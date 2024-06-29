import boto3
import json
import pandas as pd
from sqlalchemy import create_engine

# AWS Clients
s3_client = boto3.client('s3')

# Configuration (replace with your actual values)
S3_BUCKET = 'devops-tejas-new'
S3_KEY = 'csvdata/emp.csv'
RDS_ENDPOINT = 'prod-database.cr3uq7sok2wz.us-east-1.rds.amazonaws.com'
RDS_DB = 'employeedb'
RDS_USER = 'admin'
RDS_PASSWORD = 'Tejas2002'

# Read the data from the .csv file present in the s3 bucket
def read_data_from_s3(bucket, key):
    obj = s3_client.get_object(Bucket=bucket, Key=key)
    return pd.read_csv(obj['Body'])

# Push the data read from to the .csv file to RDS database
def push_to_rds(dataframe):
    try:
        engine = create_engine(f'mysql+pymysql://{RDS_USER}:{RDS_PASSWORD}@{RDS_ENDPOINT}/{RDS_DB}')
        dataframe.to_sql('employee', engine, if_exists='replace', index=False)
        print('Data pushed to RDS successfully')
    except Exception as e:
        print(f'Error pushing data to RDS: {e}')
        return False
    return True

# Call the lambda_handler function
def lambda_handler(event, context):
    dataframe = read_data_from_s3(S3_BUCKET, S3_KEY)
    push_to_rds(dataframe)

    return{
        'statusCode' : 200,
        'body' : json.dumps('Data pushed successfully')
    }


