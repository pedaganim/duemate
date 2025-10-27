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

The production environment uses:
- On-demand DynamoDB billing (with auto-scaling ready)
- High Lambda memory (1536 MB)
- Long log retention (30 days)
- Single or multi-region deployment
- Custom domain support
- Enhanced monitoring and alarms

## Security Considerations

- [ ] Review all security group rules
- [ ] Enable VPC for Lambda functions (optional)
- [ ] Configure custom domain with SSL
- [ ] Set up CloudTrail for audit logging
- [ ] Enable AWS Config for compliance
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
