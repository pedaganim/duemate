# Terraform Quick Reference Guide

## Common Commands

### Initialization and Planning

```bash
# Initialize Terraform (download providers, setup backend)
terraform init

# Re-initialize after adding new modules
terraform init -upgrade

# Validate configuration files
terraform validate

# Format code to canonical format
terraform fmt -recursive

# Check what changes will be made
terraform plan

# Save plan to a file
terraform plan -out=tfplan

# Plan with specific variable file
terraform plan -var-file="custom.tfvars"
```

### Applying Changes

```bash
# Apply changes (will prompt for confirmation)
terraform apply

# Apply saved plan
terraform apply tfplan

# Auto-approve without prompting (use with caution)
terraform apply -auto-approve

# Apply with specific variables
terraform apply -var="environment=staging"
```

### Viewing State and Outputs

```bash
# Show all outputs
terraform output

# Show specific output
terraform output api_gateway_endpoint

# Show in JSON format
terraform output -json

# List all resources in state
terraform state list

# Show details of specific resource
terraform state show module.dynamodb.aws_dynamodb_table.main

# View current state file
terraform show

# Refresh state from actual infrastructure
terraform refresh
```

### Importing Existing Resources

```bash
# Import existing AWS resource into Terraform state
terraform import module.dynamodb.aws_dynamodb_table.main duemate-dev-main

# Examples:
terraform import module.s3.aws_s3_bucket.frontend duemate-dev-frontend
terraform import module.cognito.aws_cognito_user_pool.main us-east-1_abc123def
```

### Destroying Resources

```bash
# Destroy all resources (will prompt for confirmation)
terraform destroy

# Destroy specific resource
terraform destroy -target=module.lambda_functions

# Auto-approve destruction (DANGEROUS)
terraform destroy -auto-approve
```

### Workspace Management

```bash
# List workspaces
terraform workspace list

# Create new workspace
terraform workspace new staging

# Switch workspace
terraform workspace select production

# Show current workspace
terraform workspace show

# Delete workspace
terraform workspace delete staging
```

### State Management

```bash
# Pull remote state
terraform state pull > terraform.tfstate.backup

# Push local state to remote
terraform state push terraform.tfstate

# Move resource in state (rename)
terraform state mv module.old.resource module.new.resource

# Remove resource from state (doesn't destroy)
terraform state rm module.resource

# Replace resource (force recreation)
terraform apply -replace="module.lambda_functions.aws_lambda_function.invoice_create"
```

### Advanced Operations

```bash
# Show dependency graph
terraform graph | dot -Tpng > graph.png

# Unlock state (if locked)
terraform force-unlock <LOCK_ID>

# Taint resource (mark for recreation)
terraform taint module.lambda_functions.aws_lambda_function.invoice_create

# Untaint resource
terraform untaint module.lambda_functions.aws_lambda_function.invoice_create

# Console for testing expressions
terraform console
# Try: module.dynamodb.table_name
```

### Debugging

```bash
# Enable detailed logging
export TF_LOG=DEBUG
terraform apply

# Log levels: TRACE, DEBUG, INFO, WARN, ERROR
export TF_LOG=TRACE

# Save logs to file
export TF_LOG_PATH=terraform.log

# Disable logging
unset TF_LOG
unset TF_LOG_PATH
```

### Module-Specific Commands

```bash
# Get modules (download external modules)
terraform get

# Update modules
terraform get -update

# View module dependencies
terraform providers
```

## Environment-Specific Deployments

### Development

```bash
cd terraform/environments/dev
terraform init
terraform plan
terraform apply
```

### Staging

```bash
cd terraform/environments/staging
terraform init
terraform plan
terraform apply
```

### Production

```bash
cd terraform/environments/production
terraform init
terraform plan
terraform apply -var-file="production.tfvars"
```

## Common Workflows

### Initial Deployment

```bash
# 1. Configure variables
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars

# 2. Initialize
terraform init

# 3. Validate
terraform validate

# 4. Plan
terraform plan

# 5. Apply
terraform apply
```

### Updating Infrastructure

```bash
# 1. Pull latest code
git pull

# 2. Review changes
terraform plan

# 3. Apply changes
terraform apply
```

### Rolling Back Changes

```bash
# 1. Identify good state version
terraform state pull > current.tfstate

# 2. If using S3 backend, restore previous version
aws s3 cp s3://bucket/terraform.tfstate.backup ./

# 3. Push restored state (DANGEROUS - use with caution)
terraform state push terraform.tfstate.backup
```

### Migrating State

```bash
# From local to S3 backend
# 1. Update versions.tf with backend config
# 2. Initialize with migration
terraform init -migrate-state

# 3. Verify migration
terraform state pull
```

## Best Practices

1. **Always run `plan` before `apply`**
   ```bash
   terraform plan && terraform apply
   ```

2. **Use workspaces or separate directories for environments**
   ```bash
   # Use separate directories (recommended)
   cd environments/production
   ```

3. **Lock state file for team collaboration**
   ```bash
   # Use S3 backend with DynamoDB locking
   # Configure in versions.tf
   ```

4. **Tag all resources**
   ```bash
   # Use default_tags in provider configuration
   ```

5. **Version control everything except secrets**
   ```bash
   # Add to .gitignore:
   # *.tfvars (except .example)
   # terraform.tfstate
   # .terraform/
   ```

6. **Use variables for configurable values**
   ```bash
   terraform apply -var="instance_type=t3.micro"
   ```

7. **Protect production state**
   ```bash
   # Enable S3 versioning
   # Enable DynamoDB locking
   # Restrict IAM permissions
   ```

## Troubleshooting

### State Lock Issues

```bash
# View lock info
terraform force-unlock -help

# Force unlock (use carefully)
terraform force-unlock <LOCK_ID>
```

### Resource Already Exists

```bash
# Import existing resource
terraform import <resource_address> <resource_id>
```

### Provider Version Conflicts

```bash
# Upgrade providers to match constraints
terraform init -upgrade
```

### State Drift Detection

```bash
# Compare state with actual infrastructure
terraform plan -refresh-only

# Update state to match reality (no changes)
terraform apply -refresh-only
```

## Useful Aliases

Add to your `.bashrc` or `.zshrc`:

```bash
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tfo='terraform output'
alias tfs='terraform state'
alias tfv='terraform validate'
alias tff='terraform fmt -recursive'
```

## Reference Links

- Terraform Documentation: https://www.terraform.io/docs
- AWS Provider: https://registry.terraform.io/providers/hashicorp/aws
- Terraform Registry: https://registry.terraform.io/
- Best Practices: https://www.terraform.io/docs/cloud/guides/recommended-practices

---

**Created:** 2025-10-27  
**Last Updated:** 2025-10-27
