# Staging Environment Configuration

This directory contains Terraform configuration for the **staging** environment.

## Usage

```bash
cd terraform/environments/staging
terraform init
terraform plan
terraform apply
```

## Configuration

The staging environment uses:
- On-demand DynamoDB billing
- Medium Lambda memory (1024 MB)
- Medium log retention (14 days)
- Single-region deployment
- Optional custom domain support

## Outputs

After deployment, get outputs with:
```bash
terraform output
```

## Cleanup

To destroy the staging environment:
```bash
terraform destroy
```
