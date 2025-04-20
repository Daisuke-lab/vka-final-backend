import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, GetCommand } from '@aws-sdk/lib-dynamodb';

const client = new DynamoDBClient({ region: "us-east-2" });
const dynamodb = DynamoDBDocumentClient.from(client);

export const handler = async (event) => {
    try {
        // Extract user_email from Cognito claims
        const claims = event.requestContext?.authorizer?.claims;
        if (!claims || !claims.email) {
            return {
                statusCode: 401,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                body: JSON.stringify({ error: 'Unauthorized: Missing or invalid Cognito authentication' })
            };
        }

        const user_email = claims.email;
        const userId = `USER_${user_email}`;
        const sortId = 'CART';

        // Get cart from DynamoDB
        const getParams = {
            TableName: 'UserTable',
            Key: {
                user_id: userId,
                sort_id: sortId
            }
        };

        const { Item } = await dynamodb.send(new GetCommand(getParams));

        // Check if cart exists
        if (!Item || !Item.items) {
            return {
                statusCode: 200,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                body: JSON.stringify({ 
                    message: 'Cart is empty or does not exist',
                    items: []
                })
            };
        }

        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({ 
                message: 'Cart retrieved successfully',
                items: Item.items 
            })
        };

    } catch (error) {
        console.error('Error retrieving cart:', error);
        return {
            statusCode: 500,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({ error: 'Failed to retrieve cart' })
        };
    }
};