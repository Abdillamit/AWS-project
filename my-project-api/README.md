# My Project API

Backend Lambda functions for My Project GraphQL API.

## Prerequisites

- Node.js 18+
- AWS CLI configured

## Installation

```bash
npm install
```

## Project Structure

```
src/
├── handlers/           # Lambda function handlers
│   ├── hello.ts       # Hello world handler
│   └── __tests__/     # Handler tests
├── services/          # Business logic services
├── models/            # Data models
└── utils/             # Helper functions
    └── dynamodb.ts    # DynamoDB client
```

## Development

### Build

```bash
npm run build
```

### Watch mode

```bash
npm run watch
```

### Run tests

```bash
npm test
```

### Run tests in watch mode

```bash
npm run test:watch
```

## Lambda Handlers

### Hello Handler

Simple "Hello World" handler that demonstrates:
- AppSync resolver integration
- Environment variable access
- Logging
- TypeScript types

**Environment Variables:**
- `STAGE`: Deployment stage (beta/prod)
- `USERS_TABLE_NAME`: DynamoDB table name

## Testing

Tests use Jest with ts-jest for TypeScript support. Mock AWS SDK calls in tests.

## Deployment

Lambda functions are deployed via AWS CDK infrastructure. See `my-project-infrastructure` for deployment instructions.
