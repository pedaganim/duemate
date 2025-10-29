# Importing Existing AWS Resources into Terraform

This guide explains how to import existing AWS resources into Terraform state when you encounter "EntityAlreadyExists" or "ResourceAlreadyExists" errors during deployment.

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

## Solution

### Option 1: Import Resources (Terraform 1.5+)

For Terraform 1.5 and later, you can use import blocks:

#### 1. Create Import Configuration

Create a file `terraform/import.tf`:

```hcl
# Import IAM Role
import {
  to = aws_iam_role.lambda_execution
  id = "duemate-production-lambda-execution"
}

# Import IAM Policies
import {
  to = aws_iam_policy.lambda_sqs
  id = "arn:aws:iam::ACCOUNT_ID:policy/duemate-production-lambda-sqs"
}

import {
  to = aws_iam_policy.lambda_ses
  id = "arn:aws:iam::ACCOUNT_ID:policy/duemate-production-lambda-ses"
}

import {
  to = aws_iam_policy.lambda_secrets
  id = "arn:aws:iam::ACCOUNT_ID:policy/duemate-production-lambda-secrets"
}

# Import CloudWatch Log Group
import {
  to = module.api_gateway.aws_cloudwatch_log_group.api_gateway[0]
  id = "/aws/apigateway/duemate-production-api"
}

# Import Cognito User Pool Domain
import {
  to = module.cognito.aws_cognito_user_pool_domain.main
  id = "duemate-production-users"
}

# Import DynamoDB Table
import {
  to = module.dynamodb.aws_dynamodb_table.main
  id = "duemate-production-main"
}

# Import S3 Buckets
import {
  to = module.s3.aws_s3_bucket.frontend
  id = "duemate-production-frontend"
}

import {
  to = module.s3.aws_s3_bucket.invoices
  id = "duemate-production-invoices"
}

import {
  to = module.s3.aws_s3_bucket.assets
  id = "duemate-production-assets"
}
```

#### 2. Run Terraform Plan with Import

```bash
cd terraform
terraform plan -generate-config-out=generated.tf
terraform apply
```

### Option 2: Manual Import (All Terraform Versions)

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

## References

- [Terraform Import Documentation](https://developer.hashicorp.com/terraform/cli/import)
- [AWS Provider Import Guide](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform State Management](https://developer.hashicorp.com/terraform/language/state)
