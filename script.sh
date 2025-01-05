#!/bin/bash -xe
yum install wget -y
cd /home/ec2-user/
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
pip3 install pymysql boto3
wget https://learn-cantrill-labs.s3.amazonaws.com/aws-lex-lambda-rds/app.zip
wget https://learn-cantrill-labs.s3.amazonaws.com/aws-lex-lambda-rds/db_init.py