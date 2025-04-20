import json
import boto3
from boto3.dynamodb.conditions import Key
import simplejson as json

dynamodb = boto3.resource('dynamodb')
TABLE_NAME = "ProductTable"
table = dynamodb.Table(TABLE_NAME)
def handler(event, context):
    try:
        params = event.get("params", {}).get("querystring", {})
        category = event.get("params", {}).get("path", {}).get("category", "")
        _id = event.get("params", {}).get("path", {}).get("id", "")
        res = table.get_item(Key={"category": category, "product_id": int(_id)})
        product = res.get("Item", {})
        # TODO implement
        return {
            'statusCode': 200,
            'body': product
        }
    except Exception as e:
        print(e)
        return {
            'statusCode': 400,
            'body': str(e)
        }