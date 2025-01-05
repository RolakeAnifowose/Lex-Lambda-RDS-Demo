from flask import Flask, render_template, request
from flask_mysqldb import MySQL
import MySQLdb.cursors
import boto3

app = Flask(__name__)
ssm = boto3.client('ssm', region_name='us-east-1')

# Connect to the RDS database

secrets = {
    'db_url': ssm.get_parameters(Names=['/appointment-app/prod/db-url'])['Parameters'][0]['Value'],
    'db_user': ssm.get_parameters(Names=['/appointment-app/prod/db-user'])['Parameters'][0]['Value'],
    'db_password': ssm.get_parameters(Names=['/appointment-app/prod/db-password'], WithDecryption=True)['Parameters'][0]['Value'],
    'db_database': ssm.get_parameters(Names=['/appointment-app/prod/db-database'])['Parameters'][0]['Value']
}

app.config['MYSQL_HOST'] = secrets['db_url']
app.config['MYSQL_USER'] = secrets['db_user']
app.config['MYSQL_PASSWORD'] = secrets['db_password']
app.config['MYSQL_DB'] = secrets['db_database']

mysql = MySQL(app)

def validate_mysql_config_values():
    if app.config['MYSQL_HOST'] == "" or app.config['MYSQL_USER'] == "" or app.config['MYSQL_PASSWORD'] == "" or app.config['MYSQL_DB'] == "":
        return False
    else:
        return True

def validate_mysql_connection():
    try:
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cursor.execute("SELECT 1")
        cursor.fetchone()
        return True
    except:
        return False

@app.route("/", methods=["GET", "POST"])
def appointments():
    if validate_mysql_config_values() == False:
        return render_template("index.html", msg="Please configure the MySQL connection values in the app.py file")

    if validate_mysql_connection() == False:
        return render_template("index.html", msg="Unable to connect to the MySQL database")

    if request.method == "POST":
        # Get the appointment ID from the form
        appointment_id = request.form.get("appointment_id")

        # Delete the appointment from the database
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cursor.execute("DELETE FROM appointments WHERE id = %s", (appointment_id,))
        mysql.connection.commit()

    # Query the database to get all the appointments
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute("SELECT * FROM appointments")
    appointments = cursor.fetchall()


    # Render the appointments template, passing in the appointments data
    return render_template("index.html", appointments=appointments)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
