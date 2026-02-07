# Deployment Checklist

Use this checklist to track your progress through the deployment process.

## Phase 1: Local Setup ✓

### Prerequisites
- [ ] Node.js 18+ installed
- [ ] npm 10+ installed
- [ ] AWS CLI installed and configured
- [ ] AWS CDK CLI installed (`npm install -g aws-cdk`)
- [ ] Git installed
- [ ] AWS account with appropriate permissions

### Install Dependencies
- [ ] Infrastructure dependencies installed (`cd my-project-infrastructure && npm install`)
- [ ] API dependencies installed (`cd my-project-api && npm install`)
- [ ] Web dependencies installed (`cd my-project-web && npm install --legacy-peer-deps`)

### Build and Test
- [ ] Infrastructure builds successfully (`npm run build`)
- [ ] Infrastructure tests pass (`npm test`)
- [ ] API builds successfully (`npm run build`)
- [ ] API tests pass (`npm test`)
- [ ] Web tests pass (`npm test`)

**Quick Setup**: Run `./setup.sh` to complete all of the above automatically.

## Phase 2: AWS Setup

### AWS Account Configuration
- [ ] AWS account created
- [ ] IAM user created with admin permissions (or appropriate permissions)
- [ ] AWS CLI configured (`aws configure`)
- [ ] AWS credentials verified (`aws sts get-caller-identity`)
- [ ] Default region set (recommend: us-west-2)

### CDK Bootstrap
- [ ] Get AWS account ID: `aws sts get-caller-identity --query Account --output text`
- [ ] Bootstrap CDK: `cdk bootstrap aws://ACCOUNT_ID/REGION`
- [ ] Verify bootstrap stack exists in CloudFormation console

## Phase 3: Deploy to Beta

### Infrastructure Deployment
- [ ] Navigate to infrastructure directory (`cd my-project-infrastructure`)
- [ ] Build project (`npm run build`)
- [ ] Review what will be deployed (`npm run synth:beta`)
- [ ] Deploy Storage Stack (`cdk deploy betaMyServiceStorageStack`)
- [ ] Deploy Auth Stack (`cdk deploy betaMyServiceAuthStack`)
- [ ] Deploy API Stack (`cdk deploy betaMyServiceAPIStack`)
- [ ] All stacks show CREATE_COMPLETE status

**Quick Deploy**: `cdk deploy betaMyServiceStorageStack betaMyServiceAuthStack betaMyServiceAPIStack`

### Verify Infrastructure
- [ ] DynamoDB table `betaUsersTable` exists
- [ ] S3 buckets created (`beta-my-project-assets`, `beta-my-project-media`)
- [ ] Cognito User Pool `betaMyProjectUserPool` exists
- [ ] AppSync API `betaMyProjectAPI` exists
- [ ] Lambda function `betaMyProject-Hello` exists

### Get Stack Outputs
- [ ] Get GraphQL API URL
- [ ] Get GraphQL API Key
- [ ] Get User Pool ID
- [ ] Get User Pool Client ID
- [ ] Save credentials to a secure location

**Command**: 
```bash
aws cloudformation describe-stacks \
  --stack-name betaMyServiceAPIStack \
  --query 'Stacks[0].Outputs' \
  --output table
```

## Phase 4: Test API

### GraphQL API Testing
- [ ] Copy GraphQL URL from stack outputs
- [ ] Copy API Key from stack outputs
- [ ] Test with curl:
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -H "x-api-key: YOUR_API_KEY" \
  -d '{"query":"{ hello { message stage timestamp } }"}' \
  YOUR_GRAPHQL_URL
```
- [ ] Verify response contains "Hello from Lambda!"
- [ ] Verify stage is "beta"
- [ ] Verify timestamp is current

### Lambda Testing
- [ ] Test Lambda directly:
```bash
aws lambda invoke \
  --function-name betaMyProject-Hello \
  --payload '{}' \
  response.json
```
- [ ] Check response.json for correct output
- [ ] View CloudWatch logs:
```bash
aws logs tail /aws/lambda/betaMyProject-Hello --follow
```
- [ ] No errors in logs

### AppSync Console Testing
- [ ] Open AWS AppSync console
- [ ] Select `betaMyProjectAPI`
- [ ] Go to "Queries" tab
- [ ] Run test query
- [ ] Verify response

## Phase 5: Configure Frontend

### Environment Configuration
- [ ] Navigate to web directory (`cd my-project-web`)
- [ ] Copy `.env.example` to `.env.development`
- [ ] Set `GATSBY_GRAPHQL_ENDPOINT` to your API URL
- [ ] Set `GATSBY_API_KEY` to your API key
- [ ] Set `GATSBY_STAGE=beta`
- [ ] Set Cognito User Pool ID
- [ ] Set Cognito User Pool Client ID

### Local Testing
- [ ] Start development server (`npm run dev`)
- [ ] Open http://localhost:8000
- [ ] Verify page loads without errors
- [ ] Verify "Hello from Lambda!" message displays
- [ ] Verify stage shows "beta"
- [ ] Verify timestamp is current
- [ ] Check browser console for errors (should be none)

## Phase 6: Deploy to Production

### Production Deployment
- [ ] Navigate to infrastructure directory
- [ ] Review production changes (`npm run diff:prod`)
- [ ] Deploy Storage Stack (`cdk deploy MyServiceStorageStack`)
- [ ] Deploy Auth Stack (`cdk deploy MyServiceAuthStack`)
- [ ] Deploy API Stack (`cdk deploy MyServiceAPIStack`)
- [ ] All stacks show CREATE_COMPLETE status

### Verify Production
- [ ] DynamoDB table `UsersTable` exists (no "beta" prefix)
- [ ] S3 buckets created without "beta" prefix
- [ ] Cognito User Pool `MyProjectUserPool` exists
- [ ] AppSync API `MyProjectAPI` exists
- [ ] Lambda function `MyProject-Hello` exists

### Production Testing
- [ ] Get production stack outputs
- [ ] Test production GraphQL API
- [ ] Verify Lambda function works
- [ ] Check CloudWatch logs

### Production Frontend
- [ ] Create `.env.production` with production credentials
- [ ] Build for production (`npm run build:prod`)
- [ ] Test production build locally (`npm run serve`)
- [ ] Verify all functionality works

## Phase 7: Security Review

### Access Control
- [ ] S3 buckets have public access blocked
- [ ] DynamoDB tables not publicly accessible
- [ ] Lambda functions have minimal IAM permissions
- [ ] Cognito password policy is strong
- [ ] API keys are stored securely (not in code)

### Encryption
- [ ] DynamoDB encryption at rest enabled
- [ ] S3 buckets use encryption
- [ ] All traffic uses HTTPS/TLS
- [ ] Secrets stored in AWS Secrets Manager

### Monitoring
- [ ] CloudWatch Logs enabled for Lambda
- [ ] AppSync logging enabled
- [ ] X-Ray tracing enabled
- [ ] CloudTrail enabled for audit logs

## Phase 8: Cost Management

### Cost Optimization
- [ ] DynamoDB using on-demand billing
- [ ] Lambda timeout set appropriately (30s)
- [ ] S3 lifecycle policies configured (if needed)
- [ ] Unused resources deleted

### Cost Monitoring
- [ ] AWS Cost Explorer enabled
- [ ] Budget alert created (e.g., $10/month)
- [ ] Email notification configured
- [ ] Resource tags applied for cost allocation

### Estimated Costs
- [ ] Reviewed estimated monthly costs
- [ ] Understand pay-per-use pricing
- [ ] Know how to check current costs

## Phase 9: Documentation

### Project Documentation
- [ ] README.md reviewed
- [ ] QUICKSTART.md followed
- [ ] DEPLOYMENT.md consulted
- [ ] VERIFICATION.md completed
- [ ] ARCHITECTURE.md understood

### Team Documentation
- [ ] API endpoints documented
- [ ] Environment variables documented
- [ ] Deployment process documented
- [ ] Troubleshooting guide created
- [ ] Runbook for common tasks

## Phase 10: CI/CD (Optional)

### GitHub Setup
- [ ] Create GitHub repositories
- [ ] Push code to repositories
- [ ] Create GitHub Personal Access Token
- [ ] Store token in AWS Secrets Manager

### Pipeline Setup
- [ ] Update buildspec.yml files with secret ARN
- [ ] Create pipeline stack
- [ ] Deploy pipeline stack
- [ ] Test pipeline with a commit

### Pipeline Verification
- [ ] Pipeline triggers on push
- [ ] Build stage completes
- [ ] Tests pass
- [ ] Beta deployment succeeds
- [ ] Manual approval works
- [ ] Production deployment succeeds

## Phase 11: Monitoring & Alerts

### CloudWatch Setup
- [ ] Create dashboard for key metrics
- [ ] Set up alarms for errors
- [ ] Configure SNS topic for notifications
- [ ] Subscribe email to SNS topic
- [ ] Test alarm notifications

### Logging
- [ ] Lambda logs accessible
- [ ] AppSync logs enabled
- [ ] Log retention period set
- [ ] Log insights queries created

## Phase 12: Next Steps

### Immediate Improvements
- [ ] Add custom domain names
- [ ] Configure CloudFront for frontend
- [ ] Add SSL certificates
- [ ] Implement user authentication flow
- [ ] Add more Lambda functions

### Feature Development
- [ ] Expand GraphQL schema
- [ ] Implement CRUD operations
- [ ] Add more UI components
- [ ] Implement real business logic
- [ ] Add file upload functionality

### Advanced Features
- [ ] Real-time subscriptions
- [ ] OpenSearch integration
- [ ] SQS for async processing
- [ ] Email notifications (SES)
- [ ] Multi-region deployment

## Troubleshooting Checklist

If something goes wrong, check:

### Deployment Issues
- [ ] AWS credentials are valid
- [ ] CDK is bootstrapped
- [ ] No resource name conflicts
- [ ] IAM permissions are sufficient
- [ ] CloudFormation events for errors

### API Issues
- [ ] API Key is correct
- [ ] GraphQL endpoint is correct
- [ ] Lambda has DynamoDB permissions
- [ ] CloudWatch logs for errors
- [ ] CORS settings if browser errors

### Frontend Issues
- [ ] Environment variables set correctly
- [ ] API endpoint is accessible
- [ ] No CORS errors in console
- [ ] Dependencies installed correctly
- [ ] Build completed successfully

## Success Criteria

Your deployment is successful when:

- ✅ All infrastructure stacks deployed
- ✅ GraphQL API returns correct response
- ✅ Frontend displays data from API
- ✅ All tests pass
- ✅ No errors in CloudWatch logs
- ✅ Security best practices followed
- ✅ Costs are within expected range
- ✅ Documentation is complete
- ✅ Team can deploy independently

## Completion

Date Completed: _______________

Deployed By: _______________

Environment URLs:
- Beta: _______________
- Production: _______________

Notes:
_______________________________________________
_______________________________________________
_______________________________________________

---

**Congratulations! Your full-stack AWS application is now deployed and running!** 🎉
