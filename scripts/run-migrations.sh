#!/bin/bash

# Verify database setup for DueMate
# Usage: ./run-migrations.sh <environment>

set -e

ENVIRONMENT=${1:-dev}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "==============================================="
echo "Verifying Database Setup for $ENVIRONMENT"
echo "==============================================="

# Navigate to project root
cd "$PROJECT_ROOT"

# This project uses DynamoDB, which is provisioned by Terraform
# No traditional database migrations are needed
echo ""
echo "✓ DueMate uses DynamoDB (NoSQL database)"
echo "✓ DynamoDB tables are managed by Terraform infrastructure"
echo "✓ No database migrations required"
echo ""

# Verify DynamoDB table exists
TABLE_NAME="duemate-${ENVIRONMENT}-main"
echo "Verifying DynamoDB table: $TABLE_NAME"

# Get table description (single API call)
TABLE_INFO=$(aws dynamodb describe-table --table-name "$TABLE_NAME" 2>/dev/null || echo "")

if [ -n "$TABLE_INFO" ]; then
    echo "✓ DynamoDB table '$TABLE_NAME' exists and is accessible"
    
    # Check if jq is available for JSON parsing
    if command -v jq &> /dev/null; then
        # Parse using jq (more reliable)
        TABLE_STATUS=$(echo "$TABLE_INFO" | jq -r '.Table.TableStatus // "unknown"')
        ITEM_COUNT=$(echo "$TABLE_INFO" | jq -r '.Table.ItemCount // "unknown"')
    else
        # Fallback to grep parsing if jq not available
        TABLE_STATUS=$(echo "$TABLE_INFO" | grep -o '"TableStatus": *"[^"]*"' | cut -d'"' -f4 || echo "unknown")
        ITEM_COUNT=$(echo "$TABLE_INFO" | grep -o '"ItemCount": *[0-9]*' | grep -o '[0-9]*' || echo "unknown")
    fi
    
    echo "  Status: $TABLE_STATUS"
    echo "  Item count: $ITEM_COUNT (approximate)"
else
    echo "⚠ Warning: DynamoDB table '$TABLE_NAME' not found or not accessible"
    echo "  The table should be created by Terraform during infrastructure deployment"
    echo "  If this is a new deployment, ensure Terraform has been applied successfully"
    # Don't exit with error as table might be created later in deployment
fi

echo ""
echo "==============================================="
echo "✓ Database verification completed!"
echo "==============================================="
echo ""
echo "Environment: $ENVIRONMENT"
echo "Database: DynamoDB (NoSQL)"
echo "Table: $TABLE_NAME"
echo ""
echo "Next steps:"
echo "  1. Verify DynamoDB table has correct GSI indexes"
echo "  2. Test database connectivity from Lambda functions"
echo "  3. Run smoke tests"
echo ""
