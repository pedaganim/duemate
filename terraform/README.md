# DueMate Terraform Infrastructure

This directory contains Infrastructure as Code (IaC) using Terraform to deploy the DueMate application to AWS.

## Overview

DueMate uses a serverless-first architecture on AWS, leveraging managed services to minimize operational overhead and costs. The infrastructure includes:

- **Lambda Functions**: Serverless compute for API handlers and background workers
- **DynamoDB**: NoSQL database for storing invoices, clients, reminders, and tenant data
- **API Gateway**: REST API endpoints with authentication
- **S3 + CloudFront**: Static website hosting for the frontend
- **Cognito**: User authentication and authorization
- **EventBridge**: Scheduled events for reminder checks
- **SQS**: Message queues for asynchronous processing
- **CloudWatch**: Logging and monitoring
- **Secrets Manager**: Secure storage for API keys and credentials

## Directory Structure

```
terraform/
├── README.md                    # This file
├── main.tf                      # Root module configuration
├── variables.tf                 # Root module variables
├── outputs.tf                   # Root module outputs
├── versions.tf                  # Terraform and provider version constraints
├── terraform.tfvars.example     # Example variable values
├── modules/                     # Reusable infrastructure modules
│   ├── dynamodb/               # DynamoDB table module
│   ├── lambda/                 # Lambda function module
│   ├── api_gateway/            # API Gateway module
│   ├── frontend/               # S3 + CloudFront module
│   ├── cognito/                # Cognito user pool module
│   ├── eventbridge/            # EventBridge scheduler module
│   ├── sqs/                    # SQS queue module
│   └── monitoring/             # CloudWatch monitoring module
└── environments/               # Environment-specific configurations
    ├── dev/                    # Development environment
    ├── staging/                # Staging environment
    └── production/             # Production environment
```

## Prerequisites

Before deploying the infrastructure, ensure you have:

1. **AWS Account**: Active AWS account with administrative access
2. **AWS CLI**: Installed and configured with credentials
   ```bash
   aws configure
   ```
3. **Terraform**: Version 1.5+ installed
   ```bash
   terraform --version
   ```
4. **Domain Name**: (Optional) For custom domain configuration

## Quick Start

### 1. Configure Variables

Copy the example variables file and customize it:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your specific values:
- `project_name`: Your project name (default: "duemate")
- `environment`: Environment name (dev, staging, production)
- `aws_region`: AWS region for deployment (default: us-east-1)
- `customer_name`: Customer/tenant name for multi-tenant deployments

### 2. Initialize Terraform

```bash
cd terraform
terraform init
```

This downloads required provider plugins and initializes the backend.

### 3. Review the Plan

Preview the infrastructure changes:

```bash
terraform plan
```

Review the output to ensure all resources are correct.

**Note**: If resources already exist in AWS (e.g., from a previous deployment), they will be automatically imported into the Terraform state during `terraform plan` or `terraform apply`. See [IMPORT_EXISTING_RESOURCES.md](./IMPORT_EXISTING_RESOURCES.md) for details.

### 4. Deploy Infrastructure

Apply the Terraform configuration:

```bash
terraform apply
```

Type `yes` when prompted to confirm the deployment.

### 5. Verify Deployment

After successful deployment, Terraform will output important values:

```
Outputs:

api_endpoint = "https://xxxxxxxxxx.execute-api.us-east-1.amazonaws.com/prod"
cognito_user_pool_id = "us-east-1_xxxxxxxxx"
dynamodb_table_name = "duemate-main"
frontend_url = "https://xxxxxxxxxx.cloudfront.net"
```

## Environment-Specific Deployment

To deploy to a specific environment:

```bash
# Development
cd environments/dev
terraform init
terraform plan
terraform apply

# Staging
cd environments/staging
terraform init
terraform plan
terraform apply

# Production
cd environments/production
terraform init
terraform plan
terraform apply
```

## Managing Infrastructure

### Update Infrastructure

After modifying Terraform files:

```bash
terraform plan   # Review changes
terraform apply  # Apply changes
```

### Destroy Infrastructure

To tear down all resources (use with caution):

```bash
terraform destroy
```

### View Current State

```bash
terraform show
```

### View Outputs

```bash
terraform output
```

## Resource Naming Convention

Resources follow this naming pattern:
```
{project_name}-{environment}-{resource_type}-{description}
```

Example: `duemate-production-lambda-invoice-create`

## Module Documentation

### DynamoDB Module
Creates the main DynamoDB table with:
- Single-table design for multi-tenancy
- Global Secondary Indexes (GSI) for query patterns
- On-demand billing mode (pay-per-request)
- Point-in-time recovery enabled
- Server-side encryption enabled

### Lambda Module
Deploys Lambda functions with:
- Node.js 20 runtime
- IAM roles with least-privilege permissions
- Environment variables configuration
- CloudWatch Logs integration
- VPC configuration (optional)

### API Gateway Module
Sets up REST API with:
- Cognito authorizer for protected endpoints
- CORS configuration
- Request/response validation
- CloudWatch logging
- Custom domain support (optional)

### Frontend Module
Creates S3 bucket and CloudFront distribution for:
- Static website hosting
- Global CDN delivery
- SSL/TLS certificate (optional)
- Custom domain configuration (optional)

### Cognito Module
Provisions user pool with:
- Email/password authentication
- MFA support (optional)
- User attributes configuration
- Password policy enforcement
- Lambda triggers for custom auth flows (optional)

### EventBridge Module
Configures scheduled events for:
- Reminder check jobs (hourly/daily)
- Data cleanup tasks
- Report generation
- Lambda function triggers

### SQS Module
Creates queues for:
- Notification delivery
- Background job processing
- Dead letter queues for failed messages
- Message retention policies

### Monitoring Module
Sets up CloudWatch resources:
- Log groups for Lambda functions
- Metrics dashboards
- Alarms for critical metrics
- SNS topics for alarm notifications

## Variables Reference

### Required Variables

| Variable | Type | Description | Example |
|----------|------|-------------|---------|
| `project_name` | string | Project name | "duemate" |
| `environment` | string | Environment name | "production" |
| `aws_region` | string | AWS region | "us-east-1" |

### Optional Variables

| Variable | Type | Description | Default |
|----------|------|-------------|---------|
| `customer_name` | string | Customer name for whitelabel | null |
| `custom_domain` | string | Custom domain name | null |
| `enable_monitoring` | bool | Enable CloudWatch dashboards | true |
| `enable_vpc` | bool | Deploy Lambda in VPC | false |
| `lambda_runtime` | string | Lambda runtime version | "nodejs20.x" |
| `dynamodb_billing_mode` | string | DynamoDB billing mode | "PAY_PER_REQUEST" |

See `variables.tf` for complete list.

## Cost Optimization

The infrastructure is designed to minimize costs:

1. **Serverless Services**: Pay only for what you use (Lambda, API Gateway, DynamoDB on-demand)
2. **Free Tier Eligible**: Most services have generous AWS free tier allowances
3. **On-Demand Billing**: DynamoDB and Lambda scale to zero when not in use
4. **S3 Lifecycle Policies**: Automatically archive old data to cheaper storage classes
5. **CloudWatch Log Retention**: Configure log retention to avoid unbounded storage costs

### Estimated Monthly Costs

- **Low usage** (<100 invoices/month): $0-5/month
- **Medium usage** (1,000 invoices/month): $10-30/month
- **High usage** (10,000 invoices/month): $50-150/month

Note: Costs depend on actual usage. Most services remain in free tier during development.

## Security Best Practices

1. **State Storage**: Use S3 backend with encryption for Terraform state
2. **Secrets Management**: Never commit secrets; use AWS Secrets Manager
3. **IAM Roles**: Follow least-privilege principle for all resources
4. **Encryption**: Enable encryption at rest and in transit
5. **Monitoring**: Set up CloudWatch alarms for security events
6. **Access Control**: Use IAM roles and policies, not long-lived credentials

## Backup and Disaster Recovery

1. **DynamoDB**: Point-in-time recovery enabled automatically
2. **S3**: Versioning enabled for critical buckets
3. **Lambda**: Code stored in version control
4. **Terraform State**: Backed up in S3 with versioning

## Troubleshooting

### Common Issues

**Issue**: "Error: creating IAM Role: EntityAlreadyExists" or "Error: creating S3 Bucket: BucketAlreadyExists"
- **Solution**: Resources already exist in AWS. The repository includes automatic import configuration in `import.tf.example`. To use it, rename the file to `import.tf` and run terraform again. See [IMPORT_EXISTING_RESOURCES.md](./IMPORT_EXISTING_RESOURCES.md) for detailed instructions.

**Issue**: "Error: configuring Terraform AWS Provider: no valid credential sources"
- **Solution**: Configure AWS credentials with `aws configure` or set environment variables

**Issue**: "Error creating DynamoDB Table: ResourceInUseException"
- **Solution**: Table already exists. Import existing resource or change the name

**Issue**: "Error: error creating Lambda Function: InvalidParameterValueException"
- **Solution**: Check Lambda deployment package exists and is valid

**Issue**: API Gateway returns 403 Forbidden
- **Solution**: Verify Cognito authorizer configuration and JWT token validity

### Debug Commands

```bash
# Enable detailed logging
export TF_LOG=DEBUG

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive

# Check state
terraform state list

# Import existing resource
terraform import <resource_type>.<name> <resource_id>
```

## Continuous Deployment

For automated deployments via CI/CD:

```yaml
# Example GitHub Actions workflow
- name: Configure AWS Credentials
  uses: aws-actions/configure-aws-credentials@v2
  with:
    role-to-assume: arn:aws:iam::ACCOUNT_ID:role/TerraformRole
    aws-region: us-east-1

- name: Terraform Init
  run: terraform init

- name: Terraform Plan
  run: terraform plan

- name: Terraform Apply
  run: terraform apply -auto-approve
```

## Migration from Serverless Framework

If migrating from Serverless Framework:

1. Export existing resource IDs
2. Import resources into Terraform state
3. Verify state matches actual infrastructure
4. Gradually transition management to Terraform

## Support and Resources

- **Terraform Documentation**: https://www.terraform.io/docs
- **AWS Provider Docs**: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- **Project Architecture**: See `docs/system-architecture.md`
- **AWS Best Practices**: https://aws.amazon.com/architecture/well-architected/

## License

See project LICENSE file.

---

**Last Updated**: 2025-10-27  
**Terraform Version**: 1.5+  
**AWS Provider Version**: 5.0+
