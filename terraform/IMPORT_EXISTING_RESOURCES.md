# Importing Existing AWS Resources into Terraform

This guide explains how existing AWS resources are automatically imported into Terraform state to prevent "EntityAlreadyExists" or "ResourceAlreadyExists" errors during deployment.

## Problem

When deploying with Terraform, you may encounter errors like:

```
Error: creating IAM Role (duemate-production-lambda-execution): EntityAlreadyExists: Role with name duemate-production-lambda-execution already exists.
Error: creating S3 Bucket (duemate-production-frontend): BucketAlreadyExists
Error: creating DynamoDB Table (duemate-production-main): ResourceInUseException: Table already exists
```

These errors occur when:
1. Resources were created manually or by another process
2. Terraform state was lost or corrupted
3. Resources exist from a previous deployment

## Automatic Import Solution (Recommended)

**This repository includes automatic import configuration for existing resources!**

The `terraform/import.tf.example` file contains import blocks that can automatically import existing resources during `terraform plan` or `terraform apply`. This is supported in Terraform 1.5.0+ (this repository requires 1.5.0+).

### ⚠️ Important: Import File is Disabled by Default

The import file is named `import.tf.example` (disabled) by default to prevent deployment failures on new/clean environments. 

**For NEW deployments**: Do nothing. Terraform will create all resources from scratch.

**For EXISTING infrastructure**: Rename `import.tf.example` to `import.tf` before running terraform commands.

### How It Works

**When import.tf is enabled (renamed from .example):**

1. When you run `terraform plan` or `terraform apply`, Terraform checks each import block
2. If the resource exists in AWS but not in the state file, it imports it automatically
3. If the resource doesn't exist in AWS, **the import will FAIL with an error**
4. If the resource is already in state, the import block is skipped

**Important**: Import blocks will cause deployment failures if resources don't exist in AWS. This is why the file is disabled by default.

### Enabling Automatic Import

Only enable automatic import if you have existing resources to import:

```bash
cd terraform
# Rename the file to enable import blocks
mv import.tf.example import.tf

# Now run terraform
terraform init
terraform plan
terraform apply

# After successful import, disable again (optional but recommended)
mv import.tf import.tf.example
```

### Covered Resources

The following resources are automatically imported when import.tf is enabled:
- IAM Role: `lambda_execution`
- IAM Policies: `lambda_dynamodb`, `lambda_s3`, `lambda_sqs`, `lambda_ses`, `lambda_secrets`
- IAM Role: `api_gateway_cloudwatch` (conditional)
- CloudWatch Log Group: API Gateway (conditional)
- Cognito User Pool Domain
- DynamoDB Table
- S3 Buckets: `frontend`, `invoices`, `assets`
- Lambda Functions: `invoice_create`, `invoice_get`, `reminder_check`, `notification_worker`
- CloudWatch Log Groups: for all Lambda functions
- EventBridge Rule: `reminder_check`
- EventBridge Target: `reminder_check`
- Lambda Permission: `allow_eventbridge` (EventBridge to invoke reminder Lambda)

## Manual Import (Alternative Method)

If you need to import resources manually or the automatic import doesn't work, you have these options:

### Option 1: Use the Import Script

A bash script is provided for manual imports:

```bash
cd terraform
chmod +x import-resources.sh
./import-resources.sh production duemate
```

This script will import all resources that exist in AWS but are not in the Terraform state.

### Option 2: Manual Terraform Import Commands

For each resource that already exists, run the import command:

#### Get Your AWS Account ID

```bash
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "Account ID: $AWS_ACCOUNT_ID"
```

#### Import IAM Resources

```bash
# IAM Role
terraform import aws_iam_role.lambda_execution duemate-production-lambda-execution

# IAM Policies (replace ACCOUNT_ID with your actual account ID)
terraform import aws_iam_policy.lambda_sqs arn:aws:iam::${AWS_ACCOUNT_ID}:policy/duemate-production-lambda-sqs
terraform import aws_iam_policy.lambda_ses arn:aws:iam::${AWS_ACCOUNT_ID}:policy/duemate-production-lambda-ses
terraform import aws_iam_policy.lambda_secrets arn:aws:iam::${AWS_ACCOUNT_ID}:policy/duemate-production-lambda-secrets
```

#### Import CloudWatch Log Group

```bash
terraform import 'module.api_gateway.aws_cloudwatch_log_group.api_gateway[0]' /aws/apigateway/duemate-production-api
```

#### Import Cognito Resources

```bash
terraform import module.cognito.aws_cognito_user_pool_domain.main duemate-production-users
```

#### Import DynamoDB Table

```bash
terraform import module.dynamodb.aws_dynamodb_table.main duemate-production-main
```

#### Import S3 Buckets

```bash
terraform import module.s3.aws_s3_bucket.frontend duemate-production-frontend
terraform import module.s3.aws_s3_bucket.invoices duemate-production-invoices
terraform import module.s3.aws_s3_bucket.assets duemate-production-assets
```

#### Import Lambda Functions

```bash
terraform import module.lambda_functions.aws_lambda_function.invoice_create duemate-production-invoice-create
terraform import module.lambda_functions.aws_lambda_function.invoice_get duemate-production-invoice-get
terraform import module.lambda_functions.aws_lambda_function.reminder_check duemate-production-reminder-check
terraform import module.lambda_functions.aws_lambda_function.notification_worker duemate-production-notification-worker
```

#### Import CloudWatch Log Groups for Lambda

```bash
terraform import module.lambda_functions.aws_cloudwatch_log_group.invoice_create /aws/lambda/duemate-production-invoice-create
terraform import module.lambda_functions.aws_cloudwatch_log_group.invoice_get /aws/lambda/duemate-production-invoice-get
terraform import module.lambda_functions.aws_cloudwatch_log_group.reminder_check /aws/lambda/duemate-production-reminder-check
terraform import module.lambda_functions.aws_cloudwatch_log_group.notification_worker /aws/lambda/duemate-production-notification-worker
```

#### Import EventBridge Resources

```bash
# EventBridge Rule
terraform import module.eventbridge.aws_cloudwatch_event_rule.reminder_check duemate-production-reminder-check

# EventBridge Target (format: rule-name/target-id)
terraform import module.eventbridge.aws_cloudwatch_event_target.reminder_check duemate-production-reminder-check/ReminderCheckLambda

# Lambda Permission (format: function-name/statement-id)
terraform import module.eventbridge.aws_lambda_permission.allow_eventbridge duemate-production-reminder-check/duemate-production-AllowExecutionFromEventBridge
```

### Option 3: Use Data Sources

Instead of managing existing resources, reference them using data sources. This is useful if you don't want Terraform to manage these resources.

Create a `data.tf` file:

```hcl
# Use existing IAM role instead of creating
data "aws_iam_role" "lambda_execution_existing" {
  name = "${local.name_prefix}-lambda-execution"
}

# Use existing S3 buckets
data "aws_s3_bucket" "frontend_existing" {
  bucket = "${local.name_prefix}-frontend"
}
```

Then update references in your code to use the data source instead of the resource.

### Option 4: Destroy and Recreate (NOT RECOMMENDED for Production)

**WARNING**: This will delete all data in the resources!

```bash
# Only for development/testing environments
aws s3 rb s3://duemate-dev-frontend --force
aws s3 rb s3://duemate-dev-invoices --force
aws s3 rb s3://duemate-dev-assets --force
aws dynamodb delete-table --table-name duemate-dev-main
# ... delete other resources
```

## Automated Import Script

Create a script `terraform/import-resources.sh`:

```bash
#!/bin/bash
set -e

ENVIRONMENT=${1:-production}
PROJECT_NAME=${2:-duemate}

echo "Importing resources for environment: $ENVIRONMENT"

# Get AWS Account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "AWS Account ID: $AWS_ACCOUNT_ID"

# Set name prefix
NAME_PREFIX="${PROJECT_NAME}-${ENVIRONMENT}"

# Import IAM Role
echo "Importing IAM Role..."
terraform import aws_iam_role.lambda_execution "${NAME_PREFIX}-lambda-execution" || true

# Import IAM Policies
echo "Importing IAM Policies..."
terraform import aws_iam_policy.lambda_sqs "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${NAME_PREFIX}-lambda-sqs" || true
terraform import aws_iam_policy.lambda_ses "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${NAME_PREFIX}-lambda-ses" || true
terraform import aws_iam_policy.lambda_secrets "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${NAME_PREFIX}-lambda-secrets" || true

# Import CloudWatch Log Group
echo "Importing CloudWatch Log Group..."
terraform import 'module.api_gateway.aws_cloudwatch_log_group.api_gateway[0]' "/aws/apigateway/${NAME_PREFIX}-api" || true

# Import Cognito User Pool Domain
echo "Importing Cognito User Pool Domain..."
terraform import module.cognito.aws_cognito_user_pool_domain.main "${NAME_PREFIX}-users" || true

# Import DynamoDB Table
echo "Importing DynamoDB Table..."
terraform import module.dynamodb.aws_dynamodb_table.main "${NAME_PREFIX}-main" || true

# Import S3 Buckets
echo "Importing S3 Buckets..."
terraform import module.s3.aws_s3_bucket.frontend "${NAME_PREFIX}-frontend" || true
terraform import module.s3.aws_s3_bucket.invoices "${NAME_PREFIX}-invoices" || true
terraform import module.s3.aws_s3_bucket.assets "${NAME_PREFIX}-assets" || true

# Import Lambda Functions
echo "Importing Lambda Functions..."
terraform import module.lambda_functions.aws_lambda_function.invoice_create "${NAME_PREFIX}-invoice-create" || true
terraform import module.lambda_functions.aws_lambda_function.invoice_get "${NAME_PREFIX}-invoice-get" || true
terraform import module.lambda_functions.aws_lambda_function.reminder_check "${NAME_PREFIX}-reminder-check" || true
terraform import module.lambda_functions.aws_lambda_function.notification_worker "${NAME_PREFIX}-notification-worker" || true

# Import CloudWatch Log Groups for Lambda
echo "Importing CloudWatch Log Groups for Lambda..."
terraform import module.lambda_functions.aws_cloudwatch_log_group.invoice_create "/aws/lambda/${NAME_PREFIX}-invoice-create" || true
terraform import module.lambda_functions.aws_cloudwatch_log_group.invoice_get "/aws/lambda/${NAME_PREFIX}-invoice-get" || true
terraform import module.lambda_functions.aws_cloudwatch_log_group.reminder_check "/aws/lambda/${NAME_PREFIX}-reminder-check" || true
terraform import module.lambda_functions.aws_cloudwatch_log_group.notification_worker "/aws/lambda/${NAME_PREFIX}-notification-worker" || true

echo "Import complete! Run 'terraform plan' to verify."
```

Make it executable:

```bash
chmod +x terraform/import-resources.sh
```

Run it:

```bash
cd terraform
./import-resources.sh production duemate
```

## Preventing Future Issues

### 1. Use Remote State Backend

Configure S3 backend for state storage:

```hcl
terraform {
  backend "s3" {
    bucket         = "duemate-terraform-state"
    key            = "production/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "duemate-terraform-locks"
    encrypt        = true
  }
}
```

### 2. Add Lifecycle Rules

Lifecycle rules have been added to critical resources to prevent accidental recreation:

```hcl
lifecycle {
  ignore_changes = [name]
}
```

### 3. Use Workspaces

```bash
terraform workspace new production
terraform workspace select production
```

### 4. Regular State Backups

```bash
terraform state pull > backup-$(date +%Y%m%d-%H%M%S).tfstate
```

## Troubleshooting

### Error: Resource Not Found During Import

If import fails with "not found", verify the resource exists:

```bash
# Check IAM role
aws iam get-role --role-name duemate-production-lambda-execution

# Check S3 bucket
aws s3 ls s3://duemate-production-frontend

# Check DynamoDB table
aws dynamodb describe-table --table-name duemate-production-main
```

### Error: Resource Already in State

If the resource is already in state:

```bash
# Remove from state
terraform state rm aws_iam_role.lambda_execution

# Then import again
terraform import aws_iam_role.lambda_execution duemate-production-lambda-execution
```

### Error: Incorrect Resource ID

Check Terraform documentation for the correct import ID format:
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs

### Automatic Import Not Working

If the automatic import blocks in `import.tf` are not working:

1. Ensure you're using Terraform 1.5.0 or later:
   ```bash
   terraform version
   ```

2. Check that the resource names in `import.tf` match your configuration

3. Try running with verbose logging:
   ```bash
   TF_LOG=DEBUG terraform plan
   ```

4. Fall back to manual import using the script or commands above

## References

- [Terraform Import Documentation](https://developer.hashicorp.com/terraform/cli/import)
- [Terraform Import Blocks (1.5+)](https://developer.hashicorp.com/terraform/language/import)
- [AWS Provider Import Guide](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform State Management](https://developer.hashicorp.com/terraform/language/state)
