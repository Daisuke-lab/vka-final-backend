import json
import boto3


sns_client = boto3.client("sns")
SNS_ARN = "arn:aws:sns:us-east-2:555399571935:vka-order-placed"

def handler(event, context):
    email = event["request"]["userAttributes"]["email"]
    response = sns_client.subscribe(TopicArn=SNS_ARN,Protocol='email',Endpoint=email)
    #response = client.confirm_subscription(TopicArn=SNS_ARN,Token='string')
    # TODO implement
    return event