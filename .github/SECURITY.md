# GitHub Actions Security Configuration

This document provides important security information for the DueMate deployment workflows.

## Required Secrets

The following secrets must be configured in your GitHub repository:

### Repository Secrets

Navigate to: Settings → Secrets and variables → Actions

| Secret Name | Description | Example Value |
|-------------|-------------|---------------|
| `AWS_ACCESS_KEY_ID` | AWS IAM user access key | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | AWS IAM secret access key | `wJalrXUtnFEMI/K7MDENG/bPxRfi...` |
| `AWS_REGION` | AWS region for deployment | `us-east-1` |
| `TERRAFORM_STATE_BUCKET` | S3 bucket for Terraform state (optional) | `duemate-terraform-state` |

### Environment Secrets

Create three environments: `dev`, `staging`, `production`

Navigate to: Settings → Environments → [Create/Edit Environment]

**For each environment, configure:**

| Secret Name | Description | Required |
|-------------|-------------|----------|
| `DATABASE_URL` | Database connection string | Yes* |
| `AWS_REGION` | Region override (optional) | No |
| `S3_BUCKET_NAME` | Frontend bucket override | No |

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

## IAM User Permissions

The IAM user associated with `AWS_ACCESS_KEY_ID` requires the following permissions:

### Minimum Required Permissions

Create a custom IAM policy with these permissions:

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
        "secretsmanager:GetSecretValue",
        "secretsmanager:CreateSecret",
        "secretsmanager:UpdateSecret"
      ],
      "Resource": "*"
    }
  ]
}
```

### Best Practice: Use OIDC Instead

For enhanced security, consider using OpenID Connect (OIDC) instead of long-lived credentials:

1. Create an IAM OIDC identity provider for GitHub
2. Create an IAM role with trust policy for GitHub Actions
3. Update workflow to use `aws-actions/configure-aws-credentials@v4` with `role-to-assume`

Example workflow configuration:

```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: arn:aws:iam::123456789012:role/GitHubActionsRole
    aws-region: us-east-1
```

## Security Best Practices

### 1. Secret Rotation

- Rotate AWS credentials every 90 days
- Update GitHub secrets immediately after rotation
- Use AWS IAM Access Analyzer to identify unused credentials

### 2. Least Privilege

- Grant only necessary permissions
- Use separate IAM users/roles for each environment
- Regularly review and audit IAM policies

### 3. Secret Storage

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
  id-token: write  # Only if using OIDC
```

## Monitoring and Alerts

### GitHub Actions Monitoring

- Monitor workflow runs for failures
- Review workflow logs regularly
- Set up notifications for failed deployments

### AWS Monitoring

- Enable CloudWatch alarms
- Monitor CloudTrail logs
- Set up AWS Config rules
- Use AWS Security Hub

## Incident Response

If credentials are compromised:

1. **Immediately**: Disable the IAM access key
2. **Create**: New IAM access key
3. **Update**: GitHub secrets with new credentials
4. **Review**: CloudTrail logs for unauthorized activity
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
