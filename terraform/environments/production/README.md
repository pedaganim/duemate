# Production Environment Configuration

This directory contains Terraform configuration for the **production** environment.

## Usage

```bash
cd terraform/environments/production
terraform init
terraform plan
terraform apply
```

## Configuration

The production environment uses the same simple configuration as dev/staging:
- On-demand DynamoDB billing
- Lambda memory: 512 MB
- Log retention: 7 days
- S3 versioning: disabled (cost savings)
- Single-region deployment
- Custom domain support
- Optional monitoring alarms

This simplified configuration is designed for early-stage deployment (until ~1000 customers).
Configuration can be scaled up as needed when customer base grows.

## Security Considerations

- [ ] Review all security group rules
- [ ] Configure custom domain with SSL
- [ ] Set up CloudTrail for audit logging
- [ ] Configure backup policies

## Outputs

After deployment, get outputs with:
```bash
terraform output
```

## Cleanup

**WARNING:** Never destroy production without proper backup and approval.

```bash
# First, backup all data
# Then, with approval:
terraform destroy
```
