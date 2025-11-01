#!/bin/bash

# Import Existing Resources Script
# This script imports existing AWS resources into Terraform state

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check arguments
if [ $# -lt 1 ]; then
    echo "Usage: $0 <environment> [project_name] [customer_name]"
    echo "Example: $0 production duemate"
    echo "Example: $0 dev duemate acme"
    exit 1
fi

ENVIRONMENT=$1
PROJECT_NAME=${2:-duemate}
CUSTOMER_NAME=$3

# Set name prefix based on customer
if [ -n "$CUSTOMER_NAME" ]; then
    NAME_PREFIX="${PROJECT_NAME}-${CUSTOMER_NAME}-${ENVIRONMENT}"
else
    NAME_PREFIX="${PROJECT_NAME}-${ENVIRONMENT}"
fi

print_info "Importing resources for environment: $ENVIRONMENT"
print_info "Name prefix: $NAME_PREFIX"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed. Please install it first."
    exit 1
fi

# Get AWS Account ID
print_info "Getting AWS Account ID..."
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
if [ $? -ne 0 ]; then
    print_error "Failed to get AWS Account ID. Please check your AWS credentials."
    exit 1
fi
print_info "AWS Account ID: $AWS_ACCOUNT_ID"

# Get AWS Region
AWS_REGION=${AWS_REGION:-us-east-1}
print_info "AWS Region: $AWS_REGION"

# Initialize Terraform if needed
if [ ! -d ".terraform" ]; then
    print_info "Initializing Terraform..."
    terraform init
fi

# Function to import resource with error handling
import_resource() {
    local resource_type=$1
    local resource_address=$2
    local resource_id=$3
    local resource_name=$4
    
    print_info "Importing $resource_name..."
    
    # Check if resource exists in state
    if terraform state show "$resource_address" &> /dev/null; then
        print_warn "$resource_name already exists in state. Skipping."
        return 0
    fi
    
    # Try to import
    if terraform import "$resource_address" "$resource_id" 2>&1 | tee /tmp/import.log; then
        print_info "Successfully imported $resource_name"
        return 0
    else
        # Check if resource doesn't exist in AWS
        if grep -q "Cannot import non-existent remote object" /tmp/import.log || \
           grep -q "does not exist" /tmp/import.log || \
           grep -q "NotFound" /tmp/import.log; then
            print_warn "$resource_name does not exist in AWS. Terraform will create it."
            return 0
        else
            print_error "Failed to import $resource_name"
            cat /tmp/import.log
            return 1
        fi
    fi
}

# Track success/failure
TOTAL=0
SUCCESS=0
FAILED=0
SKIPPED=0

# Import IAM Role
TOTAL=$((TOTAL + 1))
import_resource "aws_iam_role" \
    "aws_iam_role.lambda_execution" \
    "${NAME_PREFIX}-lambda-execution" \
    "IAM Role (lambda_execution)" && SUCCESS=$((SUCCESS + 1)) || FAILED=$((FAILED + 1))

# Import IAM Policies
TOTAL=$((TOTAL + 1))
import_resource "aws_iam_policy" \
    "aws_iam_policy.lambda_dynamodb" \
    "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${NAME_PREFIX}-lambda-dynamodb" \
    "IAM Policy (lambda_dynamodb)" && SUCCESS=$((SUCCESS + 1)) || FAILED=$((FAILED + 1))

TOTAL=$((TOTAL + 1))
import_resource "aws_iam_policy" \
    "aws_iam_policy.lambda_s3" \
    "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${NAME_PREFIX}-lambda-s3" \
    "IAM Policy (lambda_s3)" && SUCCESS=$((SUCCESS + 1)) || FAILED=$((FAILED + 1))

TOTAL=$((TOTAL + 1))
import_resource "aws_iam_policy" \
    "aws_iam_policy.lambda_sqs" \
    "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${NAME_PREFIX}-lambda-sqs" \
    "IAM Policy (lambda_sqs)" && SUCCESS=$((SUCCESS + 1)) || FAILED=$((FAILED + 1))

TOTAL=$((TOTAL + 1))
import_resource "aws_iam_policy" \
    "aws_iam_policy.lambda_ses" \
    "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${NAME_PREFIX}-lambda-ses" \
    "IAM Policy (lambda_ses)" && SUCCESS=$((SUCCESS + 1)) || FAILED=$((FAILED + 1))

TOTAL=$((TOTAL + 1))
import_resource "aws_iam_policy" \
    "aws_iam_policy.lambda_secrets" \
    "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${NAME_PREFIX}-lambda-secrets" \
    "IAM Policy (lambda_secrets)" && SUCCESS=$((SUCCESS + 1)) || FAILED=$((FAILED + 1))

# Import API Gateway IAM Role (conditional resource)
# This resource is only created when manage_account_settings = true (default: true)
# in the API Gateway module. It's used to give API Gateway permission to write logs to CloudWatch.
# NOTE: If this resource doesn't exist in AWS (because manage_account_settings = false),
#       the import_resource function will detect this and return success (code 0), allowing
#       Terraform to create the resource if needed. The function only returns failure (code 1)
#       if the import fails for reasons other than the resource not existing.
TOTAL=$((TOTAL + 1))
import_resource "aws_iam_role" \
    "module.api_gateway.aws_iam_role.api_gateway_cloudwatch[0]" \
    "${NAME_PREFIX}-api-cloudwatch-role" \
    "IAM Role (api_gateway_cloudwatch)" && SUCCESS=$((SUCCESS + 1)) || FAILED=$((FAILED + 1))

# Import API Gateway CloudWatch Log Group (conditional resource)
# This resource is only created when enable_logging = true (default: true) in the API Gateway module.
# It stores API Gateway access logs.
# NOTE: If this resource doesn't exist in AWS (because enable_logging = false),
#       the import_resource function will detect this and return success (code 0), allowing
#       Terraform to create the resource if needed. The function only returns failure (code 1)
#       if the import fails for reasons other than the resource not existing.
TOTAL=$((TOTAL + 1))
import_resource "aws_cloudwatch_log_group" \
    "module.api_gateway.aws_cloudwatch_log_group.api_gateway[0]" \
    "/aws/apigateway/${NAME_PREFIX}-api" \
    "CloudWatch Log Group (api_gateway)" && SUCCESS=$((SUCCESS + 1)) || FAILED=$((FAILED + 1))

# Import Cognito User Pool
# We need to get the user pool ID by listing pools and filtering by name
print_info "Looking up Cognito User Pool ID for ${NAME_PREFIX}-users..."
USER_POOL_ID=$(aws cognito-idp list-user-pools --max-results 60 --query "UserPools[?Name=='${NAME_PREFIX}-users'].Id" --output text 2>/dev/null || echo "")

if [ -n "$USER_POOL_ID" ]; then
    print_info "Found User Pool ID: $USER_POOL_ID"
    TOTAL=$((TOTAL + 1))
    import_resource "aws_cognito_user_pool" \
        "module.cognito.aws_cognito_user_pool.main" \
        "$USER_POOL_ID" \
        "Cognito User Pool" && SUCCESS=$((SUCCESS + 1)) || FAILED=$((FAILED + 1))
    
    # Import Cognito User Pool Client
    # Get the client ID from the user pool
    print_info "Looking up Cognito User Pool Client ID..."
    CLIENT_ID=$(aws cognito-idp list-user-pool-clients --user-pool-id "$USER_POOL_ID" --max-results 60 --query "UserPoolClients[?ClientName=='${NAME_PREFIX}-users-client'].ClientId" --output text 2>/dev/null || echo "")
    
    if [ -n "$CLIENT_ID" ]; then
        print_info "Found Client ID: $CLIENT_ID"
        TOTAL=$((TOTAL + 1))
        import_resource "aws_cognito_user_pool_client" \
            "module.cognito.aws_cognito_user_pool_client.main" \
            "${USER_POOL_ID}/${CLIENT_ID}" \
            "Cognito User Pool Client" && SUCCESS=$((SUCCESS + 1)) || FAILED=$((FAILED + 1))
    else
        print_warn "Cognito User Pool Client not found, Terraform will create it"
    fi
else
    print_warn "Cognito User Pool not found, Terraform will create it"
fi

# Import Cognito User Pool Domain
TOTAL=$((TOTAL + 1))
import_resource "aws_cognito_user_pool_domain" \
    "module.cognito.aws_cognito_user_pool_domain.main" \
    "${NAME_PREFIX}-users" \
    "Cognito User Pool Domain" && SUCCESS=$((SUCCESS + 1)) || FAILED=$((FAILED + 1))

# Import DynamoDB Table
TOTAL=$((TOTAL + 1))
import_resource "aws_dynamodb_table" \
    "module.dynamodb.aws_dynamodb_table.main" \
    "${NAME_PREFIX}-main" \
    "DynamoDB Table" && SUCCESS=$((SUCCESS + 1)) || FAILED=$((FAILED + 1))

# Import S3 Buckets
TOTAL=$((TOTAL + 1))
import_resource "aws_s3_bucket" \
    "module.s3.aws_s3_bucket.frontend" \
    "${NAME_PREFIX}-frontend" \
    "S3 Bucket (frontend)" && SUCCESS=$((SUCCESS + 1)) || FAILED=$((FAILED + 1))

TOTAL=$((TOTAL + 1))
import_resource "aws_s3_bucket" \
    "module.s3.aws_s3_bucket.invoices" \
    "${NAME_PREFIX}-invoices" \
    "S3 Bucket (invoices)" && SUCCESS=$((SUCCESS + 1)) || FAILED=$((FAILED + 1))

TOTAL=$((TOTAL + 1))
import_resource "aws_s3_bucket" \
    "module.s3.aws_s3_bucket.assets" \
    "${NAME_PREFIX}-assets" \
    "S3 Bucket (assets)" && SUCCESS=$((SUCCESS + 1)) || FAILED=$((FAILED + 1))

# Import Lambda Functions
TOTAL=$((TOTAL + 1))
import_resource "aws_lambda_function" \
    "module.lambda_functions.aws_lambda_function.invoice_create" \
    "${NAME_PREFIX}-invoice-create" \
    "Lambda Function (invoice_create)" && SUCCESS=$((SUCCESS + 1)) || FAILED=$((FAILED + 1))

TOTAL=$((TOTAL + 1))
import_resource "aws_lambda_function" \
    "module.lambda_functions.aws_lambda_function.invoice_get" \
    "${NAME_PREFIX}-invoice-get" \
    "Lambda Function (invoice_get)" && SUCCESS=$((SUCCESS + 1)) || FAILED=$((FAILED + 1))

TOTAL=$((TOTAL + 1))
import_resource "aws_lambda_function" \
    "module.lambda_functions.aws_lambda_function.reminder_check" \
    "${NAME_PREFIX}-reminder-check" \
    "Lambda Function (reminder_check)" && SUCCESS=$((SUCCESS + 1)) || FAILED=$((FAILED + 1))

TOTAL=$((TOTAL + 1))
import_resource "aws_lambda_function" \
    "module.lambda_functions.aws_lambda_function.notification_worker" \
    "${NAME_PREFIX}-notification-worker" \
    "Lambda Function (notification_worker)" && SUCCESS=$((SUCCESS + 1)) || FAILED=$((FAILED + 1))

# Import CloudWatch Log Groups for Lambda Functions
TOTAL=$((TOTAL + 1))
import_resource "aws_cloudwatch_log_group" \
    "module.lambda_functions.aws_cloudwatch_log_group.invoice_create" \
    "/aws/lambda/${NAME_PREFIX}-invoice-create" \
    "CloudWatch Log Group (invoice_create)" && SUCCESS=$((SUCCESS + 1)) || FAILED=$((FAILED + 1))

TOTAL=$((TOTAL + 1))
import_resource "aws_cloudwatch_log_group" \
    "module.lambda_functions.aws_cloudwatch_log_group.invoice_get" \
    "/aws/lambda/${NAME_PREFIX}-invoice-get" \
    "CloudWatch Log Group (invoice_get)" && SUCCESS=$((SUCCESS + 1)) || FAILED=$((FAILED + 1))

TOTAL=$((TOTAL + 1))
import_resource "aws_cloudwatch_log_group" \
    "module.lambda_functions.aws_cloudwatch_log_group.reminder_check" \
    "/aws/lambda/${NAME_PREFIX}-reminder-check" \
    "CloudWatch Log Group (reminder_check)" && SUCCESS=$((SUCCESS + 1)) || FAILED=$((FAILED + 1))

TOTAL=$((TOTAL + 1))
import_resource "aws_cloudwatch_log_group" \
    "module.lambda_functions.aws_cloudwatch_log_group.notification_worker" \
    "/aws/lambda/${NAME_PREFIX}-notification-worker" \
    "CloudWatch Log Group (notification_worker)" && SUCCESS=$((SUCCESS + 1)) || FAILED=$((FAILED + 1))

# Import EventBridge Resources
TOTAL=$((TOTAL + 1))
import_resource "aws_cloudwatch_event_rule" \
    "module.eventbridge.aws_cloudwatch_event_rule.reminder_check" \
    "${NAME_PREFIX}-reminder-check" \
    "EventBridge Rule (reminder_check)" && SUCCESS=$((SUCCESS + 1)) || FAILED=$((FAILED + 1))

TOTAL=$((TOTAL + 1))
import_resource "aws_cloudwatch_event_target" \
    "module.eventbridge.aws_cloudwatch_event_target.reminder_check" \
    "${NAME_PREFIX}-reminder-check/ReminderCheckLambda" \
    "EventBridge Target (reminder_check)" && SUCCESS=$((SUCCESS + 1)) || FAILED=$((FAILED + 1))

TOTAL=$((TOTAL + 1))
import_resource "aws_lambda_permission" \
    "module.eventbridge.aws_lambda_permission.allow_eventbridge" \
    "${NAME_PREFIX}-reminder-check/${NAME_PREFIX}-AllowExecutionFromEventBridge" \
    "Lambda Permission (allow_eventbridge)" && SUCCESS=$((SUCCESS + 1)) || FAILED=$((FAILED + 1))

# Print summary
echo ""
print_info "============================================"
print_info "Import Summary"
print_info "============================================"
print_info "Total resources: $TOTAL"
print_info "Successfully imported: $SUCCESS"
if [ $FAILED -gt 0 ]; then
    print_error "Failed: $FAILED"
fi
print_info "============================================"

if [ $FAILED -gt 0 ]; then
    print_error "Some resources failed to import. Please review the errors above."
    echo ""
    print_info "Next steps:"
    print_info "1. Check the errors for resources that failed to import"
    print_info "2. Verify the resource names and IDs are correct"
    print_info "3. Run 'terraform plan' to see what changes are needed"
    exit 1
else
    print_info "All resources imported successfully!"
    echo ""
    print_info "Next steps:"
    print_info "1. Run 'terraform plan' to verify the state matches your infrastructure"
    print_info "2. If the plan shows unexpected changes, review and adjust the configuration"
    print_info "3. Run 'terraform apply' when ready to sync any remaining differences"
fi

# Cleanup
rm -f /tmp/import.log
