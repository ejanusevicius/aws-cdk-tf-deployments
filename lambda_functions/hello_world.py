import json
import boto3
import os

dynamodb = boto3.client('dynamodb')

def lambda_handler(event, context):
    deployment_mechanism = os.environ["deployment_mechanism"]
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': f'hello world from {deployment_mechanism}'
        })
    }