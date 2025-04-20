import json
import boto3
from boto3.dynamodb.conditions import Key
import simplejson as json

dynamodb = boto3.resource('dynamodb')
TABLE_NAME = "ProductTable"
table = dynamodb.Table(TABLE_NAME)
def handler(event, context):
    try:
        scan_kwargs = {
            "ProjectionExpression": "category",
        }
        categories = table.scan(**scan_kwargs)['Items']
        # TODO implement
        return {
            'statusCode': 200,
            'body': list(set([category['category'] for category in categories]))
        }
    except Exception as e:
        print(e)
        return {
            'statusCode': 400,
            'body': str(e)
        }

