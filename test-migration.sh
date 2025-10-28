#!/bin/bash

# Simple test script to validate the DynamoDB migration
# This script tests basic functionality without requiring a running DynamoDB instance

echo "================================"
echo "DueMate DynamoDB Migration Tests"
echo "================================"
echo ""

# Check if TypeScript compiles
echo "✓ Testing TypeScript compilation..."
npm run build > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "  ✓ TypeScript compilation: PASSED"
else
  echo "  ✗ TypeScript compilation: FAILED"
  exit 1
fi

# Check if key files exist
echo ""
echo "✓ Checking for required files..."

FILES=(
  "src/models/invoice.model.ts"
  "src/repositories/invoice.repository.ts"
  "src/config/database.ts"
  "src/services/invoice.service.ts"
  "src/services/pdf.service.ts"
  "DYNAMODB_SETUP.md"
)

for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "  ✓ $file exists"
  else
    echo "  ✗ $file missing"
    exit 1
  fi
done

# Check that Prisma files are removed
echo ""
echo "✓ Verifying Prisma cleanup..."

REMOVED_FILES=(
  "prisma/schema.prisma"
  "prisma.config.ts"
)

for file in "${REMOVED_FILES[@]}"; do
  if [ ! -f "$file" ]; then
    echo "  ✓ $file removed"
  else
    echo "  ✗ $file still exists (should be removed)"
    exit 1
  fi
done

# Check package.json for Prisma references
echo ""
echo "✓ Checking package.json..."

if grep -q "@prisma/client" package.json; then
  echo "  ✗ Prisma client still in package.json"
  exit 1
else
  echo "  ✓ Prisma client removed from package.json"
fi

if grep -q "prisma:" package.json; then
  echo "  ✗ Prisma scripts still in package.json"
  exit 1
else
  echo "  ✓ Prisma scripts removed from package.json"
fi

# Check for AWS SDK dependencies
if grep -q "@aws-sdk/client-dynamodb" package.json; then
  echo "  ✓ AWS SDK DynamoDB client added to package.json"
else
  echo "  ✗ AWS SDK DynamoDB client missing from package.json"
  exit 1
fi

if grep -q "@aws-sdk/lib-dynamodb" package.json; then
  echo "  ✓ AWS SDK DynamoDB Document client added to package.json"
else
  echo "  ✗ AWS SDK DynamoDB Document client missing from package.json"
  exit 1
fi

# Check for Prisma imports in source files
echo ""
echo "✓ Checking for remaining Prisma imports..."

if grep -r "@prisma/client" src/ 2>/dev/null; then
  echo "  ✗ Prisma imports still found in source files"
  exit 1
else
  echo "  ✓ No Prisma imports found in source files"
fi

# Verify DynamoDB imports
echo ""
echo "✓ Verifying DynamoDB imports..."

if grep -q "@aws-sdk/client-dynamodb" src/config/database.ts; then
  echo "  ✓ DynamoDB client imported in database config"
else
  echo "  ✗ DynamoDB client not imported in database config"
  exit 1
fi

if grep -q "@aws-sdk/lib-dynamodb" src/config/database.ts; then
  echo "  ✓ DynamoDB Document client imported in database config"
else
  echo "  ✗ DynamoDB Document client not imported in database config"
  exit 1
fi

# Check environment example
echo ""
echo "✓ Checking .env.example..."

if grep -q "TABLE_NAME" .env.example; then
  echo "  ✓ TABLE_NAME in .env.example"
else
  echo "  ✗ TABLE_NAME missing from .env.example"
  exit 1
fi

if grep -q "DYNAMODB_ENDPOINT" .env.example; then
  echo "  ✓ DYNAMODB_ENDPOINT in .env.example"
else
  echo "  ✗ DYNAMODB_ENDPOINT missing from .env.example"
  exit 1
fi

if grep -q "DATABASE_URL" .env.example; then
  echo "  ✗ DATABASE_URL still in .env.example (should be removed)"
  exit 1
else
  echo "  ✓ DATABASE_URL removed from .env.example"
fi

echo ""
echo "================================"
echo "All tests PASSED! ✓"
echo "================================"
echo ""
echo "Migration from Prisma to DynamoDB is complete!"
echo ""
echo "Next steps:"
echo "1. Set up DynamoDB Local or configure AWS credentials"
echo "2. Create the DynamoDB table (see DYNAMODB_SETUP.md)"
echo "3. Start the server with: npm run dev"
echo ""
