#!/bin/bash

# Deploy Lambda Functions to AWS
# Usage: ./deploy-lambda.sh <environment>

set -e

ENVIRONMENT=${1:-dev}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "==============================================="
echo "Deploying Lambda Functions to $ENVIRONMENT"
echo "==============================================="

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI is not installed"
    exit 1
fi

# Check if required files exist
if [ ! -d "$PROJECT_ROOT/dist" ]; then
    echo "Error: dist directory not found. Run 'npm run build' first"
    exit 1
fi

# Function to package and deploy a Lambda function
deploy_lambda() {
    local function_name=$1
    local description=$2
    
    echo ""
    echo "-------------------------------------------"
    echo "Deploying: $function_name"
    echo "Description: $description"
    echo "-------------------------------------------"
    
    # Create temporary deployment package directory
    TEMP_DIR=$(mktemp -d)
    
    # Copy application code
    cp -r "$PROJECT_ROOT/dist"/* "$TEMP_DIR/"
    cp -r "$PROJECT_ROOT/node_modules" "$TEMP_DIR/"
    cp "$PROJECT_ROOT/package.json" "$TEMP_DIR/"
    
    # Copy Prisma files if they exist
    if [ -d "$PROJECT_ROOT/prisma" ]; then
        cp -r "$PROJECT_ROOT/prisma" "$TEMP_DIR/"
    fi
    
    # Create deployment package
    cd "$TEMP_DIR"
    zip -r -q function.zip . > /dev/null
    
    # Get the full Lambda function name
    FULL_FUNCTION_NAME="duemate-${ENVIRONMENT}-${function_name}"
    
    # Check if function exists
    if aws lambda get-function --function-name "$FULL_FUNCTION_NAME" > /dev/null 2>&1; then
        echo "Updating existing function: $FULL_FUNCTION_NAME"
        aws lambda update-function-code \
            --function-name "$FULL_FUNCTION_NAME" \
            --zip-file "fileb://function.zip" \
            --publish > /dev/null
        
        echo "✓ Function updated successfully"
    else
        echo "Function does not exist: $FULL_FUNCTION_NAME"
        echo "Skipping (function should be created by Terraform)"
    fi
    
    # Cleanup
    cd "$PROJECT_ROOT"
    rm -rf "$TEMP_DIR"
}

# Deploy all Lambda functions
echo ""
echo "Starting Lambda deployment..."

# API Lambda functions
deploy_lambda "invoice-create" "Create new invoice"
deploy_lambda "invoice-list" "List invoices with filtering"
deploy_lambda "invoice-get" "Get invoice by ID"
deploy_lambda "invoice-update" "Update invoice"
deploy_lambda "invoice-delete" "Delete invoice"
deploy_lambda "invoice-pdf" "Generate invoice PDF"

# Client management functions
deploy_lambda "client-create" "Create new client"
deploy_lambda "client-list" "List clients"
deploy_lambda "client-get" "Get client by ID"
deploy_lambda "client-update" "Update client"
deploy_lambda "client-delete" "Delete client"

# Reminder functions
deploy_lambda "reminder-create" "Create reminder"
deploy_lambda "reminder-check" "Check and send reminders (scheduled)"
deploy_lambda "reminder-send" "Send individual reminder"

# Notification worker
deploy_lambda "notification-worker" "Process notification queue"

echo ""
echo "==============================================="
echo "✓ All Lambda functions deployed successfully!"
echo "==============================================="
echo ""
echo "Environment: $ENVIRONMENT"
echo "Region: ${AWS_REGION:-us-east-1}"
echo ""
echo "Next steps:"
echo "  1. Verify deployments: aws lambda list-functions --query 'Functions[?starts_with(FunctionName, \`duemate-$ENVIRONMENT\`)].FunctionName'"
echo "  2. Check logs: aws logs tail /aws/lambda/duemate-$ENVIRONMENT-invoice-create --follow"
echo "  3. Test API endpoints"
echo ""
