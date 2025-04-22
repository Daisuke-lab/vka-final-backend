import json
import boto3
from boto3.dynamodb.conditions import Key

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
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "Content-Type,Authorization",
                "Access-Control-Allow-Methods": "GET,POST,OPTIONS"
            },
            'body': json.dumps(list(set([category['category'] for category in categories])))
        }
    except Exception as e:
        print(e)
        return {
            'statusCode': 400,
            'body': str(e)
        }

