#!/bin/bash

# Run database migrations on AWS
# Usage: ./run-migrations.sh <environment>

set -e

ENVIRONMENT=${1:-dev}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "==============================================="
echo "Running Database Migrations for $ENVIRONMENT"
echo "==============================================="

# Check if DATABASE_URL is set
if [ -z "$DATABASE_URL" ]; then
    echo "Warning: DATABASE_URL environment variable not set"
    echo "Attempting to get from AWS Secrets Manager..."
    
    # Try to get DATABASE_URL from Secrets Manager
    SECRET_NAME="duemate-${ENVIRONMENT}/database"
    DATABASE_URL=$(aws secretsmanager get-secret-value \
        --secret-id "$SECRET_NAME" \
        --query 'SecretString' \
        --output text 2>/dev/null | jq -r '.url' || echo "")
    
    if [ -z "$DATABASE_URL" ]; then
        echo "Error: Could not retrieve DATABASE_URL"
        echo "Please set DATABASE_URL environment variable or store in Secrets Manager"
        exit 1
    fi
    
    export DATABASE_URL
fi

# Navigate to project root
cd "$PROJECT_ROOT"

# Check if Prisma is available
if [ ! -f "prisma/schema.prisma" ]; then
    echo "Error: Prisma schema not found"
    exit 1
fi

echo ""
echo "Running Prisma migrations..."

# Generate Prisma client
npm run prisma:generate

# Deploy migrations
npx prisma migrate deploy

echo ""
echo "==============================================="
echo "✓ Database migrations completed successfully!"
echo "==============================================="
echo ""
echo "Environment: $ENVIRONMENT"
echo ""
echo "Next steps:"
echo "  1. Verify database schema"
echo "  2. Test database connectivity from Lambda functions"
echo "  3. Run smoke tests"
echo ""
