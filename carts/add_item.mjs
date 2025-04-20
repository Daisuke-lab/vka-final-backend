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
                    'Access-Control-Allow-Origin': '*'
                },
                body: JSON.stringify({ error: 'Unauthorized: Missing or invalid Cognito authentication' })
            };
        }

        const user_email = claims.email;
        const userId = `USER_${user_email}`;
        const sortId = 'CART';

        // Parse item details from request body
        const { product_id, product_image, product_name, quantity, price } = JSON.parse(event.body || '{}');
        
        // Validate input
        if (!product_id || !product_name || !quantity || price === undefined || price < 0) {
            return {
                statusCode: 400,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                body: JSON.stringify({ error: 'Missing or invalid fields: product_id, product_name, quantity, price (must be non-negative)' })
            };
        }

        // New item to add
        const newItem = {
            product_id: parseInt(product_id),
            product_image: product_image || '',
            product_name,
            quantity: parseInt(quantity),
            price: parseFloat(price)
        };

        // Get existing cart
        const getParams = {
            TableName: 'UserTable',
            Key: {
                user_id: userId,
                sort_id: sortId
            }
        };

        const { Item } = await dynamodb.send(new GetCommand(getParams));
        let cartItems = Item?.items || [];

        // Check if product already exists in cart
        const existingItemIndex = cartItems.findIndex(item => item.product_id === newItem.product_id);
        if (existingItemIndex !== -1) {
            // Update quantity and price if product exists
            cartItems[existingItemIndex].quantity += newItem.quantity;
            cartItems[existingItemIndex].price = newItem.price; // Update price to the latest provided
        } else {
            // Add new item to array
            cartItems.push(newItem);
        }

        // Prepare DynamoDB item
        const putParams = {
            TableName: 'UserTable',
            Item: {
                user_id: userId,
                sort_id: sortId,
                items: cartItems,
                updated_at: new Date().toISOString()
            }
        };

        // Update DynamoDB
        await dynamodb.send(new PutCommand(putParams));

        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({ 
                message: 'Item added to cart successfully',
                cart: putParams.Item 
            })
        };

    } catch (error) {
        console.error('Error adding item to cart:', error);
        return {
            statusCode: 500,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({ error: 'Failed to add item to cart' })
        };
    }
};