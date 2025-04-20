import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { SNSClient, PublishCommand } from "@aws-sdk/client-sns";

import {
  GetItemCommand,
  PutItemCommand,
  QueryCommand,
  DeleteItemCommand,
} from "@aws-sdk/client-dynamodb";
const TABLE = 'UserTable';
const REGION = "us-east-2";
const ddb = new DynamoDBClient({region: REGION});
const sns = new SNSClient({ region: REGION });

const TOPIC_ARN = "arn:aws:sns:us-east-2:555399571935:vka-order-placed";


export const handler = async (event) => {
    // Get current user
  const email = event.requestContext?.authorizer?.claims?.email;
  if (!email) {
    return {
      statusCode: 401,
      body: JSON.stringify({ error: "Unauthorized" }),
    };
  }
  const userId = `USER_${email}`;

  const itemsAttr = await getCartItems(userId);
  console.log("itemsAttr:", JSON.stringify(itemsAttr, null, 2));
  if (!itemsAttr || itemsAttr.length === 0) {
    return {
      statusCode: 404,
      body: JSON.stringify({ error: "Cart not found" }),
    };
  }
  const items  = itemsAttr.map((i) => ({
    productId: i.M.product_id.N,
    quantity: parseInt(i.M.quantity.N),
    productImage: i.M.product_image.S,
    productName: i.M.product_name.S,
    productPrice: parseFloat(i.M.product_price.N),
  }));

  const totalPrice = items.reduce((acc, item) => {
    return acc + parseFloat(item.productPrice) * parseInt(item.quantity);
  }, 0);
  const status = "COMPLETED";
  const orderId = "ORDER_" + uuidv4();
  const saveStatus = await saveOrderWithArray(
    orderId,
    userId,
    items,
    totalPrice
  );

  if (!saveStatus) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "Failed to save order" }),
    };
  }

  const deleteStatus = await deleteCart(userId);

  if (!deleteStatus) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "Failed to delete cart" }),
    };
  }
  
  const message = `Thank you for your order!\n\nOrder ID: ${orderId}\nTotal: $${totalPrice}\nWe will notify you when your order ships.`;

  const command = new PublishCommand({
    TopicArn: TOPIC_ARN,
    Message: message,
    Subject: `Order Confirmation - ${orderId}`,
    MessageAttributes: {
      email: {
        DataType: "String",
        StringValue: email
      }
    }
  });

  const response = await sns.send(command);

  console.log("SNS publish response:", response);

  return {
    statusCode: 201,
    headers: {
      "Access-Control-Allow-Origin": "*", 
      "Access-Control-Allow-Credentials": true,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      message: "Order placed successfully",
      orderId: orderId
    })
  }
};

function uuidv4() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    const r = Math.random() * 16 | 0,
          v = c === 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}

const getCartItems = async (userId) => {
  try {
    const response = await ddb.send(
      new GetItemCommand({
        TableName: TABLE,
        Key: {
          user_id: { S: userId },
          sort_id: { S: "CART" },
        },
      })
    );

    if (!response.Item) {
      return {
        statusCode: 404,
        body: JSON.stringify({ error: "Cart not found" }),
      };
    }
    return response.Item.items?.L || [];
  } catch (error) {
    console.error("Error getting cart items:", error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "Failed to retrieve cart" }),
    };
  }
}

const saveOrderWithArray = async (orderId, userId, itemsArray, totalPrice) => {
  try {
    const shippingAddress = "Another Place";
    const orderStatus = "COMPLETED";

    const dynamoDBItems = itemsArray.map(item => ({
      M: {
        item_total_price: { N: (parseFloat(item.quantity) * parseFloat(item.productPrice || 1)).toString() }, // Calculate total, default price to 1 if missing
        product_id: { N: item.productId.toString() },
        product_image: { S: item.productImage },
        product_name: { S: item.productName },
        product_price: { N: item.productPrice ? item.productPrice.toString() : '0' }, // Handle potential missing price
        quantity: { N: item.quantity.toString() },
      },
    }));

    const params = {
      TableName: TABLE, // Replace with your actual table name
      Item: {
        user_id: { S: userId },
        sort_id: { S: orderId },
        items: { L: dynamoDBItems },
        shipping_address: { S: shippingAddress },
        status: { S: orderStatus },
        total_price: { N: totalPrice.toString() },
      },
    };

    const command = new PutItemCommand(params);
    return ddb.send(command);
  } catch (error) {
    console.error("Error saving order", error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "Error saving order" }),
    };
  }
};

const deleteCart = async (userId) => {
  try {
    const params = {
      TableName: TABLE, // Replace with your actual table name
      Key: {
        user_id: { S: userId },
          sort_id: { S: "CART" },
      },
    };

    const command = new DeleteItemCommand(params);
    return ddb.send(command);
    // console.log("Successfully deleted cart for user:", userId, response);
    // return response;
  } catch (error) {
    console.error("Error deleting cart for user:", userId, error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "Error deleting cart" }),
    };
  }
};
