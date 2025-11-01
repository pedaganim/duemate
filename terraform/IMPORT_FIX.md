# Terraform Import Fix - EntityAlreadyExists Error Resolution

## Problem
When running `terraform apply`, resources that already exist in AWS fail with errors like:
- `EntityAlreadyExists: Role with name X already exists`
- `BucketAlreadyExists`
- `ResourceInUseException: Table already exists`
- `Domain already associated with another user pool`

## Root Causes (Fixed)

### 1. Import Blocks Couldn't Reference Locals from main.tf
**Problem:** The `import.tf.example` file used `local.name_prefix` which is defined in `main.tf`. Import blocks are evaluated in a separate phase and cannot access locals from other files.

**Solution:** Added a local `import_name_prefix` variable within `import.tf.example` itself that replicates the naming logic using only variables (which ARE available in import blocks).

```hcl
# In import.tf.example
locals {
  import_name_prefix = var.customer_name != null ? 
    "${var.project_name}-${var.customer_name}-${var.environment}" : 
    "${var.project_name}-${var.environment}"
}
```

### 2. Import Script Ran Too Late
**Problem:** The manual import fallback step ran AFTER `terraform plan`, meaning resources weren't imported before Terraform tried to plan their creation.

**Solution:** Moved the import script execution into the detection step, so it runs BEFORE `terraform plan`:
```yaml
- name: Detect and Enable Import for Existing Resources
  run: |
    # ... detect resources ...
    if resources exist; then
      cp import.tf.example import.tf
      ./import-resources.sh  # ← Runs HERE, before plan
    fi

- name: Terraform Plan  # ← Import already completed
```

### 3. Cognito Domain Import Failed
**Problem:** Error "Domain already associated with another user pool" occurs when the domain exists but the Cognito user pool isn't in Terraform state.

**Solution:** Added dynamic Cognito user pool and client imports to `import-resources.sh`:
```bash
# Look up user pool ID by name
USER_POOL_ID=$(aws cognito-idp list-user-pools --max-results 60 \
  --query "UserPools[?Name=='${NAME_PREFIX}-users'].Id" --output text)

# Import user pool first
terraform import module.cognito.aws_cognito_user_pool.main "$USER_POOL_ID"

# Then import domain
terraform import module.cognito.aws_cognito_user_pool_domain.main "${NAME_PREFIX}-users"
```

## How It Works Now

1. **Workflow detects existing resources** - Checks AWS for key resources (DynamoDB tables, S3 buckets, IAM roles)
2. **Enables import configuration** - Copies `import.tf.example` to `import.tf`
3. **Runs import script immediately** - Executes `import-resources.sh` BEFORE terraform plan
4. **Import script dynamically discovers resource IDs** - For Cognito and other resources that need lookups
5. **Resources imported into state** - All existing resources are now tracked by Terraform
6. **Terraform plan runs** - Sees resources in state, doesn't try to recreate them
7. **Terraform apply succeeds** - No "EntityAlreadyExists" errors!

## Testing the Fix

To test if the fix is working:

```bash
# 1. Navigate to terraform directory
cd terraform

# 2. Test import detection (won't modify anything)
bash -x import-resources.sh production duemate

# 3. Check if import.tf is valid
cp import.tf.example /tmp/test.tf
terraform fmt /tmp/test.tf
terraform validate  # (after init)
```

## Manual Recovery

If you still encounter "EntityAlreadyExists" errors:

```bash
cd terraform

# Run import script manually
./import-resources.sh <environment> [project_name] [customer_name]

# Example for production
./import-resources.sh production duemate

# Example for whitelabel deployment
./import-resources.sh production duemate acme

# Then run terraform
terraform plan
terraform apply
```

### Limitations

**Cognito User Pool Lookup:** The import script lists up to 60 user pools when searching for the user pool by name. If your AWS account has more than 60 user pools, you may need to manually import:

```bash
# Find your user pool ID in AWS Console or via CLI
aws cognito-idp list-user-pools --max-results 100

# Manually import the user pool
terraform import module.cognito.aws_cognito_user_pool.main <your-pool-id>

# Then import the client
terraform import module.cognito.aws_cognito_user_pool_client.main <pool-id>/<client-id>

# Then import the domain
terraform import module.cognito.aws_cognito_user_pool_domain.main <domain-name>
```

### 4. Conditional Import Blocks Failed During Plan
**Problem:** Import blocks for conditional resources (with `count`) cause `terraform plan` to fail when the resource doesn't exist in the configuration.

Example: If `manage_account_settings = false`, then `module.api_gateway.aws_iam_role.api_gateway_cloudwatch[0]` doesn't exist in the configuration (count = 0). Import blocks that reference `[0]` will fail.

**Solution:** Removed conditional import blocks from `import.tf.example`. The manual import script (`import-resources.sh`) already handles these gracefully:
- Checks if resource exists in AWS before importing
- Returns success even if resource doesn't exist (Terraform will create it)
- Only fails if import fails for other reasons

Conditional resources removed from import.tf:
- `module.api_gateway.aws_iam_role.api_gateway_cloudwatch[0]`
- `module.api_gateway.aws_cloudwatch_log_group.api_gateway[0]`

## Files Changed

- `terraform/import.tf.example` - Fixed to use variables instead of locals, removed conditional import blocks
- `terraform/import-resources.sh` - Added Cognito user pool/client import logic
- `.github/workflows/deploy.yml` - Moved import execution before terraform plan
- `terraform/IMPORT_FIX.md` - Updated documentation
