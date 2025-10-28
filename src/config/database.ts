import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient } from '@aws-sdk/lib-dynamodb';

// DynamoDB Client Configuration
const client = new DynamoDBClient({
  region: process.env.AWS_REGION || 'us-east-1',
  ...(process.env.DYNAMODB_ENDPOINT && {
    endpoint: process.env.DYNAMODB_ENDPOINT, // For local development with DynamoDB Local
  }),
});

// Document client wrapper for easier interaction
const ddbDocClient = DynamoDBDocumentClient.from(client, {
  marshallOptions: {
    removeUndefinedValues: true, // Remove undefined values from items
    convertEmptyValues: false,
  },
  unmarshallOptions: {
    wrapNumbers: false, // Don't wrap numbers in objects
  },
});

export const TABLE_NAME = process.env.TABLE_NAME || 'duemate-dev-main';

export default ddbDocClient;
