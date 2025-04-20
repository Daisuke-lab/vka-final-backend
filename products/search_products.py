import json
import boto3
from boto3.dynamodb.conditions import Key
import simplejson as json

dynamodb = boto3.resource('dynamodb')
TABLE_NAME = "ProductTable"
table = dynamodb.Table(TABLE_NAME)
def handler(event, context):
    print("HELLO WORLD!!!!")
    try:
        params = event.get("params", {}).get("querystring", {})
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
            'body': products
        }
    except Exception as e:
        print(e)
        return {
            'statusCode': 400,
            'body': str(e)
        }


def generate_expression(params):
    expressions = []
    for key in params:
        if params[key] != "":
            values = params[key].split(",")
            for value in values:
                expressions.append(Key(key).eq(value))
    return expressions