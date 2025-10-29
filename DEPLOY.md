# DueMate Deployment Guide

This guide provides comprehensive instructions for deploying the DueMate application to AWS using our automated CI/CD workflow.

> **Note**: If you encounter "EntityAlreadyExists" or "ResourceAlreadyExists" errors during deployment, see the [Importing Existing Resources Guide](terraform/IMPORT_EXISTING_RESOURCES.md) for instructions on how to import existing AWS resources into Terraform state.

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Quick Start](#quick-start)
4. [GitHub Actions Workflow](#github-actions-workflow)
5. [Environment Configuration](#environment-configuration)
6. [Secrets Management](#secrets-management)
7. [Manual Deployment](#manual-deployment)
8. [Deployment Scripts](#deployment-scripts)
9. [Troubleshooting](#troubleshooting)
10. [Rollback Procedures](#rollback-procedures)

## Overview

DueMate uses a fully automated CI/CD pipeline powered by GitHub Actions to deploy to AWS. The deployment process includes:

- **Infrastructure as Code**: Terraform manages all AWS resources
- **Automated Builds**: TypeScript compilation and dependency management
- **Lambda Deployment**: Automated packaging and deployment of serverless functions
- **Database Migrations**: Automated Prisma migration execution
- **Frontend Deployment**: Static asset deployment to S3/CloudFront
- **Verification**: Post-deployment health checks and smoke tests

### Architecture

```
┌─────────────────┐
│  GitHub Actions │
│   CI/CD Pipeline│
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
┌───▼──┐  ┌──▼────┐
│Build │  │Deploy │
│& Test│  │Infra  │
└───┬──┘  └──┬────┘
    │        │
    │     ┌──▼─────────┐
    │     │ Terraform  │
    │     │ (AWS)      │
    │     └──┬─────────┘
    │        │
    └────┬───┴──────────┐
         │              │
    ┌────▼────┐    ┌───▼──────┐
    │ Lambda  │    │ Frontend │
    │Functions│    │   (S3)   │
    └─────────┘    └──────────┘
```

## Prerequisites

### Required Tools

1. **AWS Account**
   - Active AWS account with administrative access
   - Recommended: Use AWS Organizations for multi-environment setup

2. **GitHub Repository Access**
   - Write access to the repository
   - Ability to configure secrets and environments

3. **Local Development Tools** (for manual deployment)
   - Node.js v20.x or higher
   - Terraform v1.6.0 or higher
   - AWS CLI v2
   - Git

### AWS Resources Setup

Before the first deployment, ensure you have:

1. **AWS Access Keys**
   - Create an IAM user with programmatic access
   - Required permissions: Administrator (or custom policy with required permissions)

2. **Terraform State Backend** (recommended for production)
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

## Quick Start

### 1. Configure GitHub Secrets

Navigate to your repository settings and add the following secrets:

**Repository Secrets** (Settings → Secrets and variables → Actions → New repository secret):

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `AWS_ACCESS_KEY_ID` | AWS access key ID | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | AWS secret access key | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `AWS_REGION` | AWS region to deploy to | `us-east-1` |
| `TERRAFORM_STATE_BUCKET` | S3 bucket for Terraform state (optional) | `duemate-terraform-state` |

**Environment-Specific Secrets** (Settings → Environments → New environment):

Create three environments: `dev`, `staging`, `production`

For each environment, add:

| Secret Name | Description | Required |
|-------------|-------------|----------|
| `DATABASE_URL` | Database connection string | Yes |
| `AWS_REGION` | Region override (optional) | No |
| `S3_BUCKET_NAME` | Frontend S3 bucket (optional) | No |

### 2. Trigger Deployment

There are two ways to trigger a deployment:

#### Option A: Automatic Deployment (Push to Branch)

Push to specific branches to trigger automatic deployment:

```bash
# Deploy to development
git push origin develop

# Deploy to staging
git push origin staging

# Deploy to production
git push origin main
```

#### Option B: Manual Deployment (Workflow Dispatch)

1. Go to **Actions** tab in GitHub
2. Select **Deploy to AWS** workflow
3. Click **Run workflow**
4. Choose:
   - **Environment**: dev, staging, or production
   - **Terraform action**: plan, apply, or destroy
5. Click **Run workflow**

### 3. Monitor Deployment

1. Navigate to the **Actions** tab
2. Click on the running workflow
3. Monitor each job's progress:
   - ✓ Build and Test
   - ✓ Deploy Infrastructure
   - ✓ Deploy Application
   - ✓ Deploy Frontend
   - ✓ Verify Deployment

### 4. Access Deployed Application

After successful deployment, find the endpoints in:

1. **GitHub Actions Summary**: Check the "Deployment Summary" at the bottom of the workflow run
2. **Terraform Outputs**: 
   ```bash
   cd terraform
   terraform output
   ```

Example outputs:
- API Endpoint: `https://abc123.execute-api.us-east-1.amazonaws.com/prod`
- Frontend URL: `https://d111111abcdef8.cloudfront.net`

## GitHub Actions Workflow

### Workflow Structure

The `.github/workflows/deploy.yml` file defines the deployment pipeline:

```yaml
Jobs:
  1. determine-environment  # Decides which environment to deploy
  2. build-and-test        # Builds and tests the application
  3. deploy-infrastructure # Deploys AWS resources with Terraform
  4. deploy-application    # Deploys Lambda functions
  5. deploy-frontend       # Deploys frontend to S3 (if exists)
  6. verify-deployment     # Runs health checks
```

### Workflow Triggers

| Trigger | Environment | Action |
|---------|-------------|--------|
| Push to `main` | production | Deploy |
| Push to `staging` | staging | Deploy |
| Push to `develop` | dev | Deploy |
| Manual (workflow_dispatch) | User choice | User choice |

### Workflow Configuration

Key environment variables:

```yaml
env:
  NODE_VERSION: '20.x'
  TERRAFORM_VERSION: '1.6.0'
```

## Environment Configuration

### Development Environment

**Purpose**: Testing new features and bug fixes

**Configuration**:
- Environment: `dev`
- Branch: `develop`
- Auto-deploy: Yes
- Protection rules: None

**Resources**:
- Minimal Lambda memory (256MB)
- On-demand DynamoDB billing
- No CloudFront CDN
- Reduced log retention (7 days)

### Staging Environment

**Purpose**: Pre-production testing and QA

**Configuration**:
- Environment: `staging`
- Branch: `staging`
- Auto-deploy: Yes
- Protection rules: Required reviewers (recommended)

**Resources**:
- Standard Lambda memory (512MB)
- On-demand DynamoDB billing
- CloudFront CDN enabled
- Standard log retention (30 days)

### Production Environment

**Purpose**: Live production environment

**Configuration**:
- Environment: `production`
- Branch: `main`
- Auto-deploy: Yes
- Protection rules: **Required reviewers, wait timer**

**Resources**:
- Production Lambda memory (1024MB)
- Provisioned DynamoDB capacity (optional)
- CloudFront CDN with custom domain
- Extended log retention (90 days)
- Enhanced monitoring and alarms

## Secrets Management

### AWS Secrets Manager Integration

Store sensitive data in AWS Secrets Manager:

```bash
# Create secret for Stripe API keys
aws secretsmanager create-secret \
  --name duemate-production/stripe \
  --secret-string '{"api_key":"sk_live_..."}'

# Create secret for Twilio credentials
aws secretsmanager create-secret \
  --name duemate-production/twilio \
  --secret-string '{"account_sid":"AC...","auth_token":"..."}'

# Create secret for database URL
aws secretsmanager create-secret \
  --name duemate-production/database \
  --secret-string '{"url":"postgresql://..."}'
```

### Accessing Secrets in Lambda Functions

Lambda functions automatically have permission to read secrets with the pattern:
`duemate-{environment}/*`

Example code:

```typescript
import { SecretsManagerClient, GetSecretValueCommand } from '@aws-sdk/client-secrets-manager';

const client = new SecretsManagerClient({ region: process.env.AWS_REGION });

async function getSecret(secretName: string) {
  const command = new GetSecretValueCommand({ SecretId: secretName });
  const response = await client.send(command);
  return JSON.parse(response.SecretString!);
}

// Usage
const stripeConfig = await getSecret('duemate-production/stripe');
```

### Environment Variables

Environment variables are set automatically in Lambda functions:

| Variable | Description | Source |
|----------|-------------|--------|
| `TABLE_NAME` | DynamoDB table name | Terraform output |
| `USER_POOL_ID` | Cognito user pool ID | Terraform output |
| `INVOICES_BUCKET` | S3 bucket for invoices | Terraform output |
| `NOTIFICATION_QUEUE` | SQS queue URL | Terraform output |
| `AWS_REGION_NAME` | AWS region | Terraform variable |
| `ENVIRONMENT` | Environment name | Terraform variable |

## Manual Deployment

For situations where you need to deploy manually (e.g., troubleshooting, local testing):

### 1. Deploy Infrastructure

```bash
cd terraform

# Initialize Terraform
terraform init

# Review changes
terraform plan -var="environment=dev"

# Apply changes
terraform apply -var="environment=dev"

# Save outputs
terraform output > ../outputs.txt
```

### 2. Build Application

```bash
# Install dependencies
npm install

# Build TypeScript
npm run build
```

### 3. Deploy Lambda Functions

```bash
# Make script executable
chmod +x scripts/deploy-lambda.sh

# Deploy to dev environment
./scripts/deploy-lambda.sh dev
```

### 4. Run Database Migrations

```bash
# Set DATABASE_URL
export DATABASE_URL="your-database-url"

# Run migrations
chmod +x scripts/run-migrations.sh
./scripts/run-migrations.sh dev
```

### 5. Deploy Frontend (if applicable)

```bash
# Set S3 bucket name
export S3_BUCKET_NAME="duemate-dev-frontend"

# Deploy frontend
chmod +x scripts/deploy-frontend.sh
./scripts/deploy-frontend.sh dev
```

### 6. Verify Deployment

```bash
# Run verification script
chmod +x scripts/verify-deployment.sh
./scripts/verify-deployment.sh dev
```

## Deployment Scripts

### deploy-lambda.sh

**Purpose**: Package and deploy Lambda functions

**Usage**:
```bash
./scripts/deploy-lambda.sh <environment>
```

**What it does**:
1. Creates deployment package with dependencies
2. Zips the package
3. Updates Lambda function code
4. Publishes new version

**Functions deployed**:
- invoice-create, invoice-list, invoice-get, invoice-update, invoice-delete
- invoice-pdf
- client-create, client-list, client-get, client-update, client-delete
- reminder-create, reminder-check, reminder-send
- notification-worker

### deploy-frontend.sh

**Purpose**: Deploy frontend to S3 and invalidate CloudFront cache

**Usage**:
```bash
./scripts/deploy-frontend.sh <environment>
```

**What it does**:
1. Builds frontend application
2. Syncs files to S3 with appropriate cache headers
3. Creates CloudFront invalidation

### run-migrations.sh

**Purpose**: Execute database migrations

**Usage**:
```bash
export DATABASE_URL="your-database-url"
./scripts/run-migrations.sh <environment>
```

**What it does**:
1. Generates Prisma client
2. Runs pending migrations
3. Verifies migration success

### verify-deployment.sh

**Purpose**: Verify all deployed resources

**Usage**:
```bash
./scripts/verify-deployment.sh <environment>
```

**What it checks**:
- DynamoDB tables
- Lambda functions
- API Gateway
- S3 buckets
- Cognito user pools
- SQS queues
- CloudWatch log groups

## Troubleshooting

### Common Issues

#### 1. "Error: configuring Terraform AWS Provider: no valid credential sources"

**Cause**: AWS credentials not configured

**Solution**:
```bash
# Check GitHub secrets
# OR for local deployment:
aws configure
```

#### 2. Lambda function update fails

**Cause**: Function doesn't exist or incorrect name

**Solution**:
```bash
# List Lambda functions
aws lambda list-functions --query 'Functions[?starts_with(FunctionName, `duemate-dev`)].FunctionName'

# Verify function name format: duemate-{environment}-{function-name}
```

#### 3. Terraform state lock error

**Cause**: Another process holds the state lock

**Solution**:
```bash
# Force unlock (use carefully)
terraform force-unlock <LOCK_ID>
```

#### 4. Frontend deployment fails

**Cause**: S3 bucket doesn't exist or no frontend directory

**Solution**:
```bash
# Verify bucket exists
aws s3 ls s3://duemate-dev-frontend

# Check if frontend directory exists
ls -la frontend/
```

#### 5. Database migration fails

**Cause**: Invalid DATABASE_URL or connectivity issue

**Solution**:
```bash
# Test DynamoDB connection
aws dynamodb list-tables --region $AWS_REGION

# Verify DynamoDB configuration
echo "Table: $TABLE_NAME"
echo "Region: $AWS_REGION"
```

#### 6. "EntityAlreadyExists" or "ResourceAlreadyExists" errors

**Cause**: Resources already exist in AWS but are not in Terraform state

**Examples**:
- `Error: creating IAM Role (duemate-production-lambda-execution): EntityAlreadyExists`
- `Error: creating S3 Bucket (duemate-production-frontend): BucketAlreadyExists`
- `Error: creating DynamoDB Table: ResourceInUseException: Table already exists`

**Solution**:

Import existing resources into Terraform state:

```bash
cd terraform

# Option 1: Use the automated import script
./import-resources.sh production duemate

# Option 2: Manual import (see terraform/IMPORT_EXISTING_RESOURCES.md for details)
terraform import aws_iam_role.lambda_execution duemate-production-lambda-execution
terraform import module.s3.aws_s3_bucket.frontend duemate-production-frontend
# ... etc
```

For detailed instructions, see [terraform/IMPORT_EXISTING_RESOURCES.md](terraform/IMPORT_EXISTING_RESOURCES.md)

### Debug Commands

```bash
# Enable Terraform debug logging
export TF_LOG=DEBUG
terraform apply

# Test AWS credentials
aws sts get-caller-identity

# View Lambda logs
aws logs tail /aws/lambda/duemate-dev-invoice-create --follow

# Check API Gateway deployment
aws apigateway get-deployments --rest-api-id <API_ID>

# List S3 bucket contents
aws s3 ls s3://duemate-dev-frontend/ --recursive
```

### Getting Help

1. **Check workflow logs**: Actions tab → Select workflow run → Review job logs
2. **Review CloudWatch logs**: Check Lambda function logs for errors
3. **Verify resources**: Run `./scripts/verify-deployment.sh`
4. **Check Terraform state**: `terraform state list`
5. **AWS Console**: Verify resources exist in the AWS Console

## Rollback Procedures

### Automatic Rollback (Lambda)

Lambda functions support automatic rollback using aliases and versions:

```bash
# List function versions
aws lambda list-versions-by-function --function-name duemate-production-invoice-create

# Rollback to previous version
aws lambda update-alias \
  --function-name duemate-production-invoice-create \
  --name prod \
  --function-version 2
```

### Infrastructure Rollback

To rollback infrastructure changes:

```bash
# Option 1: Revert Terraform changes
cd terraform
git checkout HEAD~1 main.tf  # or specific file
terraform apply

# Option 2: Import previous state
terraform state pull > backup.tfstate
# Edit backup.tfstate to previous version
terraform state push backup.tfstate
terraform apply
```

### Database Rollback

**Warning**: Database rollbacks can be complex and may cause data loss.

```bash
# View DynamoDB table status
aws dynamodb describe-table --table-name $TABLE_NAME --region $AWS_REGION

# DynamoDB doesn't require migrations
# Data model changes are handled at the application level
```

### Emergency Rollback

For critical issues:

1. **Stop traffic**: Update API Gateway to maintenance mode
2. **Revert Lambda**: Use previous version
3. **Restore database**: From backup (if needed)
4. **Revert Terraform**: Use git to restore previous state
5. **Verify**: Run health checks
6. **Resume traffic**: Update API Gateway

## Best Practices

### Before Deployment

- [ ] Review all changes in pull request
- [ ] Run tests locally
- [ ] Update documentation
- [ ] Check for breaking changes
- [ ] Review Terraform plan output

### During Deployment

- [ ] Monitor workflow progress
- [ ] Watch for errors in logs
- [ ] Verify each step completes successfully
- [ ] Check CloudWatch for immediate errors

### After Deployment

- [ ] Run smoke tests
- [ ] Verify API endpoints
- [ ] Check CloudWatch metrics
- [ ] Monitor error rates
- [ ] Test critical user flows

### Security Checklist

- [ ] Never commit secrets to repository
- [ ] Use AWS Secrets Manager for sensitive data
- [ ] Rotate credentials regularly
- [ ] Enable MFA for production deployments
- [ ] Review IAM permissions (least privilege)
- [ ] Enable CloudTrail logging
- [ ] Set up billing alerts

## Cost Optimization

### Development Environment

- Use on-demand billing for DynamoDB
- Minimal Lambda memory allocation
- Short log retention periods
- No CloudFront CDN
- Destroy when not in use

### Production Environment

- Consider reserved capacity for predictable workloads
- Right-size Lambda memory
- Use S3 lifecycle policies
- Enable CloudFront for cost-effective delivery
- Set up cost monitoring and alerts

## Monitoring and Alerts

### CloudWatch Dashboards

After deployment, access your CloudWatch dashboard:

```bash
# Get dashboard URL from Terraform output
terraform output cloudwatch_dashboard_url
```

### Recommended Alarms

1. **Lambda Errors**: Alert on error rate > 1%
2. **API Gateway 5xx**: Alert on server errors
3. **DynamoDB Throttling**: Alert on throttled requests
4. **SQS Dead Letter Queue**: Alert on messages in DLQ
5. **Lambda Duration**: Alert on timeout approaching

### Setting Up Alarms

```bash
# Create alarm for Lambda errors
aws cloudwatch put-metric-alarm \
  --alarm-name duemate-production-lambda-errors \
  --alarm-description "Lambda function errors" \
  --metric-name Errors \
  --namespace AWS/Lambda \
  --statistic Sum \
  --period 300 \
  --evaluation-periods 1 \
  --threshold 10 \
  --comparison-operator GreaterThanThreshold
```

## Additional Resources

- **Terraform Documentation**: [terraform/README.md](terraform/README.md)
- **Terraform Deployment Guide**: [terraform/DEPLOYMENT_GUIDE.md](terraform/DEPLOYMENT_GUIDE.md)
- **API Documentation**: [API_README.md](API_README.md)
- **Project README**: [README.md](README.md)

## Support

For issues or questions:
- Create an issue in the repository
- Check existing documentation
- Review CloudWatch logs
- Contact DevOps team

---

**Last Updated**: 2025-10-28  
**Version**: 1.0  
**Maintained By**: DueMate DevOps Team
