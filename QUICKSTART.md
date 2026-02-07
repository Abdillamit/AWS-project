# Quick Start Guide

Get up and running with My Project in 15 minutes.

## Prerequisites Check

```bash
# Check Node.js version (need 18+)
node --version

# Check npm version (need 10+)
npm --version

# Check AWS CLI
aws --version

# Check AWS credentials
aws sts get-caller-identity
```

## 5-Minute Local Setup

### 1. Install Dependencies (2 min)

```bash
# Install all dependencies
cd my-project-infrastructure && npm install && cd ..
cd my-project-api && npm install && cd ..
cd my-project-web && npm install --legacy-peer-deps && cd ..
```

### 2. Build and Test (3 min)

```bash
# Build infrastructure
cd my-project-infrastructure
npm run build
npm test

# Build and test API
cd ../my-project-api
npm run build
npm test

# Test frontend
cd ../my-project-web
npm test
```

If all tests pass, you're ready to deploy! ✅

## 10-Minute AWS Deployment

### 1. Bootstrap CDK (1 min, first time only)

```bash
cd my-project-infrastructure

# Get your AWS account ID
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Bootstrap CDK
cdk bootstrap aws://$AWS_ACCOUNT_ID/us-west-2
```

### 2. Deploy to Beta (5-7 min)

```bash
# Deploy all stacks at once
cdk deploy betaMyServiceStorageStack betaMyServiceAuthStack betaMyServiceAPIStack --require-approval never
```

Wait for deployment to complete. This creates:
- ✅ DynamoDB table
- ✅ S3 buckets
- ✅ Cognito User Pool
- ✅ AppSync GraphQL API
- ✅ Lambda function

### 3. Get API Credentials (1 min)

```bash
# Save these to a file
aws cloudformation describe-stacks \
  --stack-name betaMyServiceAPIStack \
  --query 'Stacks[0].Outputs' \
  --output table > api-credentials.txt

cat api-credentials.txt
```

### 4. Test the API (1 min)

```bash
# Extract values (or copy from api-credentials.txt)
export GRAPHQL_URL=$(aws cloudformation describe-stacks \
  --stack-name betaMyServiceAPIStack \
  --query 'Stacks[0].Outputs[?OutputKey==`GraphQLApiUrl`].OutputValue' \
  --output text)

export API_KEY=$(aws cloudformation describe-stacks \
  --stack-name betaMyServiceAPIStack \
  --query 'Stacks[0].Outputs[?OutputKey==`GraphQLApiKey`].OutputValue' \
  --output text)

# Test the API
curl -X POST \
  -H "Content-Type: application/json" \
  -H "x-api-key: $API_KEY" \
  -d '{"query":"{ hello { message stage timestamp } }"}' \
  $GRAPHQL_URL
```

Expected response:
```json
{
  "data": {
    "hello": {
      "message": "Hello from Lambda!",
      "stage": "beta",
      "timestamp": "2026-02-07T..."
    }
  }
}
```

### 5. Run Frontend Locally (2 min)

```bash
cd my-project-web

# Create .env.development file
cat > .env.development << EOF
GATSBY_GRAPHQL_ENDPOINT=$GRAPHQL_URL
GATSBY_API_KEY=$API_KEY
GATSBY_STAGE=beta
EOF

# Start development server
npm run dev
```

Open http://localhost:8000 - you should see "Hello from Lambda!" 🎉

## What You Just Built

- ✅ **Backend**: GraphQL API with Lambda functions
- ✅ **Database**: DynamoDB table with GSI
- ✅ **Storage**: S3 buckets for assets and media
- ✅ **Auth**: Cognito User Pool (ready for authentication)
- ✅ **Frontend**: Gatsby app with Apollo Client
- ✅ **State Management**: Redux + Redux-Observable
- ✅ **Multi-Environment**: Beta environment deployed

## Next Steps

### Option 1: Deploy to Production

```bash
cd my-project-infrastructure
cdk deploy MyServiceStorageStack MyServiceAuthStack MyServiceAPIStack
```

### Option 2: Add Business Logic

1. Edit `my-project-api/src/handlers/hello.ts`
2. Update GraphQL schema in `my-project-infrastructure/lib/graphql/schema.graphql`
3. Rebuild and redeploy

### Option 3: Customize Frontend

1. Edit `my-project-web/src/pages/index.tsx`
2. Add components in `my-project-web/src/components/`
3. Run `npm run dev` to see changes

### Option 4: Set Up CI/CD

See `PIPELINE.md` for setting up automated deployments with AWS CodePipeline.

## Common Commands

### Infrastructure

```bash
cd my-project-infrastructure

# View what will be deployed
npm run synth:beta

# See differences from deployed stack
npm run diff:beta

# Deploy changes
cdk deploy betaMyServiceAPIStack

# View logs
aws logs tail /aws/lambda/betaMyProject-Hello --follow
```

### API

```bash
cd my-project-api

# Build
npm run build

# Test
npm test

# Watch mode
npm run watch
```

### Frontend

```bash
cd my-project-web

# Development
npm run dev

# Build for beta
npm run build:beta

# Build for production
npm run build:prod

# Run tests
npm test
```

## Troubleshooting

### "CDK bootstrap required"

```bash
cdk bootstrap aws://YOUR_ACCOUNT_ID/us-west-2
```

### "Access Denied" errors

Check your AWS credentials:
```bash
aws sts get-caller-identity
aws configure list
```

### Frontend shows "Error: Failed to fetch"

1. Check API URL in `.env.development`
2. Verify API Key is correct
3. Test API with curl first

### Lambda function errors

View logs:
```bash
aws logs tail /aws/lambda/betaMyProject-Hello --follow
```

## Clean Up

To delete everything and avoid charges:

```bash
cd my-project-infrastructure
cdk destroy betaMyServiceAPIStack betaMyServiceAuthStack betaMyServiceStorageStack
```

## Getting Help

- Check `DEPLOYMENT.md` for detailed deployment guide
- Check `VERIFICATION.md` for testing checklist
- View CloudWatch logs for errors
- Check AWS Console for resource status

## Success! 🎉

You now have a working full-stack AWS application with:
- GraphQL API
- Lambda functions
- DynamoDB database
- S3 storage
- Cognito authentication
- React frontend
- Multi-environment support

Ready to build something amazing!
