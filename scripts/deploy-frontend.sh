#!/bin/bash

# Deploy Frontend to AWS S3 and CloudFront
# Usage: ./deploy-frontend.sh <environment>

set -e

ENVIRONMENT=${1:-dev}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
FRONTEND_DIR="$PROJECT_ROOT/frontend"

echo "==============================================="
echo "Deploying Frontend to $ENVIRONMENT"
echo "==============================================="

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI is not installed"
    exit 1
fi

# Check if frontend directory exists
if [ ! -d "$FRONTEND_DIR" ]; then
    echo "Error: Frontend directory not found at $FRONTEND_DIR"
    echo "Skipping frontend deployment"
    exit 0
fi

# Navigate to frontend directory
cd "$FRONTEND_DIR"

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "Installing frontend dependencies..."
    npm install
fi

# Build frontend
echo "Building frontend..."
npm run build

# Check if build directory exists
if [ ! -d "dist" ] && [ ! -d "build" ]; then
    echo "Error: Build directory not found. Expected 'dist' or 'build'"
    exit 1
fi

BUILD_DIR="dist"
if [ -d "build" ]; then
    BUILD_DIR="build"
fi

# Get S3 bucket name from Terraform output or environment variable
BUCKET_NAME="${S3_BUCKET_NAME:-duemate-${ENVIRONMENT}-frontend}"

echo ""
echo "Deploying to S3 bucket: $BUCKET_NAME"

# Sync files to S3
echo "Uploading files to S3..."
aws s3 sync "$BUILD_DIR/" "s3://$BUCKET_NAME/" \
    --delete \
    --cache-control "public, max-age=31536000" \
    --exclude "*.html" \
    --exclude "index.html"

# Upload HTML files with different cache settings
echo "Uploading HTML files..."
aws s3 sync "$BUILD_DIR/" "s3://$BUCKET_NAME/" \
    --cache-control "no-cache, no-store, must-revalidate" \
    --exclude "*" \
    --include "*.html"

# Get CloudFront distribution ID
DISTRIBUTION_ID=$(aws cloudfront list-distributions \
    --query "DistributionList.Items[?Origins.Items[?contains(DomainName, '$BUCKET_NAME')]].Id | [0]" \
    --output text)

if [ -n "$DISTRIBUTION_ID" ] && [ "$DISTRIBUTION_ID" != "None" ]; then
    echo ""
    echo "Creating CloudFront invalidation..."
    INVALIDATION_ID=$(aws cloudfront create-invalidation \
        --distribution-id "$DISTRIBUTION_ID" \
        --paths "/*" \
        --query 'Invalidation.Id' \
        --output text)
    
    echo "Invalidation created: $INVALIDATION_ID"
    echo "CloudFront cache will be refreshed shortly"
else
    echo ""
    echo "Warning: CloudFront distribution not found"
    echo "Files uploaded to S3 but no cache invalidation performed"
fi

echo ""
echo "==============================================="
echo "✓ Frontend deployed successfully!"
echo "==============================================="
echo ""
echo "Environment: $ENVIRONMENT"
echo "S3 Bucket: $BUCKET_NAME"
if [ -n "$DISTRIBUTION_ID" ] && [ "$DISTRIBUTION_ID" != "None" ]; then
    echo "CloudFront Distribution: $DISTRIBUTION_ID"
fi
echo ""
echo "Next steps:"
echo "  1. Access the frontend URL (check Terraform outputs)"
echo "  2. Verify deployment: aws s3 ls s3://$BUCKET_NAME/"
echo "  3. Test the application"
echo ""
