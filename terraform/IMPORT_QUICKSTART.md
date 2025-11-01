# Quick Start: Importing Existing Resources

This guide helps you quickly resolve "EntityAlreadyExists" errors when deploying with Terraform.

## Automatic Import (GitHub Actions)

**No action needed!** The deployment workflow automatically:
1. Detects existing AWS resources
2. Enables `import.tf` for automatic imports
3. Runs `import-resources.sh` to import all resources
4. Proceeds with terraform plan and apply

If the workflow fails, check the logs for the "Detect and Enable Import" step.

## Manual Import (Local Development)

If deploying locally and encountering "EntityAlreadyExists" errors:

```bash
cd terraform

# Run the comprehensive import script
chmod +x import-resources.sh
./import-resources.sh production duemate

# For whitelabel deployments with customer name:
./import-resources.sh production duemate acme

# Then run terraform normally
terraform plan
terraform apply
```

## What Gets Imported?

**All resources are imported by import-resources.sh**, including:
- ✅ IAM roles and policies (6 resources)
- ✅ DynamoDB tables
- ✅ S3 buckets (3 buckets)
- ✅ Lambda functions and log groups (8 resources)
- ✅ EventBridge rules and permissions (3 resources)
- ✅ API Gateway CloudWatch role and log group (if enabled)
- ✅ Cognito user pool, client, and domain (3 resources)

**Additionally, import.tf provides backup imports for 21 non-conditional resources**

## Understanding Import Errors

### Expected (OK) Messages
```
⚠️  Resource does not exist in AWS. Terraform will create it.
⚠️  Resource is not in configuration (likely count = 0). Skipping.
```
These are normal - the script handles them gracefully.

### Unexpected (Needs Action) Messages
```
❌ Failed to import <resource>
Error: authentication error
Error: invalid resource ID
```
These indicate real issues that need investigation.

## Troubleshooting

### Problem: "Domain already associated with another user pool"
**Cause**: Cognito user pool not imported before domain
**Solution**: Run `import-resources.sh` - it imports in correct order

### Problem: Import blocks fail during terraform plan
**Cause**: Trying to import conditional resources with count = 0
**Solution**: Use `import-resources.sh` instead of just import.tf

### Problem: "Resource address does not exist in configuration"
**Cause**: Conditional resource (count = 0) can't be imported
**Solution**: This is expected - the script returns success automatically

## For More Details

- **Complete fix documentation**: See `IMPORT_FIX.md`
- **Detailed import guide**: See `IMPORT_EXISTING_RESOURCES.md`
- **Terraform commands**: See `TERRAFORM_COMMANDS.md`

## Quick Decision Tree

```
Do resources already exist in AWS?
├─ NO → Just run terraform apply (no import needed)
└─ YES → Is this GitHub Actions deployment?
    ├─ YES → Workflow handles imports automatically
    └─ NO → Run ./import-resources.sh first, then terraform apply
```

## Common Commands

```bash
# Check if resources exist
aws dynamodb describe-table --table-name duemate-production-main
aws s3 ls s3://duemate-production-frontend
aws iam get-role --role-name duemate-production-lambda-execution

# Import all resources
./import-resources.sh production duemate

# Check what's in terraform state
terraform state list

# Remove resource from state (if needed)
terraform state rm aws_iam_role.lambda_execution

# Show resource in state
terraform state show aws_iam_role.lambda_execution
```

---

**Remember**: The import script is idempotent - safe to run multiple times!
