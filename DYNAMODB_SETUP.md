# DynamoDB Setup Guide

This guide explains how to set up DynamoDB for the DueMate application.

## Overview

DueMate uses Amazon DynamoDB as its primary database. DynamoDB is a fully managed NoSQL database service that provides fast and predictable performance with seamless scalability.

## Table Design

### Main Table: `duemate-{environment}-main`

The application uses a single-table design with the following structure:

#### Primary Key
- **Partition Key (PK)**: `INVOICE#{id}`
- **Sort Key (SK)**: `INVOICE#{id}`

#### Global Secondary Indexes (GSIs)

**GSI1 - Invoice Number Lookup**
- **GSI1PK**: `INVOICE_NUMBER#{invoiceNumber}`
- **GSI1SK**: `INVOICE_NUMBER#{invoiceNumber}`
- Purpose: Fast lookup by invoice number

**GSI2 - Status Queries**
- **GSI2PK**: `STATUS#{status}`
- **GSI2SK**: `{createdAt}` (ISO timestamp)
- Purpose: Query invoices by status, sorted by creation date

**GSI3 - Client Email Queries**
- **GSI3PK**: `CLIENT_EMAIL#{clientEmail}`
- **GSI3SK**: `{createdAt}` (ISO timestamp)
- Purpose: Query invoices by client email, sorted by creation date

## AWS Deployment

When deploying to AWS, the DynamoDB table is automatically created by Terraform with the following configuration:

```hcl
resource "aws_dynamodb_table" "main" {
  name           = "duemate-${var.environment}-main"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "PK"
  range_key      = "SK"

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  attribute {
    name = "GSI1PK"
    type = "S"
  }

  attribute {
    name = "GSI1SK"
    type = "S"
  }

  attribute {
    name = "GSI2PK"
    type = "S"
  }

  attribute {
    name = "GSI2SK"
    type = "S"
  }

  attribute {
    name = "GSI3PK"
    type = "S"
  }

  attribute {
    name = "GSI3SK"
    type = "S"
  }

  global_secondary_index {
    name            = "GSI1"
    hash_key        = "GSI1PK"
    range_key       = "GSI1SK"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "GSI2"
    hash_key        = "GSI2PK"
    range_key       = "GSI2SK"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "GSI3"
    hash_key        = "GSI3PK"
    range_key       = "GSI3SK"
    projection_type = "ALL"
  }

  tags = {
    Environment = var.environment
    Project     = "duemate"
  }
}
```

## Local Development with DynamoDB Local

For local development, you can use DynamoDB Local, which is a downloadable version of DynamoDB that runs on your computer.

### Option 1: Using Docker (Recommended)

```bash
# Pull and run DynamoDB Local
docker run -d -p 8000:8000 amazon/dynamodb-local

# Verify it's running
curl http://localhost:8000
```

### Option 2: Download DynamoDB Local

1. Download from: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.DownloadingAndRunning.html
2. Extract and run:
   ```bash
   java -Djava.library.path=./DynamoDBLocal_lib -jar DynamoDBLocal.jar -sharedDb
   ```

### Create Local Table

Use the AWS CLI to create the table locally:

```bash
# Create the main table
aws dynamodb create-table \
  --table-name duemate-dev-main \
  --attribute-definitions \
    AttributeName=PK,AttributeType=S \
    AttributeName=SK,AttributeType=S \
    AttributeName=GSI1PK,AttributeType=S \
    AttributeName=GSI1SK,AttributeType=S \
    AttributeName=GSI2PK,AttributeType=S \
    AttributeName=GSI2SK,AttributeType=S \
    AttributeName=GSI3PK,AttributeType=S \
    AttributeName=GSI3SK,AttributeType=S \
  --key-schema \
    AttributeName=PK,KeyType=HASH \
    AttributeName=SK,KeyType=RANGE \
  --global-secondary-indexes \
    '[
      {
        "IndexName": "GSI1",
        "KeySchema": [
          {"AttributeName":"GSI1PK","KeyType":"HASH"},
          {"AttributeName":"GSI1SK","KeyType":"RANGE"}
        ],
        "Projection": {"ProjectionType":"ALL"}
      },
      {
        "IndexName": "GSI2",
        "KeySchema": [
          {"AttributeName":"GSI2PK","KeyType":"HASH"},
          {"AttributeName":"GSI2SK","KeyType":"RANGE"}
        ],
        "Projection": {"ProjectionType":"ALL"}
      },
      {
        "IndexName": "GSI3",
        "KeySchema": [
          {"AttributeName":"GSI3PK","KeyType":"HASH"},
          {"AttributeName":"GSI3SK","KeyType":"RANGE"}
        ],
        "Projection": {"ProjectionType":"ALL"}
      }
    ]' \
  --billing-mode PAY_PER_REQUEST \
  --endpoint-url http://localhost:8000
```

### Configure Environment

Create a `.env` file in the project root:

```bash
# AWS Configuration
AWS_REGION=us-east-1

# DynamoDB Configuration
TABLE_NAME=duemate-dev-main

# DynamoDB Local endpoint (comment out for AWS)
DYNAMODB_ENDPOINT=http://localhost:8000

# Application Configuration
NODE_ENV=development
PORT=3000
```

### Verify Table Creation

```bash
# List tables
aws dynamodb list-tables --endpoint-url http://localhost:8000

# Describe table
aws dynamodb describe-table \
  --table-name duemate-dev-main \
  --endpoint-url http://localhost:8000
```

## Environment Variables

The following environment variables control database configuration:

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `AWS_REGION` | Yes | AWS region | `us-east-1` |
| `TABLE_NAME` | Yes | DynamoDB table name | `duemate-dev-main` |
| `DYNAMODB_ENDPOINT` | No | DynamoDB endpoint (for local dev) | `http://localhost:8000` |

## Data Model

### Invoice Entity

```typescript
interface Invoice {
  id: string;                    // UUID
  invoiceNumber: string;         // Format: INV-YYYY-#####
  clientName: string;
  clientEmail: string;
  clientAddress?: string;
  clientDetails?: string;        // JSON string with client info
  customerDetails?: string;      // JSON string with vendor info
  amount: number;
  currency: string;              // Default: AUD
  issueDate: Date;
  dueDate: Date;
  status: string;                // draft, sent, paid, overdue, cancelled
  description?: string;
  items?: any;                   // JSON array of line items
  notes?: string;
  taxRate?: number;
  taxAmount?: number;
  discount?: number;
  discountAmount?: number;
  shipping?: number;
  subtotal: number;
  total: number;
  amountPaid?: number;
  balanceDue?: number;
  createdAt: Date;
  updatedAt: Date;
}
```

## Query Patterns

### Get Invoice by ID
```typescript
const invoice = await invoiceRepository.findById(id);
```

### Get Invoice by Invoice Number
```typescript
const invoice = await invoiceRepository.findByInvoiceNumber('INV-2025-00001');
```

### Get Invoices by Status
```typescript
const { items, lastEvaluatedKey } = await invoiceRepository.findByStatus('paid', 10);
```

### Get Invoices by Client Email
```typescript
const { items, lastEvaluatedKey } = await invoiceRepository.findByClientEmail('client@example.com', 10);
```

### Scan All Invoices
```typescript
const { items, lastEvaluatedKey } = await invoiceRepository.findAll(10);
```

## Best Practices

1. **Use GSIs for Queries**: Always use Global Secondary Indexes when querying by invoice number, status, or client email
2. **Pagination**: Use the `lastEvaluatedKey` for pagination in large result sets
3. **Limit Scans**: Avoid full table scans when possible; use GSIs or Query operations
4. **Atomic Updates**: Use UpdateCommand for partial updates instead of reading, modifying, and writing back
5. **Error Handling**: Always handle DynamoDB-specific errors like `ConditionalCheckFailedException`

## Migration from Prisma

The application has been migrated from Prisma (SQLite/PostgreSQL) to DynamoDB. Key changes:

1. **No Schema Migrations**: DynamoDB is schema-less; table structure is defined at creation
2. **No JOIN Operations**: Single-table design eliminates need for joins
3. **Different Query Patterns**: Use GSIs instead of SQL WHERE clauses
4. **No Auto-incrementing IDs**: Use UUIDs for unique identifiers
5. **JSON Storage**: Complex objects (items) stored as JSON strings

## Troubleshooting

### "ResourceNotFoundException: Cannot do operations on a non-existent table"

**Solution**: Create the table using the AWS CLI command above or ensure Terraform has been applied

### "ValidationException: One or more parameter values were invalid"

**Solution**: Check that all required GSI attributes are defined in the table schema

### Connection to localhost:8000 refused

**Solution**: Ensure DynamoDB Local is running:
```bash
docker ps | grep dynamodb-local
```

## Additional Resources

- [AWS DynamoDB Documentation](https://docs.aws.amazon.com/dynamodb/)
- [DynamoDB Best Practices](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/best-practices.html)
- [DynamoDB Local Guide](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.html)
- [AWS SDK for JavaScript v3](https://docs.aws.amazon.com/sdk-for-javascript/v3/developer-guide/)

---

**Last Updated**: 2025-10-28  
**Version**: 1.0
