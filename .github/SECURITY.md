# GitHub Actions Security Configuration

This document provides important security information for the DueMate deployment workflows.

## Required Secrets

The following secrets must be configured in your GitHub repository:

### Repository Secrets

Navigate to: Settings → Secrets and variables → Actions

| Secret Name | Description | Example Value |
|-------------|-------------|---------------|
| `AWS_ROLE_ARN` | AWS IAM role ARN for OIDC authentication | `arn:aws:iam::123456789012:role/GitHubActionsRole` |
| `TERRAFORM_STATE_BUCKET` | S3 bucket for Terraform state (optional) | `duemate-terraform-state` |

### Repository Variables

Navigate to: Settings → Secrets and variables → Actions → Variables

| Variable Name | Description | Example Value |
|---------------|-------------|---------------|
| `AWS_REGION` | AWS region for deployment | `us-east-1` |

### Environment Secrets

Create three environments: `dev`, `staging`, `production`

Navigate to: Settings → Environments → [Create/Edit Environment]

**For each environment, configure:**

| Secret Name | Description | Required |
|-------------|-------------|----------|
| `DATABASE_URL` | Database connection string | Yes* |
| `S3_BUCKET_NAME` | Frontend bucket override | No |

**Environment Variables (optional overrides):**

| Variable Name | Description | Required |
|---------------|-------------|----------|
| `AWS_REGION` | Region override (optional) | No |

*Note: DATABASE_URL can also be stored in AWS Secrets Manager

## Environment Protection Rules

### Development (`dev`)

- **Required reviewers**: None
- **Wait timer**: None
- **Deployment branches**: `develop` branch only

### Staging (`staging`)

- **Required reviewers**: 1 reviewer (recommended)
- **Wait timer**: None
- **Deployment branches**: `staging` branch only

### Production (`production`)

- **Required reviewers**: 2 reviewers (strongly recommended)
- **Wait timer**: 5 minutes (recommended)
- **Deployment branches**: `main` branch only
- **Prevent self-review**: Enabled

## IAM Role Setup (OIDC Authentication)

The workflow uses OpenID Connect (OIDC) for secure authentication with AWS, eliminating the need for long-lived access keys.

### Setting Up OIDC Provider

1. **Create OIDC Identity Provider in AWS IAM:**
   - Provider URL: `https://token.actions.githubusercontent.com`
   - Audience: `sts.amazonaws.com`

2. **Create IAM Role with Trust Policy:**

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

### Required IAM Role Permissions

Attach a custom policy with these permissions to the IAM role:

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
        "secretsmanager:GetSecretValue",
        "secretsmanager:CreateSecret",
        "secretsmanager:UpdateSecret"
      ],
      "Resource": "*"
    }
  ]
}
```

### Workflow Configuration

The workflow is already configured to use OIDC:

```yaml
permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    steps:
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: us-east-1
```

## Security Best Practices

### 1. OIDC Benefits

Using OIDC instead of long-lived access keys provides:
- **No long-lived credentials** - Temporary credentials expire automatically
- **Reduced attack surface** - No access keys to leak or rotate
- **Better auditability** - CloudTrail logs show which GitHub workflow made requests
- **Fine-grained access** - Trust policy can restrict to specific repositories and branches

### 2. Secret Rotation

- IAM role credentials rotate automatically with OIDC
- Review and update IAM role permissions periodically
- Audit trust policies to ensure they're not overly permissive

### 3. Least Privilege

- Grant only necessary permissions
- Use separate IAM roles for each environment
- Regularly review and audit IAM policies
- Restrict trust policy to specific repository

### 4. Secret Storage

- **Never** commit secrets to the repository
- Use AWS Secrets Manager for sensitive data
- Store database credentials in Secrets Manager
- Reference secrets by ARN in Lambda functions

### 4. Audit Logging

- Enable AWS CloudTrail for all regions
- Monitor CloudTrail logs for suspicious activity
- Set up CloudWatch alarms for security events

### 5. Branch Protection

Enable branch protection rules:

- `main` → Require pull request reviews (2 approvers)
- `main` → Require status checks to pass
- `main` → Require signed commits (recommended)
- `staging` → Require pull request reviews (1 approver)

### 6. Workflow Permissions

The workflows use minimal permissions:

```yaml
permissions:
  contents: read
  id-token: write  # Required for OIDC authentication
```

## Monitoring and Alerts

### GitHub Actions Monitoring

- Monitor workflow runs for failures
- Review workflow logs regularly
- Set up notifications for failed deployments

### AWS Monitoring

- Enable CloudWatch alarms
- Monitor CloudTrail logs for AssumeRoleWithWebIdentity events
- Set up AWS Config rules
- Use AWS Security Hub

## Incident Response

If the IAM role is compromised:

1. **Immediately**: Update the trust policy to remove compromised repository access
2. **Review**: CloudTrail logs for unauthorized AssumeRoleWithWebIdentity activity
5. **Rotate**: All other affected credentials
6. **Document**: Incident and response

## Compliance

### GDPR/Data Protection

- Ensure database encryption at rest
- Enable S3 bucket encryption
- Use HTTPS for all API endpoints
- Implement data retention policies

### SOC 2 / ISO 27001

- Document all deployment procedures
- Maintain audit logs (CloudTrail)
- Regular security reviews
- Access control documentation

## Additional Resources

- [GitHub Actions Security Hardening](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)
- [AWS Security Best Practices](https://aws.amazon.com/architecture/security-identity-compliance/)
- [Terraform Security Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

## Contact

For security concerns or questions:
- Create a private security advisory in GitHub
- Contact the DevOps team
- Email: security@yourcompany.com (configure appropriately)

---

**Last Updated**: 2025-10-28  
**Version**: 1.0
