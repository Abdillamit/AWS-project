import { AppSyncResolverEvent, AppSyncResolverHandler } from 'aws-lambda';

interface HelloResponse {
  message: string;
  stage: string;
  timestamp: string;
}

/**
 * Hello World Lambda handler for AppSync
 * Returns a simple greeting message
 */
export const handler: AppSyncResolverHandler<void, HelloResponse> = async (
  event: AppSyncResolverEvent<void>
) => {
  console.log('Event:', JSON.stringify(event, null, 2));

  const stage = process.env.STAGE || 'unknown';
  const usersTableName = process.env.USERS_TABLE_NAME || 'not-configured';

  console.log(`Running in stage: ${stage}`);
  console.log(`Users table: ${usersTableName}`);

  return {
    message: 'Hello from Lambda!',
    stage,
    timestamp: new Date().toISOString(),
  };
};
