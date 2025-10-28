#!/bin/bash

# Verify AWS deployment
# Usage: ./verify-deployment.sh <environment>

set -e

ENVIRONMENT=${1:-dev}
AWS_REGION=${AWS_REGION:-us-east-1}

echo "==============================================="
echo "Verifying Deployment for $ENVIRONMENT"
echo "==============================================="
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if a resource exists
check_resource() {
    local resource_type=$1
    local resource_name=$2
    local check_command=$3
    
    echo -n "Checking $resource_type: $resource_name... "
    
    if eval "$check_command" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Found${NC}"
        return 0
    else
        echo -e "${RED}✗ Not found${NC}"
        return 1
    fi
}

# Track failures
FAILURES=0

echo "=== DynamoDB Tables ==="
if check_resource "DynamoDB Table" "duemate-${ENVIRONMENT}-main" \
    "aws dynamodb describe-table --table-name duemate-${ENVIRONMENT}-main --region $AWS_REGION"; then
    # Get table item count
    ITEM_COUNT=$(aws dynamodb scan --table-name "duemate-${ENVIRONMENT}-main" \
        --select "COUNT" --region "$AWS_REGION" --query 'Count' --output text 2>/dev/null || echo "0")
    echo "  Items in table: $ITEM_COUNT"
else
    ((FAILURES++))
fi
echo ""

echo "=== Lambda Functions ==="
LAMBDA_FUNCTIONS=(
    "invoice-create"
    "invoice-list"
    "invoice-get"
    "invoice-update"
    "invoice-delete"
    "invoice-pdf"
    "client-create"
    "client-list"
    "client-get"
    "client-update"
    "client-delete"
    "reminder-create"
    "reminder-check"
    "reminder-send"
    "notification-worker"
)

for func in "${LAMBDA_FUNCTIONS[@]}"; do
    FULL_NAME="duemate-${ENVIRONMENT}-${func}"
    if check_resource "Lambda" "$FULL_NAME" \
        "aws lambda get-function --function-name $FULL_NAME --region $AWS_REGION"; then
        # Get function status
        STATE=$(aws lambda get-function --function-name "$FULL_NAME" --region "$AWS_REGION" \
            --query 'Configuration.State' --output text 2>/dev/null || echo "Unknown")
        LAST_MODIFIED=$(aws lambda get-function --function-name "$FULL_NAME" --region "$AWS_REGION" \
            --query 'Configuration.LastModified' --output text 2>/dev/null || echo "Unknown")
        echo "  State: $STATE, Last Modified: $LAST_MODIFIED"
    else
        ((FAILURES++))
    fi
done
echo ""

echo "=== API Gateway ==="
if check_resource "API Gateway" "duemate-${ENVIRONMENT}-api" \
    "aws apigateway get-rest-apis --region $AWS_REGION --query 'items[?name==\`duemate-${ENVIRONMENT}-api\`]' --output text"; then
    API_ID=$(aws apigateway get-rest-apis --region "$AWS_REGION" \
        --query "items[?name==\`duemate-${ENVIRONMENT}-api\`].id" --output text 2>/dev/null || echo "")
    if [ -n "$API_ID" ]; then
        echo "  API ID: $API_ID"
        echo "  Endpoint: https://${API_ID}.execute-api.${AWS_REGION}.amazonaws.com/prod"
    fi
else
    ((FAILURES++))
fi
echo ""

echo "=== S3 Buckets ==="
S3_BUCKETS=(
    "duemate-${ENVIRONMENT}-frontend"
    "duemate-${ENVIRONMENT}-invoices"
    "duemate-${ENVIRONMENT}-assets"
)

for bucket in "${S3_BUCKETS[@]}"; do
    if check_resource "S3 Bucket" "$bucket" \
        "aws s3 ls s3://$bucket --region $AWS_REGION"; then
        OBJECT_COUNT=$(aws s3 ls "s3://$bucket" --recursive --region "$AWS_REGION" 2>/dev/null | wc -l || echo "0")
        echo "  Objects: $OBJECT_COUNT"
    else
        ((FAILURES++))
    fi
done
echo ""

echo "=== Cognito User Pool ==="
USER_POOLS=$(aws cognito-idp list-user-pools --max-results 60 --region "$AWS_REGION" \
    --query "UserPools[?contains(Name, 'duemate-${ENVIRONMENT}')].Name" --output text 2>/dev/null || echo "")
if [ -n "$USER_POOLS" ]; then
    echo -e "${GREEN}✓ Found${NC} user pool(s): $USER_POOLS"
else
    echo -e "${YELLOW}⚠ No user pool found${NC}"
fi
echo ""

echo "=== SQS Queues ==="
SQS_QUEUES=(
    "duemate-${ENVIRONMENT}-notifications"
    "duemate-${ENVIRONMENT}-notifications-dlq"
)

for queue in "${SQS_QUEUES[@]}"; do
    QUEUE_URL=$(aws sqs get-queue-url --queue-name "$queue" --region "$AWS_REGION" \
        --query 'QueueUrl' --output text 2>/dev/null || echo "")
    if [ -n "$QUEUE_URL" ]; then
        echo -e "${GREEN}✓ Found${NC} SQS Queue: $queue"
        # Get approximate message count
        MSG_COUNT=$(aws sqs get-queue-attributes --queue-url "$QUEUE_URL" --region "$AWS_REGION" \
            --attribute-names ApproximateNumberOfMessages \
            --query 'Attributes.ApproximateNumberOfMessages' --output text 2>/dev/null || echo "0")
        echo "  Messages in queue: $MSG_COUNT"
    else
        echo -e "${RED}✗ Not found${NC} SQS Queue: $queue"
        ((FAILURES++))
    fi
done
echo ""

echo "=== CloudWatch Log Groups ==="
LOG_GROUPS=$(aws logs describe-log-groups --region "$AWS_REGION" \
    --log-group-name-prefix "/aws/lambda/duemate-${ENVIRONMENT}" \
    --query 'logGroups[*].logGroupName' --output text 2>/dev/null || echo "")
LOG_GROUP_COUNT=$(echo "$LOG_GROUPS" | wc -w)
echo -e "${GREEN}✓ Found${NC} $LOG_GROUP_COUNT log group(s)"
echo ""

echo "==============================================="
echo "Verification Summary"
echo "==============================================="
echo ""

if [ $FAILURES -eq 0 ]; then
    echo -e "${GREEN}✓ All resources verified successfully!${NC}"
    echo ""
    echo "Deployment Status: ${GREEN}HEALTHY${NC}"
    exit 0
else
    echo -e "${RED}✗ Found $FAILURES missing or failed resource(s)${NC}"
    echo ""
    echo "Deployment Status: ${YELLOW}INCOMPLETE${NC}"
    echo ""
    echo "Please check:"
    echo "  1. Terraform apply completed successfully"
    echo "  2. AWS credentials are correct"
    echo "  3. Resources are in the correct region: $AWS_REGION"
    exit 1
fi
