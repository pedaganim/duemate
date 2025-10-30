# Scripts Directory

This directory contains utility scripts for the DueMate project.

## Deployment Scripts

### deploy-lambda.sh

Packages and deploys Lambda functions to AWS.

**Prerequisites:**
- AWS CLI installed and configured
- Application built (`npm run build`)
- Node modules installed

**Usage:**
```bash
./scripts/deploy-lambda.sh <environment>
```

**Example:**
```bash
./scripts/deploy-lambda.sh dev
./scripts/deploy-lambda.sh staging
./scripts/deploy-lambda.sh production
```

**What it does:**
- Creates deployment packages for all Lambda functions
- Uploads function code to AWS
- Updates Lambda function configurations
- Verifies deployment

**Functions deployed:**
- Invoice management (create, list, get, update, delete, pdf)
- Client management (create, list, get, update, delete)
- Reminder system (create, check, send)
- Notification worker

### deploy-frontend.sh

Deploys frontend application to S3 and CloudFront.

**Prerequisites:**
- AWS CLI installed and configured
- Frontend built (`npm run build` in frontend directory)

**Usage:**
```bash
./scripts/deploy-frontend.sh <environment>
```

**Example:**
```bash
./scripts/deploy-frontend.sh production
```

**What it does:**
- Builds the frontend application
- Syncs files to S3 bucket with cache headers
- Creates CloudFront invalidation
- Verifies deployment

### run-migrations.sh

Verifies DynamoDB database setup.

**Prerequisites:**
- AWS CLI installed and configured
- DynamoDB table created by Terraform

**Usage:**
```bash
./scripts/run-migrations.sh <environment>
```

**Example:**
```bash
./scripts/run-migrations.sh production
```

**What it does:**
- Verifies DynamoDB table exists
- Checks table status and accessibility
- Displays table information

**Note:** DueMate uses DynamoDB. Database tables are created by Terraform, not by migrations.

### verify-deployment.sh

Verifies that all AWS resources are deployed correctly.

**Prerequisites:**
- AWS CLI installed and configured

**Usage:**
```bash
./scripts/verify-deployment.sh <environment>
```

**Example:**
```bash
./scripts/verify-deployment.sh production
```

**What it checks:**
- ✓ DynamoDB tables
- ✓ Lambda functions
- ✓ API Gateway
- ✓ S3 buckets
- ✓ Cognito user pools
- ✓ SQS queues
- ✓ CloudWatch log groups

**Output:**
- Green ✓ for resources found
- Red ✗ for missing resources
- Summary with health status

## Utility Scripts

### create-issues.sh

This script creates all the GitHub issues for the DueMate MVP product backlog.

**Prerequisites:**

1. Install GitHub CLI: https://cli.github.com/
2. Authenticate with GitHub:
   ```bash
   gh auth login
   ```

**Usage:**

```bash
./scripts/create-issues.sh
```

The script will create 16 GitHub issues in the `pedaganim/duemate` repository:

- **11 Core Features (P0)** - Essential for MVP
  - Project setup and infrastructure
  - Database schema
  - Client CRUD operations (2 issues)
  - Invoice CRUD operations (2 issues)
  - Reminder scheduling
  - Email delivery
  - Frontend UI (3 issues: clients, invoices, dashboard)

- **3 Nice-to-Have Features (P1)** - Valuable additions
  - Bank account sync
  - AI voice reminders
  - Whitelabel/multi-tenant support

- **2 Future Enhancements (P2)** - Long-term roadmap
  - Reporting and analytics
  - Mobile application

**Issue Structure:**

Each issue includes:
- Clear title
- Detailed description
- Acceptance criteria as checkboxes
- Appropriate labels (priority, category, feature area)

**Verification:**

After running the script, verify the issues were created:

```bash
gh issue list --repo pedaganim/duemate
```

**Manual Creation:**

If you prefer to create issues manually, refer to:
- `PRODUCT_BACKLOG.md` - Detailed documentation for each issue
- `issues.json` - Structured JSON data of all issues

## Making Scripts Executable

All scripts should already be executable. If needed, make them executable:

```bash
chmod +x scripts/*.sh
```

## Environment Variables

Scripts may require the following environment variables:

| Variable | Description | Required By |
|----------|-------------|-------------|
| `AWS_REGION` | AWS region | All deployment scripts |
| `S3_BUCKET_NAME` | S3 bucket for frontend | deploy-frontend.sh |

**Note**: DueMate uses DynamoDB which is provisioned by Terraform. No DATABASE_URL is needed.

## Additional Resources

- **[Deployment Guide](../DEPLOY.md)** - Comprehensive deployment documentation
- **[Terraform Documentation](../terraform/README.md)** - Infrastructure as Code
- **[API Documentation](../API_README.md)** - API reference

---

**Note:** For automated CI/CD deployments, these scripts are called automatically by GitHub Actions. See [DEPLOY.md](../DEPLOY.md) for details.
