import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, GetCommand, PutCommand } from '@aws-sdk/lib-dynamodb';

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
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type,Authorization',
                    'Access-Control-Allow-Methods': 'GET,POST,OPTIONS'
                },
                body: JSON.stringify({ error: 'Unauthorized: Missing or invalid Cognito authentication' })
            };
        }

        const user_email = claims.email;
        const userId = `USER_${user_email}`;
        const sortId = 'CART';

        // Parse product_id and new_quantity from request body
        const { product_id, new_quantity } = JSON.parse(event.body || '{}');
        
        // Validate input
        if (!product_id || new_quantity === undefined || new_quantity < 0) {
            return {
                statusCode: 400,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type,Authorization',
                    'Access-Control-Allow-Methods': 'GET,POST,OPTIONS'
                },
                body: JSON.stringify({ error: 'Missing or invalid fields: product_id, new_quantity (must be non-negative)' })
            };
        }

        const productId = parseInt(product_id);
        const quantity = parseInt(new_quantity);

        // Get existing cart
        const getParams = {
            TableName: 'UserTable',
            Key: {
                user_id: userId,
                sort_id: sortId
            }
        };

        const { Item } = await dynamodb.send(new GetCommand(getParams));

        // Check if cart exists and has items
        if (!Item || !Item.items || Item.items.length === 0) {
            return {
                statusCode: 404,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type,Authorization',
                    'Access-Control-Allow-Methods': 'GET,POST,OPTIONS'
                },
                body: JSON.stringify({ error: 'Cart is empty or does not exist' })
            };
        }

        // Find the item in the cart
        const itemIndex = Item.items.findIndex(item => item.product_id === productId);
        if (itemIndex === -1) {
            return {
                statusCode: 404,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type,Authorization',
                    'Access-Control-Allow-Methods': 'GET,POST,OPTIONS'
                },
                body: JSON.stringify({ error: 'Item not found in cart' })
            };
        }

        let updatedItems = Item.items;

        if (quantity === 0) {
            // Remove item if new_quantity is 0
            updatedItems = Item.items.filter(item => item.product_id !== productId);
        } else {
            // Update quantity
            updatedItems[itemIndex].quantity = quantity;
        }

        // Prepare DynamoDB item
        const putParams = {
            TableName: 'UserTable',
            Item: {
                user_id: userId,
                sort_id: sortId,
                items: updatedItems,
                updated_at: new Date().toISOString()
            }
        };

        // Update DynamoDB
        await dynamodb.send(new PutCommand(putParams));

        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type,Authorization',
                'Access-Control-Allow-Methods': 'GET,POST,OPTIONS'
            },
            body: JSON.stringify({ 
                message: quantity === 0 ? 'Item removed from cart successfully' : 'Item quantity updated successfully',
                cart: putParams.Item 
            })
        };

    } catch (error) {
        console.error('Error updating item quantity:', error);
        return {
            statusCode: 500,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type,Authorization',
                'Access-Control-Allow-Methods': 'GET,POST,OPTIONS'
            },
            body: JSON.stringify({ error: 'Failed to update item quantity' })
        };
    }
};