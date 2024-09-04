import os
import json
import boto3
import requests
from datetime import datetime

# Initialize AWS clients
secrets_client = boto3.client('secretsmanager')
s3 = boto3.client('s3')

# Initialise Variables
bucket_name = os.getenv('BUCKET_NAME', 'swanna-bronze')  # Provide a default value if needed


def get_secret(secret_name):
    try:
        # Retrieve secret from AWS Secrets Manager
        response = secrets_client.get_secret_value(SecretId=secret_name)
        secret = response['SecretString']
        return json.loads(secret)
    except Exception as e:
        print(f"Error retrieving secret: {e}")
        raise

def lambda_handler(event, context):
    # Retrieve API key from Secrets Manager
    secrets = get_secret('AlphaVantageAPI_Key')
    api_key = secrets['AlphaVantageAPI_Key']  
    symbol = 'AAPL'
    function = 'TIME_SERIES_DAILY'
    
    # Fetch data from Alpha Vantage
    response = requests.get(f'https://www.alphavantage.co/query?function={function}&symbol={symbol}&apikey={api_key}')
    data = response.json()

    # Save to S3
    timestamp = datetime.now().strftime('%Y-%m-%d_%H-%M-%S')
    filename = f'{symbol}_{timestamp}.json'
    s3.put_object(Bucket=bucket_name, Key=filename, Body=json.dumps(data))

    return {
        'statusCode': 200,
        'body': json.dumps('Data ingested successfully')
    }
