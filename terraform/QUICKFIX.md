# Quick Fix for Deployment Issues

## Error 1: "Cannot import non-existent remote object"

If you see:
```
Error: Cannot import non-existent remote object

While attempting to import an existing object to
"module.lambda_functions.aws_lambda_function.notification_worker", the
provider detected that no object exists with the given id.
```

### Quick Solution

This happens when `import.tf` is enabled but resources don't exist yet.

**For new deployments:**
```bash
cd terraform
# Remove or rename the import.tf file
rm import.tf
# OR
mv import.tf import.tf.example

# Run terraform again
terraform plan
terraform apply
```

**Note**: The latest version of this repository ships with `import.tf.example` (disabled by default) to prevent this issue.

---

## Error 2: Resources Already Exist

If you encounter deployment errors like:
```
Error: EntityAlreadyExists: Role with name duemate-production-lambda-execution already exists
Error: BucketAlreadyExists
Error: ResourceInUseException: Table already exists
```

### Quick Solution

Enable import functionality to import existing resources:

```bash
cd terraform
# Enable import blocks
mv import.tf.example import.tf

# Run terraform
terraform plan
terraform apply

# Disable import blocks after successful import (optional but recommended)
mv import.tf import.tf.example
```

**Alternative**: Use the manual import script:
```bash
cd terraform
./import-resources.sh production duemate
terraform plan
terraform apply
```

---

## What These Solutions Do

**Solution 1 (Disable Import)**: Removes import blocks that try to import non-existent resources, allowing Terraform to create resources from scratch.

**Solution 2 (Enable Import)**: Imports existing AWS resources into Terraform state to prevent Terraform from trying to recreate them.

## For More Details

See [IMPORT_EXISTING_RESOURCES.md](./IMPORT_EXISTING_RESOURCES.md) for comprehensive documentation.

## Environment Options

- Development: `./import-resources.sh dev duemate`
- Staging: `./import-resources.sh staging duemate`
- Production: `./import-resources.sh production duemate`
- Customer-specific: `./import-resources.sh production duemate customer-name`
