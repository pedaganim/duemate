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

The staging environment uses the same simple configuration as dev:
- On-demand DynamoDB billing
- Lambda memory: 512 MB
- Log retention: 7 days
- S3 versioning: disabled (cost savings)
- Single-region deployment
- Optional custom domain support

This simplified configuration is designed for early-stage deployment (until ~1000 customers).

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
