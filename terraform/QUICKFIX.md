# Quick Fix for Deployment Issues

If you encounter deployment errors like:
```
Error: EntityAlreadyExists: Role with name duemate-production-lambda-execution already exists
Error: BucketAlreadyExists
Error: ResourceInUseException: Table already exists
```

## Quick Solution

Run this command to import existing resources:

```bash
cd terraform
./import-resources.sh production duemate
terraform plan
terraform apply
```

## What This Does

1. Imports all existing AWS resources into Terraform state
2. Prevents Terraform from trying to recreate them
3. Allows deployment to continue normally

## For More Details

See [terraform/IMPORT_EXISTING_RESOURCES.md](terraform/IMPORT_EXISTING_RESOURCES.md) for comprehensive documentation.

## Environment Options

- Development: `./import-resources.sh dev duemate`
- Staging: `./import-resources.sh staging duemate`
- Production: `./import-resources.sh production duemate`
- Customer-specific: `./import-resources.sh production duemate customer-name`
