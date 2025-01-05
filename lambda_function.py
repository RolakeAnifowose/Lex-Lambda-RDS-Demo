import pymysql
from datetime import datetime, date
import boto3

ssm = boto3.client('ssm', region_name='us-east-1')

def get_slots(event):
    return event['sessionState']['intent']['slots']

def validate_data(slots):
    animal_types = ['dog', 'cat', 'chicken']

    if slots['AnimalName'] is None:
        return {
            'isValid': False,
            'violatedSlot': 'AnimalName'
        }

    if len(slots['AnimalName']['value']['originalValue']) < 4:
        return {
            'isValid': False,
            'violatedSlot': 'AnimalName',
            'message': 'Your pet name must be at least 4 characters long.'
        }

    if slots['AnimalType'] is None:
        return {
            'isValid': False,
            'violatedSlot': 'AnimalType'
        }

    if slots['AnimalType']['value']['originalValue'].lower() not in animal_types:
        return {
            'isValid': False,
            'violatedSlot': 'AnimalType',
            'message': 'Sorry, we only schedule appointments for cats, dogs or chickens.'
        }

    if slots['ReservationDate'] is None:
        return {
            'isValid': False,
            'violatedSlot': 'ReservationDate'
        }

    if slots['ReservationTime'] is None:
        return {
            'isValid': False,
            'violatedSlot': 'ReservationTime'
        }


    return {'isValid': True}


def book_appointment(event):
    source = event['invocationSource']
    intent_name = event['sessionState']['intent']['name']

    slots = get_slots(event)

    if source == 'DialogCodeHook':
        validate_result = validate_data(slots)
        if not validate_result['isValid']:

            if 'message' in validate_result:

                response = {
                    'sessionState': {
                        'dialogAction': {
                            'slotToElicit': validate_result['violatedSlot'],
                            'type': 'ElicitSlot',
                        },
                        'intent': {
                            'name': intent_name,
                            'slots': slots,
                        }
                    },
                    'messages': [
                        {
                            'contentType': 'PlainText',
                            'content': validate_result['message']
                        }
                    ]
                }

            else:
                response = {
                    'sessionState': {
                        'dialogAction': {
                            'slotToElicit': validate_result['violatedSlot'],
                            'type': 'ElicitSlot',
                        },
                        'intent': {
                            'name': intent_name,
                            'slots': slots,
                        }
                    }
                }

            return response

        else:
            return {
                'sessionState': {
                    'dialogAction': {
                        'type': 'Delegate'
                    },
                    'intent': {
                        'name': intent_name,
                        'slots': slots,
                    }
                }
            }


    elif source == 'FulfillmentCodeHook':
        animal_type = slots['AnimalType']['value']['originalValue']
        animal_name = slots['AnimalName']['value']['originalValue']
        date = transform_datetime(slots['ReservationDate']['value']['interpretedValue'])
        time = transform_time(slots['ReservationTime']['value']['interpretedValue'])
        rds_secrets = get_rds_secrets()

        conn = pymysql.connect(
            host=rds_secrets['db_url'],
            user=rds_secrets['db_user'],
            password=rds_secrets['db_password'],
            database=rds_secrets['db_database'],
        )

        with conn.cursor() as cur:
            cur.execute(
                "INSERT INTO appointments (date, time, pet_name, pet_type) VALUES (%s, %s, %s, %s)",
                (date, time, animal_name.lower(), animal_type.lower()),
            )
            conn.commit()


        return {
            'sessionState': {
                'dialogAction': {
                    'type': 'Close'
                },
                'intent': {
                    'name': intent_name,
                    'slots': slots,
                    'state': 'Fulfilled'
                }
            },
            'messages': [
                {
                    'contentType': 'PlainText',
                    'content': 'Great. It seems the system allowed me to finish the appointment. You can check your appointment in the web application.'
                }
            ]
        }

def transform_datetime(date_string):
    date_time = datetime.strptime(date_string, '%Y-%m-%d')
    date = date_time.date()

    return date


def transform_time(time_string):
    date_time = datetime.strptime(time_string, '%H:%M')
    time = date_time.time()

    return time

def get_rds_secrets():

    secrets = {
        'db_url': ssm.get_parameters(Names=['/appointment-app/prod/db-url'])['Parameters'][0]['Value'],
        'db_user': ssm.get_parameters(Names=['/appointment-app/prod/db-user'])['Parameters'][0]['Value'],
        'db_password': ssm.get_parameters(Names=['/appointment-app/prod/db-password'], WithDecryption=True)['Parameters'][0]['Value'],
        'db_database': ssm.get_parameters(Names=['/appointment-app/prod/db-database'])['Parameters'][0]['Value']
    }

    return secrets

def dispatch(event):
    intent_name = event['sessionState']['intent']['name']
    if intent_name == 'BookAppointment':
        return book_appointment(event)


def lambda_handler(event, context):
    return dispatch(event)