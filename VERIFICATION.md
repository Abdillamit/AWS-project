# Verification Checklist

Use this checklist to verify your deployment is working correctly.

## Infrastructure Verification

### Beta Environment

#### Storage Stack

```bash
# Check DynamoDB table
aws dynamodb describe-table --table-name betaUsersTable

# Check S3 buckets
aws s3 ls | grep beta-my-project
```

Expected:
- ✅ Table `betaUsersTable` exists
- ✅ Buckets `beta-my-project-assets` and `beta-my-project-media` exist

#### Auth Stack

```bash
# Check Cognito User Pool
aws cognito-idp list-user-pools --max-results 10 | grep betaMyProjectUserPool
```

Expected:
- ✅ User Pool `betaMyProjectUserPool` exists

#### API Stack

```bash
# Check AppSync API
aws appsync list-graphql-apis | grep betaMyProjectAPI

# Check Lambda function
aws lambda get-function --function-name betaMyProject-Hello
```

Expected:
- ✅ AppSync API `betaMyProjectAPI` exists
- ✅ Lambda function `betaMyProject-Hello` exists

### Production Environment

Repeat the above checks without the "beta" prefix:
- `UsersTable`
- `my-project-assets`, `my-project-media`
- `MyProjectUserPool`
- `MyProjectAPI`
- `MyProject-Hello`

## Functional Verification

### 1. GraphQL API Test

Get your API details:

```bash
aws cloudformation describe-stacks \
  --stack-name betaMyServiceAPIStack \
  --query 'Stacks[0].Outputs[?OutputKey==`GraphQLApiUrl`].OutputValue' \
  --output text

aws cloudformation describe-stacks \
  --stack-name betaMyServiceAPIStack \
  --query 'Stacks[0].Outputs[?OutputKey==`GraphQLApiKey`].OutputValue' \
  --output text
```

Test the API:

```bash
GRAPHQL_URL="<your-api-url>"
API_KEY="<your-api-key>"

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

### 2. Lambda Function Test

```bash
aws lambda invoke \
  --function-name betaMyProject-Hello \
  --payload '{}' \
  response.json

cat response.json
```

Expected:
- ✅ Function executes successfully
- ✅ Returns message, stage, and timestamp

### 3. Frontend Test

If deployed:

```bash
# Check if website is accessible
curl -I https://beta.mydomain.com
```

Or open in browser and verify:
- ✅ Page loads without errors
- ✅ "Hello from Lambda!" message displays
- ✅ Stage shows "beta"
- ✅ Timestamp is current

### 4. CloudWatch Logs

```bash
# View Lambda logs
aws logs tail /aws/lambda/betaMyProject-Hello --follow

# Invoke function and watch logs
aws lambda invoke --function-name betaMyProject-Hello --payload '{}' /dev/null
```

Expected:
- ✅ Logs appear in CloudWatch
- ✅ No error messages
- ✅ Event data is logged

## Security Verification

### 1. S3 Bucket Security

```bash
aws s3api get-bucket-acl --bucket beta-my-project-assets
aws s3api get-public-access-block --bucket beta-my-project-assets
```

Expected:
- ✅ Public access is blocked
- ✅ No public ACLs

### 2. DynamoDB Security

```bash
aws dynamodb describe-table --table-name betaUsersTable \
  --query 'Table.SSEDescription'
```

Expected:
- ✅ Encryption at rest enabled (or AWS managed)

### 3. Lambda Permissions

```bash
aws lambda get-policy --function-name betaMyProject-Hello
```

Expected:
- ✅ Only AppSync has invoke permissions
- ✅ No public access

## Performance Verification

### 1. API Response Time

```bash
time curl -X POST \
  -H "Content-Type: application/json" \
  -H "x-api-key: $API_KEY" \
  -d '{"query":"{ hello { message stage timestamp } }"}' \
  $GRAPHQL_URL
```

Expected:
- ✅ Response time < 1 second (cold start may be slower)

### 2. Lambda Metrics

```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Duration \
  --dimensions Name=FunctionName,Value=betaMyProject-Hello \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 3600 \
  --statistics Average
```

Expected:
- ✅ Average duration < 1000ms

## Cost Verification

### 1. Check Current Costs

```bash
# This requires AWS Cost Explorer API access
aws ce get-cost-and-usage \
  --time-period Start=$(date -d '1 day ago' +%Y-%m-%d),End=$(date +%Y-%m-%d) \
  --granularity DAILY \
  --metrics BlendedCost \
  --group-by Type=SERVICE
```

### 2. Set Up Billing Alert

1. Go to AWS Billing Console
2. Create a budget alert
3. Set threshold (e.g., $10/month)
4. Add email notification

## Troubleshooting Common Issues

### Issue: GraphQL API returns 401 Unauthorized

**Solution:**
- Verify API Key is correct
- Check if API Key has expired
- Ensure `x-api-key` header is set

### Issue: Lambda function times out

**Solution:**
```bash
# Check Lambda timeout setting
aws lambda get-function-configuration \
  --function-name betaMyProject-Hello \
  --query 'Timeout'

# Increase if needed (via CDK)
```

### Issue: DynamoDB access denied

**Solution:**
```bash
# Check Lambda execution role
aws lambda get-function-configuration \
  --function-name betaMyProject-Hello \
  --query 'Role'

# Verify role has DynamoDB permissions
aws iam get-role-policy \
  --role-name <role-name> \
  --policy-name <policy-name>
```

### Issue: Frontend can't connect to API

**Solution:**
- Check browser console for CORS errors
- Verify environment variables in `.env` files
- Test API directly with curl
- Check AppSync CORS settings

## Success Criteria

Your deployment is successful when:

- ✅ All infrastructure stacks deployed without errors
- ✅ GraphQL API returns correct response
- ✅ Lambda function executes successfully
- ✅ Frontend displays data from API
- ✅ No errors in CloudWatch logs
- ✅ Security best practices followed
- ✅ Costs are within expected range

## Next Steps After Verification

1. ✅ Document API endpoints and credentials
2. ✅ Set up monitoring dashboards
3. ✅ Configure alerts for errors
4. ✅ Plan CI/CD pipeline setup
5. ✅ Begin implementing business logic
