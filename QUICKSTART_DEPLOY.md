# Quick Start: AWS Deployment

This is a quick reference guide for deploying DueMate to AWS. For comprehensive documentation, see [DEPLOY.md](DEPLOY.md).

## 🚀 First Time Setup

### 1. Configure GitHub Secrets and Variables

**Secrets** - Go to **Settings** → **Secrets and variables** → **Actions** → **Secrets** → **New repository secret**

Add these secrets:

| Secret | Value |
|--------|-------|
| `AWS_ACCESS_KEY_ID` | Your AWS access key |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret key |

**Variables** - Go to **Settings** → **Secrets and variables** → **Actions** → **Variables** → **New repository variable**

Add these variables:

| Variable | Value |
|----------|-------|
| `AWS_REGION` | `us-east-1` (or your preferred region) |

### 2. Create Environments

Go to **Settings** → **Environments** → **New environment**

Create: `dev`, `staging`, `production`

For each environment, add:
- `DATABASE_URL` (your database connection string)

### 3. (Optional) Setup Terraform State Backend

```bash
# Create S3 bucket for Terraform state
aws s3 mb s3://duemate-terraform-state --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket duemate-terraform-state \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for locking
aws dynamodb create-table \
  --table-name duemate-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

Add `TERRAFORM_STATE_BUCKET=duemate-terraform-state` to GitHub secrets.

## 📦 Deploy to AWS

### Automatic Deployment (Push to Branch)

```bash
# Deploy to development
git push origin develop

# Deploy to staging
git push origin staging

# Deploy to production
git push origin main
```

### Manual Deployment (GitHub UI)

1. Go to **Actions** tab
2. Select **Deploy to AWS** workflow
3. Click **Run workflow**
4. Choose environment and action
5. Click **Run workflow**

## 🔍 Monitor Deployment

1. Go to **Actions** tab
2. Click on the running workflow
3. Watch the progress of each job

Expected workflow steps:
- ✓ Determine Environment
- ✓ Build and Test
- ✓ Deploy Infrastructure
- ✓ Deploy Application
- ✓ Deploy Frontend (if exists)
- ✓ Verify Deployment

## 🎯 Access Deployed Application

After deployment, find URLs in:

1. **GitHub Actions Summary** (bottom of workflow run)
2. **Terraform outputs**:
   ```bash
   cd terraform
   terraform output
   ```

Example endpoints:
- API: `https://abc123.execute-api.us-east-1.amazonaws.com/prod`
- Frontend: `https://d111111abcdef8.cloudfront.net`

## 📝 Manual Deployment (Local)

If you need to deploy manually:

```bash
# 1. Deploy infrastructure
cd terraform
terraform init
terraform apply -var="environment=dev"

# 2. Build application
cd ..
npm install
npm run build

# 3. Deploy Lambda functions
./scripts/deploy-lambda.sh dev

# 4. Run migrations (optional)
export DATABASE_URL="your-database-url"
./scripts/run-migrations.sh dev

# 5. Verify deployment
./scripts/verify-deployment.sh dev
```

## 🔧 Troubleshooting

### Workflow fails during Terraform

**Check:**
- AWS credentials are valid
- IAM user has sufficient permissions
- Terraform state is not locked

**Fix:**
```bash
# Verify AWS credentials
aws sts get-caller-identity

# Unlock state (if locked)
cd terraform
terraform force-unlock <LOCK_ID>
```

### Lambda deployment fails

**Check:**
- Application is built (`npm run build`)
- Function exists in AWS (created by Terraform)

**Fix:**
```bash
# List Lambda functions
aws lambda list-functions --query 'Functions[?starts_with(FunctionName, `duemate-dev`)].FunctionName'

# Deploy manually
./scripts/deploy-lambda.sh dev
```

### Frontend deployment fails

**Check:**
- Frontend directory exists
- S3 bucket exists

**Fix:**
```bash
# Check if bucket exists
aws s3 ls s3://duemate-dev-frontend

# Deploy manually
./scripts/deploy-frontend.sh dev
```

## 🛡️ Security Best Practices

- ✅ Never commit secrets to repository
- ✅ Use AWS Secrets Manager for sensitive data
- ✅ Rotate credentials every 90 days
- ✅ Enable branch protection on `main`
- ✅ Require reviews for production deployments
- ✅ Monitor CloudWatch logs for errors

## 📚 Resources

- [Full Deployment Guide](DEPLOY.md)
- [Security Configuration](.github/SECURITY.md)
- [Terraform Documentation](terraform/README.md)
- [API Documentation](API_README.md)
- [Deployment Scripts](scripts/README.md)

## 🆘 Need Help?

1. Check [DEPLOY.md](DEPLOY.md) for detailed instructions
2. Review [Troubleshooting](DEPLOY.md#troubleshooting) section
3. Check CloudWatch logs for errors
4. Review workflow run logs in GitHub Actions
5. Create an issue in the repository

---

**Quick Links:**
- [GitHub Actions Workflows](.github/workflows/)
- [AWS Console](https://console.aws.amazon.com/)
- [Terraform Cloud](https://app.terraform.io/)
