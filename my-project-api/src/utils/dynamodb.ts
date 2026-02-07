import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient } from '@aws-sdk/lib-dynamodb';

/**
 * Create DynamoDB Document Client
 */
export const createDynamoDBClient = (): DynamoDBDocumentClient => {
  const client = new DynamoDBClient({
    region: process.env.AWS_REGION || 'us-west-2',
  });

  return DynamoDBDocumentClient.from(client, {
    marshallOptions: {
      removeUndefinedValues: true,
      convertClassInstanceToMap: true,
    },
  });
};

export const dynamoDBClient = createDynamoDBClient();
