# Terraform Deployment Testing Guide

This guide provides instructions for testing and validating the Terraform deployment.

## Pre-Deployment Testing

### 1. Validate Configuration Syntax

```bash
cd terraform

# Validate all configuration files
terraform validate

# Check for formatting issues
terraform fmt -check -recursive

# If formatting issues found, auto-fix them
terraform fmt -recursive
```

### 2. Plan Validation

```bash
# Generate and review execution plan
terraform plan

# Save plan for review
terraform plan -out=tfplan

# Review plan in detail
terraform show tfplan

# Check plan for any unexpected changes
terraform plan | grep -E "Plan:|will be"
```

### 3. Security Scan (Optional)

Use tools like `tfsec` or `checkov` to scan for security issues:

```bash
# Install tfsec
brew install tfsec  # macOS
# or
curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash

# Run security scan
tfsec .

# Install checkov
pip install checkov

# Run checkov scan
checkov -d .
```

## Post-Deployment Testing

### 1. Verify Resource Creation

After `terraform apply`, verify all resources were created:

```bash
# Get all outputs
terraform output

# Verify specific resources via AWS CLI
aws dynamodb describe-table --table-name $(terraform output -raw dynamodb_table_name)
aws cognito-idp describe-user-pool --user-pool-id $(terraform output -raw cognito_user_pool_id)
aws lambda list-functions --query 'Functions[?starts_with(FunctionName, `duemate`)].FunctionName'
```

### 2. Test DynamoDB Access

```bash
# Get table name
TABLE_NAME=$(terraform output -raw dynamodb_table_name)

# Test write access
aws dynamodb put-item \
  --table-name $TABLE_NAME \
  --item '{
    "PK": {"S": "TEST#001"},
    "SK": {"S": "METADATA"},
    "testData": {"S": "Hello from Terraform test"}
  }'

# Test read access
aws dynamodb get-item \
  --table-name $TABLE_NAME \
  --key '{"PK": {"S": "TEST#001"}, "SK": {"S": "METADATA"}}'

# Clean up test data
aws dynamodb delete-item \
  --table-name $TABLE_NAME \
  --key '{"PK": {"S": "TEST#001"}, "SK": {"S": "METADATA"}}'
```

### 3. Test Lambda Functions

```bash
# List Lambda functions
aws lambda list-functions \
  --query 'Functions[?starts_with(FunctionName, `duemate`)].FunctionName' \
  --output table

# Invoke a Lambda function
aws lambda invoke \
  --function-name duemate-dev-invoice-create \
  --payload '{"test": true}' \
  response.json

# View response
cat response.json

# Check CloudWatch logs
aws logs tail /aws/lambda/duemate-dev-invoice-create --follow
```

### 4. Test API Gateway

```bash
# Get API endpoint
API_ENDPOINT=$(terraform output -raw api_gateway_endpoint)

# Test OPTIONS request (CORS)
curl -X OPTIONS $API_ENDPOINT/api \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -i

# Expected: 200 OK with CORS headers

# Test health check (after deploying Lambda code)
curl $API_ENDPOINT/api/health

# Test authenticated endpoint (requires token)
# First, create a test user in Cognito
```

### 5. Test S3 Buckets

```bash
# List S3 buckets
aws s3 ls | grep duemate

# Upload test file to frontend bucket
FRONTEND_BUCKET=$(terraform output -raw frontend_bucket_name)
echo "Test" > test.txt
aws s3 cp test.txt s3://$FRONTEND_BUCKET/test.txt

# Verify upload
aws s3 ls s3://$FRONTEND_BUCKET/

# Download to verify
aws s3 cp s3://$FRONTEND_BUCKET/test.txt downloaded.txt
cat downloaded.txt

# Clean up
aws s3 rm s3://$FRONTEND_BUCKET/test.txt
rm test.txt downloaded.txt
```

### 6. Test CloudFront Distribution

```bash
# Get CloudFront URL
CLOUDFRONT_URL=$(terraform output -raw frontend_url)

# Test access
curl -I $CLOUDFRONT_URL

# Expected: 200 OK or 403 (if no index.html yet)

# Get distribution ID
DISTRIBUTION_ID=$(terraform output -raw cloudfront_distribution_id)

# Check distribution status
aws cloudfront get-distribution --id $DISTRIBUTION_ID \
  --query 'Distribution.Status' \
  --output text

# Expected: "Deployed"
```

### 7. Test Cognito User Pool

```bash
# Get user pool ID
USER_POOL_ID=$(terraform output -raw cognito_user_pool_id)

# Create test user
aws cognito-idp admin-create-user \
  --user-pool-id $USER_POOL_ID \
  --username testuser@example.com \
  --user-attributes Name=email,Value=testuser@example.com Name=email_verified,Value=true \
  --temporary-password TempPass123!

# Set permanent password
aws cognito-idp admin-set-user-password \
  --user-pool-id $USER_POOL_ID \
  --username testuser@example.com \
  --password SecurePass123! \
  --permanent

# List users
aws cognito-idp list-users \
  --user-pool-id $USER_POOL_ID

# Delete test user
aws cognito-idp admin-delete-user \
  --user-pool-id $USER_POOL_ID \
  --username testuser@example.com
```

### 8. Test SQS Queues

```bash
# Get queue URL
QUEUE_URL=$(terraform output -raw notification_queue_url)

# Send test message
aws sqs send-message \
  --queue-url $QUEUE_URL \
  --message-body "Test notification message"

# Receive message
aws sqs receive-message \
  --queue-url $QUEUE_URL

# Purge queue (clean up)
aws sqs purge-queue --queue-url $QUEUE_URL
```

### 9. Test EventBridge Rules

```bash
# List EventBridge rules
aws events list-rules \
  --name-prefix duemate

# Describe specific rule
aws events describe-rule \
  --name duemate-dev-reminder-check

# List targets for rule
aws events list-targets-by-rule \
  --rule duemate-dev-reminder-check

# Manually trigger rule (for testing)
aws events put-events \
  --entries '[{
    "Source": "test",
    "DetailType": "test",
    "Detail": "{\"test\": true}"
  }]'
```

### 10. Test CloudWatch Monitoring

```bash
# View dashboard
DASHBOARD_NAME=$(terraform output -raw cloudwatch_dashboard_name)
echo "View dashboard at:"
echo "https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=$DASHBOARD_NAME"

# List alarms
aws cloudwatch describe-alarms \
  --alarm-name-prefix duemate

# Check alarm state
aws cloudwatch describe-alarms \
  --alarm-names duemate-dev-lambda-errors \
  --query 'MetricAlarms[0].StateValue' \
  --output text
```

## Integration Testing

### End-to-End Invoice Flow Test

```bash
#!/bin/bash
# test-invoice-flow.sh

# Set variables
API_ENDPOINT=$(terraform output -raw api_gateway_endpoint)
TABLE_NAME=$(terraform output -raw dynamodb_table_name)

# 1. Create test tenant
echo "Creating test tenant..."
aws dynamodb put-item \
  --table-name $TABLE_NAME \
  --item '{
    "PK": {"S": "TENANT#test001"},
    "SK": {"S": "METADATA"},
    "name": {"S": "Test Company"},
    "plan": {"S": "professional"}
  }'

# 2. Create test invoice
echo "Creating test invoice..."
aws dynamodb put-item \
  --table-name $TABLE_NAME \
  --item '{
    "PK": {"S": "TENANT#test001"},
    "SK": {"S": "INVOICE#inv001"},
    "invoiceId": {"S": "inv001"},
    "amount": {"N": "1000"},
    "status": {"S": "pending"},
    "dueDate": {"S": "2025-12-31"}
  }'

# 3. Verify invoice creation
echo "Verifying invoice..."
aws dynamodb get-item \
  --table-name $TABLE_NAME \
  --key '{"PK": {"S": "TENANT#test001"}, "SK": {"S": "INVOICE#inv001"}}'

# 4. Clean up
echo "Cleaning up..."
aws dynamodb delete-item \
  --table-name $TABLE_NAME \
  --key '{"PK": {"S": "TENANT#test001"}, "SK": {"S": "INVOICE#inv001"}}'

aws dynamodb delete-item \
  --table-name $TABLE_NAME \
  --key '{"PK": {"S": "TENANT#test001"}, "SK": {"S": "METADATA"}}'

echo "Test complete!"
```

Run the test:
```bash
chmod +x test-invoice-flow.sh
./test-invoice-flow.sh
```

## Performance Testing

### Load Test Lambda Functions

```bash
# Install artillery (load testing tool)
npm install -g artillery

# Create load test configuration
cat > lambda-load-test.yml << EOF
config:
  target: "https://$(terraform output -raw api_gateway_endpoint)"
  phases:
    - duration: 60
      arrivalRate: 10
scenarios:
  - name: "Health Check"
    flow:
      - get:
          url: "/api/health"
EOF

# Run load test
artillery run lambda-load-test.yml
```

### Monitor During Load Test

```bash
# Watch Lambda metrics
watch -n 5 'aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Invocations \
  --dimensions Name=FunctionName,Value=duemate-dev-invoice-create \
  --statistics Sum \
  --start-time $(date -u -d "5 minutes ago" +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 60'
```

## Disaster Recovery Testing

### Backup and Restore DynamoDB

```bash
# Create backup
aws dynamodb create-backup \
  --table-name $(terraform output -raw dynamodb_table_name) \
  --backup-name duemate-test-backup-$(date +%Y%m%d)

# List backups
aws dynamodb list-backups \
  --table-name $(terraform output -raw dynamodb_table_name)

# Restore from backup (to new table)
BACKUP_ARN=$(aws dynamodb list-backups \
  --table-name $(terraform output -raw dynamodb_table_name) \
  --query 'BackupSummaries[0].BackupArn' \
  --output text)

aws dynamodb restore-table-from-backup \
  --target-table-name duemate-dev-main-restored \
  --backup-arn $BACKUP_ARN
```

### Test State Recovery

```bash
# Backup current state
terraform state pull > terraform-backup-$(date +%Y%m%d).tfstate

# Test state restore (dry-run)
terraform plan

# If state lost, restore from backup
# terraform state push terraform-backup-YYYYMMDD.tfstate
```

## Cost Validation

### Estimate Monthly Costs

```bash
# Use AWS Cost Explorer API
aws ce get-cost-forecast \
  --time-period Start=$(date +%Y-%m-01),End=$(date -d "1 month" +%Y-%m-01) \
  --metric BLENDED_COST \
  --granularity MONTHLY

# View current month costs by service
aws ce get-cost-and-usage \
  --time-period Start=$(date +%Y-%m-01),End=$(date +%Y-%m-%d) \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --group-by Type=DIMENSION,Key=SERVICE
```

## Cleanup After Testing

```bash
# Remove all test resources
terraform destroy -auto-approve

# Verify cleanup
aws dynamodb list-tables --query 'TableNames[?starts_with(@, `duemate`)]'
aws s3 ls | grep duemate
aws lambda list-functions --query 'Functions[?starts_with(FunctionName, `duemate`)].FunctionName'
```

## Automated Testing Script

```bash
#!/bin/bash
# automated-test.sh

set -e

echo "=== Starting Terraform Deployment Tests ==="

# 1. Validate configuration
echo "1. Validating configuration..."
terraform validate
echo "✓ Configuration valid"

# 2. Check formatting
echo "2. Checking formatting..."
terraform fmt -check -recursive
echo "✓ Formatting correct"

# 3. Generate plan
echo "3. Generating plan..."
terraform plan -out=tfplan
echo "✓ Plan generated"

# 4. Apply (if approved)
read -p "Apply changes? (yes/no): " APPLY
if [ "$APPLY" = "yes" ]; then
  terraform apply tfplan
  echo "✓ Applied successfully"
  
  # 5. Run post-deployment tests
  echo "5. Running post-deployment tests..."
  
  # Test DynamoDB
  TABLE_NAME=$(terraform output -raw dynamodb_table_name)
  aws dynamodb describe-table --table-name $TABLE_NAME > /dev/null
  echo "  ✓ DynamoDB accessible"
  
  # Test Lambda
  aws lambda list-functions --query 'Functions[?starts_with(FunctionName, `duemate`)].FunctionName' > /dev/null
  echo "  ✓ Lambda functions deployed"
  
  # Test S3
  BUCKET=$(terraform output -raw frontend_bucket_name)
  aws s3 ls s3://$BUCKET > /dev/null
  echo "  ✓ S3 buckets accessible"
  
  echo "✓ All tests passed!"
else
  echo "✗ Deployment cancelled"
fi
```

## Test Checklist

- [ ] Configuration validated
- [ ] Security scan completed
- [ ] Plan reviewed
- [ ] Applied successfully
- [ ] DynamoDB table accessible
- [ ] Lambda functions deployed
- [ ] API Gateway responding
- [ ] S3 buckets created
- [ ] CloudFront distributing
- [ ] Cognito user pool configured
- [ ] SQS queues operational
- [ ] EventBridge rules scheduled
- [ ] CloudWatch monitoring active
- [ ] All outputs retrieved
- [ ] Documentation reviewed
- [ ] Costs estimated

---

**Last Updated:** 2025-10-27
