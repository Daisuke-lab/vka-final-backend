import json
import boto3
from boto3.dynamodb.conditions import Key
import simplejson as json
import traceback

dynamodb = boto3.resource('dynamodb')
TABLE_NAME = "ProductTable"
table = dynamodb.Table(TABLE_NAME)
def handler(event, context):
    print("EVENT:", event)
    try:
        params = event.get("queryStringParameters", {})
        params = params if params else {}
        #params = event.get("params", {}).get("querystring", {})
        expressions = generate_expression(params)
        if len(expressions) == 0:
            res = table.scan()
            products = res.get("Items", [])
        else:
            products = []
            for expression in expressions:
                res = table.query(KeyConditionExpression=expression)
                products.extend(res.get("Items", []))
        # TODO implement
        return {
            'statusCode': 200,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "Content-Type,Authorization",
                "Access-Control-Allow-Methods": "GET,POST,OPTIONS"
            },
            'body': json.dumps(products)
        }
    except Exception as e:
        print(traceback.format_exc())
        return {
            'statusCode': 400,
            'body': str(traceback.format_exc())
        }


def generate_expression(params):
    expressions = []
    for key in params:
        if params[key] != "":
            values = params[key].split(",")
            for value in values:
                expressions.append(Key(key).eq(value))
    return expressions