# AWS Deployment Setup Guide

This guide provides step-by-step instructions for setting up GitHub secrets, variables, and required AWS resources for the DueMate deployment workflow.

## Required GitHub Secrets

### Repository Secrets

Navigate to: **Settings → Secrets and variables → Actions → Secrets → New repository secret**

| Secret Name | Required | Description | Example Value | Where to Get |
|-------------|----------|-------------|---------------|--------------|
| `AWS_ROLE_ARN` | **Yes** | AWS IAM role ARN for OIDC | `arn:aws:iam::123456789012:role/GitHubActionsRole` | Create IAM role (see below) |
| `AWS_REGION` | **Yes** | AWS region for deployment | `us-east-1` | Choose your preferred region |
| `TERRAFORM_STATE_BUCKET` | No | S3 bucket for Terraform state | `duemate-terraform-state` | Create S3 bucket first (see below) |

### Environment Secrets

Navigate to: **Settings → Environments**

#### Step 1: Create Environments

Create three environments:
1. Click **New environment**
2. Enter name: `dev`
3. Click **Configure environment**
4. Repeat for `staging` and `production`

#### Step 2: Add Secrets to Each Environment

For **each environment** (dev, staging, production), add:

| Secret Name | Required | Description | Example Value |
|-------------|----------|-------------|---------------|
| `DATABASE_URL` | **Yes*** | Database connection string | `postgresql://user:pass@host:5432/db` or `sqlite:./dev.db` |
| `AWS_REGION` | No | Region override for this environment | `us-west-2` |
| `S3_BUCKET_NAME` | No | Frontend bucket name override | `duemate-dev-frontend` |

**Note**: `DATABASE_URL` can alternatively be stored in AWS Secrets Manager (see below).

#### Environment Protection Rules (Recommended)

**Production environment:**
- ✅ Required reviewers: 2
- ✅ Wait timer: 5 minutes
- ✅ Deployment branches: `main` only
- ✅ Prevent self-review: Enabled

**Staging environment:**
- ✅ Required reviewers: 1
- ✅ Deployment branches: `staging` only

**Dev environment:**
- No protection rules needed

## Required AWS Resources (One-Time Setup)

### 1. IAM Role for GitHub Actions (OIDC)

**Step 1: Create an OIDC Identity Provider**

1. Go to **IAM Console → Identity providers → Add provider**
2. Select **OpenID Connect**
3. **Provider URL**: `https://token.actions.githubusercontent.com`
4. **Audience**: `sts.amazonaws.com`
5. Click **Add provider**

**Step 2: Create IAM Role**

1. Go to **IAM Console → Roles → Create role**
2. Select **Web identity**
3. **Identity provider**: Choose the GitHub OIDC provider you just created
4. **Audience**: `sts.amazonaws.com`
5. Click **Next**

**Step 3: Add Trust Policy**

Edit the trust policy to restrict to your repository:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:pedaganim/duemate:*"
        }
      }
    }
  ]
}
```

**Step 4: Attach Permissions**

Option A - Use Administrator Access (quick setup):
- Attach policy: `AdministratorAccess`

Option B - Use Custom Policy (recommended for production):

Create a custom policy with these permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "lambda:*",
        "apigateway:*",
        "dynamodb:*",
        "s3:*",
        "cloudfront:*",
        "cognito-idp:*",
        "sqs:*",
        "events:*",
        "logs:*",
        "iam:GetRole",
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:PassRole",
        "iam:PutRolePolicy",
        "iam:DeleteRolePolicy",
        "secretsmanager:*",
        "ses:*"
      ],
      "Resource": "*"
    }
  ]
}
```

**Step 5: Save Role ARN**

1. After creating the role, copy the **Role ARN** (e.g., `arn:aws:iam::123456789012:role/GitHubActionsRole`)
2. Add it to GitHub secret `AWS_ROLE_ARN`

### 2. S3 Bucket for Terraform State (Optional but Recommended)

**Create S3 Bucket:**

```bash
# Replace 'duemate-terraform-state' with your preferred name
aws s3 mb s3://duemate-terraform-state --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket duemate-terraform-state \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket duemate-terraform-state \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Block public access
aws s3api put-public-access-block \
  --bucket duemate-terraform-state \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
```

**Create DynamoDB Table for State Locking:**

```bash
aws dynamodb create-table \
  --table-name duemate-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

**Add to GitHub Secrets:**
- Secret name: `TERRAFORM_STATE_BUCKET`
- Value: `duemate-terraform-state`

### 3. AWS Secrets Manager (For Third-Party API Keys)

Create secrets for sensitive third-party credentials:

**Database Connection (Alternative to Environment Secret):**

```bash
aws secretsmanager create-secret \
  --name duemate-dev/database \
  --description "Database connection for dev environment" \
  --secret-string '{"url":"postgresql://user:pass@host:5432/duemate_dev"}' \
  --region us-east-1

# Repeat for staging and production
aws secretsmanager create-secret \
  --name duemate-staging/database \
  --secret-string '{"url":"postgresql://user:pass@host:5432/duemate_staging"}' \
  --region us-east-1

aws secretsmanager create-secret \
  --name duemate-production/database \
  --secret-string '{"url":"postgresql://user:pass@host:5432/duemate_production"}' \
  --region us-east-1
```

**Stripe API Keys (if using):**

```bash
aws secretsmanager create-secret \
  --name duemate-production/stripe \
  --description "Stripe API credentials" \
  --secret-string '{"api_key":"sk_live_..."}' \
  --region us-east-1
```

**Twilio Credentials (if using):**

```bash
aws secretsmanager create-secret \
  --name duemate-production/twilio \
  --description "Twilio API credentials" \
  --secret-string '{"account_sid":"AC...","auth_token":"...","phone_number":"+1..."}' \
  --region us-east-1
```

**Plaid Credentials (if using):**

```bash
aws secretsmanager create-secret \
  --name duemate-production/plaid \
  --description "Plaid API credentials" \
  --secret-string '{"client_id":"...","secret":"...","env":"production"}' \
  --region us-east-1
```

### 4. SES Email Verification (For Email Sending)

**Verify Sender Email Address:**

```bash
# Verify the email address you'll use to send reminders
aws ses verify-email-identity \
  --email-address noreply@yourdomain.com \
  --region us-east-1

# Check your email and click the verification link
```

**For Production (Optional - Custom Domain):**

```bash
# Verify domain for production email sending
aws ses verify-domain-identity \
  --domain yourdomain.com \
  --region us-east-1
```

## Summary Checklist

### Before First Deployment

- [ ] **AWS IAM Role Created (OIDC)**
  - [ ] OIDC identity provider created for GitHub Actions
  - [ ] IAM role created with trust policy for your repository
  - [ ] Permissions attached (Administrator or custom policy)
  - [ ] Added `AWS_ROLE_ARN` to GitHub secrets
  - [ ] Added `AWS_REGION` to GitHub secrets

- [ ] **GitHub Environments Created**
  - [ ] Created `dev` environment
  - [ ] Created `staging` environment
  - [ ] Created `production` environment

- [ ] **Environment Secrets Configured**
  - [ ] Added `DATABASE_URL` to dev environment (or Secrets Manager)
  - [ ] Added `DATABASE_URL` to staging environment (or Secrets Manager)
  - [ ] Added `DATABASE_URL` to production environment (or Secrets Manager)

- [ ] **Terraform State Backend (Optional)**
  - [ ] Created S3 bucket for Terraform state
  - [ ] Enabled versioning on bucket
  - [ ] Enabled encryption on bucket
  - [ ] Created DynamoDB table for state locking
  - [ ] Added `TERRAFORM_STATE_BUCKET` to GitHub secrets

- [ ] **AWS Secrets Manager (Optional)**
  - [ ] Created database secrets (if not using env secrets)
  - [ ] Created Stripe secrets (if using)
  - [ ] Created Twilio secrets (if using)
  - [ ] Created Plaid secrets (if using)

- [ ] **SES Email Verification (Optional)**
  - [ ] Verified sender email address
  - [ ] Checked verification email and clicked link

### Ready to Deploy!

Once you've completed the checklist above, you can deploy:

```bash
# Push to develop branch (deploys to dev)
git push origin develop

# Or use GitHub Actions UI:
# Actions → Deploy to AWS → Run workflow → Select 'dev' → Run
```

## Quick Reference

### Minimum Required Setup

To get started with minimal setup:

1. **GitHub Repository Secrets** (2 required):
   - `AWS_ROLE_ARN`
   - `AWS_REGION`

2. **GitHub Environment Secrets** (1 per environment):
   - `dev` environment: `DATABASE_URL`
   - `staging` environment: `DATABASE_URL`
   - `production` environment: `DATABASE_URL`

That's it! The workflow will create all other AWS resources automatically using Terraform.

### AWS Resources Created by Terraform

The workflow will automatically create:

- **DynamoDB Tables** - Main data storage
- **Lambda Functions** - 15+ serverless functions
- **API Gateway** - REST API endpoints
- **S3 Buckets** - Frontend hosting, invoices, assets
- **CloudFront** - CDN for frontend
- **Cognito User Pool** - Authentication (if enabled)
- **SQS Queues** - Message queues for notifications
- **EventBridge Rules** - Scheduled tasks
- **CloudWatch** - Logging and monitoring
- **IAM Roles** - Function execution roles

## Troubleshooting

### "Error: configuring Terraform AWS Provider: no valid credential sources"

**Cause:** AWS credentials not configured in GitHub secrets

**Solution:**
1. Verify secrets are set: Settings → Secrets and variables → Actions
2. Check secret names match exactly: `AWS_ROLE_ARN`, `AWS_REGION`
3. Verify IAM role exists and has correct trust policy
4. Verify OIDC provider is configured in AWS IAM

### "Error: error creating DynamoDB Table: ResourceInUseException"

**Cause:** Resources already exist from previous deployment

**Solution:**
1. Either destroy existing resources: `terraform destroy`
2. Or import existing resources: `terraform import`

### "jq: command not found" during migrations

**Cause:** `jq` tool not installed in GitHub Actions runner

**Solution:** This shouldn't happen as GitHub Actions runners have `jq` pre-installed. If it does, set `DATABASE_URL` directly in environment secrets instead of using Secrets Manager.

## Additional Resources

- **Full Deployment Guide**: [DEPLOY.md](DEPLOY.md)
- **Quick Start**: [QUICKSTART_DEPLOY.md](QUICKSTART_DEPLOY.md)
- **Security Guide**: [.github/SECURITY.md](.github/SECURITY.md)
- **Environment Template**: [.env.example](.env.example)
- **Terraform Documentation**: [terraform/README.md](terraform/README.md)

## Need Help?

- Check the [DEPLOY.md](DEPLOY.md) troubleshooting section
- Review GitHub Actions workflow logs
- Check CloudWatch logs for Lambda functions
- Create an issue in the repository

---

**Last Updated**: 2025-10-28  
**Version**: 1.0
