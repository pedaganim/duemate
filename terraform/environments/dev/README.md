# Development Environment Configuration

This directory contains Terraform configuration for the **development** environment.

## Usage

```bash
cd terraform/environments/dev
terraform init
terraform plan
terraform apply
```

## Configuration

The development environment uses:
- On-demand DynamoDB billing
- Lower Lambda memory (512 MB)
- Shorter log retention (7 days)
- Single-region deployment
- No custom domain

## Outputs

After deployment, get outputs with:
```bash
terraform output
```

## Cleanup

To destroy the development environment:
```bash
terraform destroy
```
