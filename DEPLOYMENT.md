# Deployment Guide

Complete guide for deploying the My Project full-stack application to AWS.

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **AWS CLI** configured with credentials
3. **Node.js 18+** and npm 10+
4. **AWS CDK CLI**: `npm install -g aws-cdk`
5. **GitHub Account** (for CI/CD pipeline)

## Initial Setup

### 1. Install Dependencies

```bash
# Infrastructure
cd my-project-infrastructure
npm install

# API
cd ../my-project-api
npm install

# Web
cd ../my-project-web
npm install --legacy-peer-deps
```

### 2. Bootstrap AWS CDK

First time only, bootstrap CDK in your AWS account:

```bash
cd my-project-infrastructure
cdk bootstrap aws://YOUR_ACCOUNT_ID/us-west-2
```

Replace `YOUR_ACCOUNT_ID` with your AWS account ID.

## Phase 1: Deploy Infrastructure to Beta

### Step 1: Deploy Storage Stack

```bash
cd my-project-infrastructure
npm run build
cdk deploy betaMyServiceStorageStack
```

This creates:
- DynamoDB table: `betaUsersTable`
- S3 buckets: `beta-my-project-assets`, `beta-my-project-media`

### Step 2: Deploy Auth Stack

```bash
cdk deploy betaMyServiceAuthStack
```

This creates:
- Cognito User Pool: `betaMyProjectUserPool`
- User Pool Client
- Identity Pool

### Step 3: Deploy API Stack

```bash
cdk deploy betaMyServiceAPIStack
```

This creates:
- AppSync GraphQL API
- Lambda function for hello query
- API Key for testing

### Step 4: Get Stack Outputs

```bash
aws cloudformation describe-stacks \
  --stack-name betaMyServiceAPIStack \
  --query 'Stacks[0].Outputs' \
  --output table
```

Save these values:
- `GraphQLApiUrl`
- `GraphQLApiKey`
- `UserPoolId`
- `UserPoolClientId`

## Phase 2: Configure and Deploy Frontend

### Step 1: Create Environment File

Create `my-project-web/.env.development`:

```env
GATSBY_GRAPHQL_ENDPOINT=<GraphQLApiUrl from stack outputs>
GATSBY_API_KEY=<GraphQLApiKey from stack outputs>
GATSBY_STAGE=beta
GATSBY_USER_POOL_ID=<UserPoolId from stack outputs>
GATSBY_USER_POOL_CLIENT_ID=<UserPoolClientId from stack outputs>
```

### Step 2: Test Locally

```bash
cd my-project-web
npm run dev
```

Open http://localhost:8000 and verify the "Hello from Lambda!" message appears.

### Step 3: Build for Beta

```bash
npm run build:beta
```

### Step 4: Deploy to S3 (Manual for now)

```bash
# Upload to S3 bucket (you'll need to create this or add to CDK)
aws s3 sync public/ s3://beta-my-project-web --delete
```

## Phase 3: Deploy to Production

### Step 1: Deploy Infrastructure

```bash
cd my-project-infrastructure
cdk deploy MyServiceStorageStack MyServiceAuthStack MyServiceAPIStack
```

### Step 2: Get Production Outputs

```bash
aws cloudformation describe-stacks \
  --stack-name MyServiceAPIStack \
  --query 'Stacks[0].Outputs' \
  --output table
```

### Step 3: Configure Frontend for Production

Create `my-project-web/.env.production`:

```env
GATSBY_GRAPHQL_ENDPOINT=<Production GraphQLApiUrl>
GATSBY_API_KEY=<Production GraphQLApiKey>
GATSBY_STAGE=prod
GATSBY_USER_POOL_ID=<Production UserPoolId>
GATSBY_USER_POOL_CLIENT_ID=<Production UserPoolClientId>
```

### Step 4: Build and Deploy

```bash
cd my-project-web
npm run build:prod
aws s3 sync public/ s3://my-project-web --delete
```

## Verification Checklist

### Beta Environment

- [ ] DynamoDB table `betaUsersTable` exists
- [ ] S3 buckets created
- [ ] Cognito User Pool created
- [ ] AppSync API accessible
- [ ] GraphQL query returns "Hello from Lambda!"
- [ ] Website loads at beta URL
- [ ] API Key authentication works

### Production Environment

- [ ] All infrastructure stacks deployed
- [ ] Resources named without "beta" prefix
- [ ] GraphQL API accessible
- [ ] Website loads at production URL
- [ ] All functionality works

## Testing the GraphQL API

### Using AWS Console

1. Go to AWS AppSync console
2. Select your API
3. Go to "Queries" tab
4. Run:

```graphql
query {
  hello {
    message
    stage
    timestamp
  }
}
```

### Using curl

```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -H "x-api-key: YOUR_API_KEY" \
  -d '{"query":"{ hello { message stage timestamp } }"}' \
  YOUR_GRAPHQL_ENDPOINT
```

## Troubleshooting

### CDK Deploy Fails

- Check AWS credentials: `aws sts get-caller-identity`
- Verify CDK is bootstrapped: `cdk bootstrap`
- Check for resource limits in your AWS account

### GraphQL API Returns Error

- Verify Lambda function has correct permissions
- Check CloudWatch logs for Lambda errors
- Verify DynamoDB table exists and is accessible

### Frontend Can't Connect to API

- Verify environment variables are set correctly
- Check CORS settings in AppSync
- Verify API Key is valid
- Check browser console for errors

### Lambda Function Errors

View logs:

```bash
aws logs tail /aws/lambda/betaMyProject-Hello --follow
```

## Cost Optimization

- Use DynamoDB on-demand billing (already configured)
- Set up billing alerts in AWS Console
- Delete unused resources
- Use CloudWatch to monitor usage

## Cleanup

To delete all resources:

```bash
cd my-project-infrastructure

# Delete beta
cdk destroy betaMyServiceAPIStack betaMyServiceAuthStack betaMyServiceStorageStack

# Delete prod
cdk destroy MyServiceAPIStack MyServiceAuthStack MyServiceStorageStack
```

**Warning**: This will permanently delete all data!

## Next Steps

1. Set up CI/CD pipeline (see PIPELINE.md)
2. Add custom domain names
3. Configure CloudFront for frontend
4. Add monitoring and alerts
5. Implement real business logic
6. Add more Lambda functions
7. Expand GraphQL schema
