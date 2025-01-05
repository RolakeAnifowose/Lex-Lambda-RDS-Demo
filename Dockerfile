FROM python:3.8

RUN pip3 install Flask boto3 flask-mysqldb

COPY templates/ templates/
COPY app.py app.py


CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0", "--port=80"]