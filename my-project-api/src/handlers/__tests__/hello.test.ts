import { handler } from '../hello';
import { Context } from 'aws-lambda';

describe('Hello Handler', () => {
  const mockEvent: any = {
    arguments: {},
    identity: null,
    source: null,
    request: {
      headers: {},
      domainName: null,
    },
    prev: null,
    stash: {},
    info: {
      selectionSetList: [],
      selectionSetGraphQL: '',
      parentTypeName: 'Query',
      fieldName: 'hello',
      variables: {},
    },
  };

  const mockContext: Context = {
    callbackWaitsForEmptyEventLoop: false,
    functionName: 'test-function',
    functionVersion: '1',
    invokedFunctionArn: 'arn:aws:lambda:us-west-2:123456789012:function:test',
    memoryLimitInMB: '128',
    awsRequestId: 'test-request-id',
    logGroupName: '/aws/lambda/test',
    logStreamName: 'test-stream',
    getRemainingTimeInMillis: () => 30000,
    done: () => {},
    fail: () => {},
    succeed: () => {},
  };

  beforeEach(() => {
    process.env.STAGE = 'test';
    process.env.USERS_TABLE_NAME = 'testUsersTable';
  });

  it('should return hello message', async () => {
    const result = await handler(mockEvent, mockContext, () => {});

    expect(result).toBeDefined();
    expect(result!.message).toBe('Hello from Lambda!');
    expect(result!.stage).toBe('test');
    expect(result!.timestamp).toBeDefined();
  });

  it('should include timestamp in ISO format', async () => {
    const result = await handler(mockEvent, mockContext, () => {});

    expect(result!.timestamp).toMatch(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/);
  });
});
