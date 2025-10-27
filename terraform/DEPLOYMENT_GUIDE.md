# DueMate Terraform Deployment Guide

This guide provides step-by-step instructions for deploying the DueMate application infrastructure using Terraform.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Deployment Steps](#deployment-steps)
4. [Post-Deployment Configuration](#post-deployment-configuration)
5. [Deploying Application Code](#deploying-application-code)
6. [Verification](#verification)
7. [Updating Infrastructure](#updating-infrastructure)
8. [Troubleshooting](#troubleshooting)
9. [Destroying Infrastructure](#destroying-infrastructure)

## Prerequisites

### Required Tools

1. **AWS Account**
   - Active AWS account with administrative access
   - AWS credentials configured

2. **Terraform**
   ```bash
   # Install Terraform (version 1.5+)
   # macOS
   brew install terraform

   # Linux
   wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
   unzip terraform_1.6.0_linux_amd64.zip
   sudo mv terraform /usr/local/bin/

   # Verify installation
   terraform --version
   ```

3. **AWS CLI**
   ```bash
   # Install AWS CLI
   # macOS
   brew install awscli

   # Linux
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   unzip awscliv2.zip
   sudo ./aws/install

   # Verify installation
   aws --version
   ```

4. **Git**
   ```bash
   git --version
   ```

### AWS Account Setup

1. **Configure AWS Credentials**
   ```bash
   aws configure
   ```
   
   Enter your:
   - AWS Access Key ID
   - AWS Secret Access Key
   - Default region (e.g., us-east-1)
   - Default output format (json)

2. **Verify AWS Access**
   ```bash
   aws sts get-caller-identity
   ```

## Initial Setup

### 1. Clone Repository

```bash
git clone https://github.com/pedaganim/duemate.git
cd duemate/terraform
```

### 2. Configure Variables

Create a `terraform.tfvars` file from the example:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your preferred editor:

```bash
nano terraform.tfvars
# or
vim terraform.tfvars
```

**Minimum Required Configuration:**

```hcl
# Project Configuration
project_name = "duemate"
environment  = "dev"  # or "staging" or "production"
aws_region   = "us-east-1"

# Enable monitoring
enable_monitoring = true
```

**Optional Configuration:**

```hcl
# For whitelabel/multi-tenant deployments
customer_name = "acmecorp"
custom_domain = "invoices.acmecorp.com"

# Email for CloudWatch alarms
alarm_email = "devops@yourcompany.com"

# Third-party integrations (store securely)
# stripe_api_key = "sk_test_..."
# twilio_account_sid = "AC..."
# twilio_auth_token = "..."
```

### 3. Backend Configuration (Optional but Recommended)

For production deployments, configure remote state storage:

**Create S3 Backend Resources:**

```bash
# Create S3 bucket for Terraform state
aws s3 mb s3://duemate-terraform-state --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket duemate-terraform-state \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name duemate-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

**Update `versions.tf`:**

Uncomment the backend configuration in `versions.tf`:

```hcl
backend "s3" {
  bucket         = "duemate-terraform-state"
  key            = "terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
  dynamodb_table = "duemate-terraform-locks"
}
```

## Deployment Steps

### Step 1: Initialize Terraform

Initialize the Terraform working directory:

```bash
terraform init
```

This will:
- Download required provider plugins (AWS, Random)
- Set up the backend (if configured)
- Initialize modules

Expected output:
```
Terraform has been successfully initialized!
```

### Step 2: Validate Configuration

Validate the Terraform configuration:

```bash
terraform validate
```

Expected output:
```
Success! The configuration is valid.
```

### Step 3: Format Code (Optional)

Format Terraform files for consistency:

```bash
terraform fmt -recursive
```

### Step 4: Plan Deployment

Preview the infrastructure changes:

```bash
terraform plan
```

This will show:
- Resources to be created
- Resource configurations
- Estimated changes

Review the plan carefully. You should see approximately 40-50 resources to be created.

**Save the plan (optional):**

```bash
terraform plan -out=tfplan
```

### Step 5: Deploy Infrastructure

Apply the Terraform configuration:

```bash
terraform apply
```

Or, if you saved a plan:

```bash
terraform apply tfplan
```

**Confirmation:**
- Review the execution plan
- Type `yes` when prompted to confirm

**Deployment Time:** ~5-10 minutes

**Watch for:**
- Resource creation progress
- Any errors or warnings
- Final output values

### Step 6: Save Outputs

After successful deployment, save the outputs:

```bash
terraform output > outputs.txt
```

Or view specific outputs:

```bash
terraform output api_gateway_endpoint
terraform output frontend_url
terraform output cognito_user_pool_id
```

## Post-Deployment Configuration

### 1. Verify SES Email

If you plan to send emails, verify your sender email address in SES:

```bash
aws ses verify-email-identity --email-address noreply@yourcompany.com
```

Check your email and click the verification link.

### 2. Configure Custom Domain (Optional)

If using a custom domain:

**For CloudFront:**
1. Request ACM certificate in us-east-1
2. Add DNS validation records
3. Update CloudFront distribution with certificate

**For API Gateway:**
1. Create custom domain in API Gateway
2. Map to your stage
3. Add DNS record pointing to API Gateway endpoint

### 3. Store Sensitive Information

Store third-party API keys in Secrets Manager:

```bash
# Stripe
aws secretsmanager create-secret \
  --name duemate-dev/stripe \
  --secret-string '{"api_key":"sk_test_..."}'

# Twilio
aws secretsmanager create-secret \
  --name duemate-dev/twilio \
  --secret-string '{"account_sid":"AC...","auth_token":"..."}'

# Plaid
aws secretsmanager create-secret \
  --name duemate-dev/plaid \
  --secret-string '{"client_id":"...","secret":"..."}'
```

## Deploying Application Code

The Terraform deployment creates placeholder Lambda functions. You need to deploy actual application code.

### Option 1: Manual Deployment

Package and deploy Lambda functions:

```bash
# Package function
cd ../lambda/invoice-create
npm install
zip -r function.zip .

# Update Lambda function
aws lambda update-function-code \
  --function-name duemate-dev-invoice-create \
  --zip-file fileb://function.zip
```

### Option 2: CI/CD Pipeline

Set up GitHub Actions or similar for automated deployments:

```yaml
# .github/workflows/deploy.yml
name: Deploy Lambda Functions

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-region: us-east-1
      - name: Deploy Functions
        run: |
          # Deploy each Lambda function
          ./scripts/deploy-lambda.sh
```

### Frontend Deployment

Deploy the frontend to S3:

```bash
# Build frontend
cd ../frontend
npm install
npm run build

# Sync to S3
aws s3 sync dist/ s3://duemate-dev-frontend/ --delete

# Invalidate CloudFront cache
DISTRIBUTION_ID=$(terraform output -raw cloudfront_distribution_id)
aws cloudfront create-invalidation \
  --distribution-id $DISTRIBUTION_ID \
  --paths "/*"
```

## Verification

### 1. Check Resource Creation

Verify all resources were created:

```bash
# List Lambda functions
aws lambda list-functions --query 'Functions[?starts_with(FunctionName, `duemate-dev`)].FunctionName'

# Check DynamoDB table
aws dynamodb describe-table --table-name duemate-dev-main

# Verify S3 buckets
aws s3 ls | grep duemate-dev

# Check API Gateway
aws apigateway get-rest-apis --query 'items[?name==`duemate-dev-api`]'
```

### 2. Test API Endpoint

```bash
API_ENDPOINT=$(terraform output -raw api_gateway_endpoint)

# Test OPTIONS (CORS)
curl -X OPTIONS $API_ENDPOINT/api

# Test health check (after deploying code)
curl $API_ENDPOINT/api/health
```

### 3. Test Frontend

```bash
FRONTEND_URL=$(terraform output -raw frontend_url)
echo "Visit: $FRONTEND_URL"

# Or open in browser
open $FRONTEND_URL
```

### 4. Check CloudWatch Logs

```bash
# View Lambda logs
aws logs tail /aws/lambda/duemate-dev-invoice-create --follow

# View API Gateway logs
aws logs tail /aws/apigateway/duemate-dev-api --follow
```

### 5. Monitor Dashboard

View the CloudWatch dashboard:

```bash
DASHBOARD_NAME=$(terraform output -raw cloudwatch_dashboard_name)
echo "Dashboard: https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=$DASHBOARD_NAME"
```

## Updating Infrastructure

### Making Changes

1. **Edit Configuration**
   ```bash
   # Edit variables or main configuration
   vim terraform.tfvars
   ```

2. **Plan Changes**
   ```bash
   terraform plan
   ```

3. **Apply Changes**
   ```bash
   terraform apply
   ```

### Adding Resources

To add new Lambda functions or resources:

1. Edit module files in `modules/lambda/`
2. Update outputs if needed
3. Run `terraform plan` and `terraform apply`

### Scaling

To change Lambda memory or DynamoDB capacity:

```hcl
# terraform.tfvars
lambda_memory_size     = 1024  # Increase from 512
dynamodb_billing_mode  = "PROVISIONED"
dynamodb_read_capacity = 10
```

Apply changes:
```bash
terraform apply
```

## Troubleshooting

### Common Issues

**Issue: "Error acquiring state lock"**
```bash
# Force unlock (use carefully)
terraform force-unlock <LOCK_ID>
```

**Issue: "Error creating DynamoDB Table: ResourceInUseException"**
```bash
# Import existing table
terraform import module.dynamodb.aws_dynamodb_table.main duemate-dev-main
```

**Issue: "NoSuchBucket" during state operations**
```bash
# Recreate backend bucket
aws s3 mb s3://duemate-terraform-state
```

**Issue: Lambda function not updating**
```bash
# Check function exists
aws lambda get-function --function-name duemate-dev-invoice-create

# Force update
terraform taint module.lambda_functions.aws_lambda_function.invoice_create
terraform apply
```

### Debug Commands

Enable detailed logging:
```bash
export TF_LOG=DEBUG
terraform apply
```

View state:
```bash
terraform state list
terraform state show <resource>
```

Refresh state:
```bash
terraform refresh
```

## Destroying Infrastructure

**Warning:** This will delete all resources and data. Use with extreme caution.

### Full Destruction

```bash
terraform destroy
```

Review the destruction plan and type `yes` to confirm.

### Selective Destruction

To destroy specific resources:

```bash
# Destroy specific module
terraform destroy -target=module.lambda_functions

# Destroy specific resource
terraform destroy -target=module.dynamodb.aws_dynamodb_table.main
```

### Pre-Destruction Checklist

Before destroying:

- [ ] Backup DynamoDB data
- [ ] Export S3 bucket contents
- [ ] Save important outputs
- [ ] Notify team members
- [ ] Verify you're in the correct environment

### Data Preservation

Back up data before destroying:

```bash
# Backup DynamoDB table
aws dynamodb create-backup \
  --table-name duemate-dev-main \
  --backup-name duemate-dev-backup-$(date +%Y%m%d)

# Download S3 bucket contents
aws s3 sync s3://duemate-dev-invoices ./backup/invoices/
aws s3 sync s3://duemate-dev-assets ./backup/assets/
```

## Environment-Specific Deployments

### Development Environment

```bash
cd environments/dev
terraform init
terraform apply
```

### Staging Environment

```bash
cd environments/staging
terraform init
terraform apply
```

### Production Environment

```bash
cd environments/production
terraform init
terraform apply -var="enable_monitoring=true" -var="alarm_email=ops@company.com"
```

## Best Practices

1. **Always run `terraform plan` before `apply`**
2. **Use workspaces or separate directories for environments**
3. **Store state remotely in S3**
4. **Enable state locking with DynamoDB**
5. **Tag all resources appropriately**
6. **Review security group rules**
7. **Enable CloudTrail for audit logging**
8. **Set up billing alerts**
9. **Document custom configurations**
10. **Regular state backups**

## Next Steps

After successful deployment:

1. Set up CI/CD pipeline for application code
2. Configure domain names and SSL certificates
3. Implement monitoring and alerting
4. Create runbooks for common operations
5. Set up disaster recovery procedures
6. Conduct security review
7. Performance testing
8. User acceptance testing

## Support

For issues or questions:
- Check Terraform documentation: https://www.terraform.io/docs
- AWS Provider docs: https://registry.terraform.io/providers/hashicorp/aws
- Project documentation: `terraform/README.md`
- System architecture: `docs/system-architecture.md`

---

**Last Updated:** 2025-10-27  
**Version:** 1.0
