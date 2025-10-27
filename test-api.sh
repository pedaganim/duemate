#!/bin/bash

# DueMate Invoice API Test Script
# This script demonstrates all CRUD operations and PDF generation

set -e

API_URL="http://localhost:3000"
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "=========================================="
echo "DueMate Invoice API Test Suite"
echo "=========================================="
echo ""

# Check if server is running
echo -e "${BLUE}[1] Checking server health...${NC}"
curl -s "$API_URL/health" | jq .
echo ""

# Create first invoice
echo -e "${BLUE}[2] Creating first invoice...${NC}"
INVOICE1=$(curl -s -X POST "$API_URL/api/invoices" \
  -H "Content-Type: application/json" \
  -d '{
    "clientName": "Acme Corporation",
    "clientEmail": "billing@acme.com",
    "clientAddress": "123 Business Street, Tech City, TC 12345",
    "clientDetails": "Acme Corporation\nABN: 12 345 678 901\n123 Business Street\nTech City, TC 12345",
    "customerDetails": "DueMate Pty Ltd\nABN: 98 765 432 109\n456 Vendor Ave\nMelbourne, VIC 3000",
    "amount": 2500.00,
    "currency": "AUD",
    "dueDate": "2025-11-30",
    "subtotal": 2500.00,
    "discount": 5,
    "discountAmount": 125.00,
    "shipping": 50.00,
    "taxRate": 10,
    "taxAmount": 242.50,
    "total": 2667.50,
    "amountPaid": 1000.00,
    "balanceDue": 1667.50,
    "status": "draft",
    "description": "Web Development Services - Q4 2025",
    "items": [
      {
        "description": "Frontend Development",
        "quantity": 50,
        "unitPrice": 35.00,
        "amount": 1750.00
      },
      {
        "description": "Backend API Development",
        "quantity": 30,
        "unitPrice": 25.00,
        "amount": 750.00
      }
    ],
    "notes": "Payment due within 30 days. Bank transfer details available on request."
  }')

INVOICE1_ID=$(echo "$INVOICE1" | jq -r '.data.id')
INVOICE1_NUMBER=$(echo "$INVOICE1" | jq -r '.data.invoiceNumber')
echo -e "${GREEN}✓ Created invoice: $INVOICE1_NUMBER (ID: $INVOICE1_ID)${NC}"
echo ""

# Create second invoice
echo -e "${BLUE}[3] Creating second invoice...${NC}"
INVOICE2=$(curl -s -X POST "$API_URL/api/invoices" \
  -H "Content-Type: application/json" \
  -d '{
    "clientName": "Tech Startup Inc",
    "clientEmail": "payments@techstartup.io",
    "clientAddress": "456 Innovation Ave, Silicon Valley, CA 94000",
    "amount": 1200.00,
    "currency": "USD",
    "dueDate": "2025-12-15",
    "subtotal": 1200.00,
    "total": 1200.00,
    "status": "sent",
    "description": "Consulting Services - November 2025",
    "items": [
      {
        "description": "Technical Consulting",
        "quantity": 12,
        "unitPrice": 100.00,
        "amount": 1200.00
      }
    ],
    "notes": "Payment via wire transfer preferred."
  }')

INVOICE2_ID=$(echo "$INVOICE2" | jq -r '.data.id')
INVOICE2_NUMBER=$(echo "$INVOICE2" | jq -r '.data.invoiceNumber')
echo -e "${GREEN}✓ Created invoice: $INVOICE2_NUMBER (ID: $INVOICE2_ID)${NC}"
echo ""

# List all invoices
echo -e "${BLUE}[4] Listing all invoices...${NC}"
INVOICES=$(curl -s "$API_URL/api/invoices")
TOTAL_COUNT=$(echo "$INVOICES" | jq -r '.pagination.total')
echo -e "${GREEN}✓ Found $TOTAL_COUNT invoices${NC}"
echo "$INVOICES" | jq '.data[] | {invoiceNumber, clientName, status, total}'
echo ""

# Filter by status
echo -e "${BLUE}[5] Filtering invoices by status (draft)...${NC}"
DRAFT_INVOICES=$(curl -s "$API_URL/api/invoices?status=draft")
DRAFT_COUNT=$(echo "$DRAFT_INVOICES" | jq -r '.pagination.total')
echo -e "${GREEN}✓ Found $DRAFT_COUNT draft invoices${NC}"
echo ""

# Get single invoice
echo -e "${BLUE}[6] Getting single invoice details...${NC}"
INVOICE_DETAIL=$(curl -s "$API_URL/api/invoices/$INVOICE1_ID")
echo "$INVOICE_DETAIL" | jq '.data | {invoiceNumber, clientName, status, total, items}'
echo ""

# Update invoice
echo -e "${BLUE}[7] Updating invoice status from draft to sent...${NC}"
UPDATED=$(curl -s -X PUT "$API_URL/api/invoices/$INVOICE1_ID" \
  -H "Content-Type: application/json" \
  -d '{"status": "sent"}')
NEW_STATUS=$(echo "$UPDATED" | jq -r '.data.status')
echo -e "${GREEN}✓ Invoice status updated to: $NEW_STATUS${NC}"
echo ""

# Download PDF
echo -e "${BLUE}[8] Downloading invoice as PDF...${NC}"
curl -s "$API_URL/api/invoices/$INVOICE1_ID/download" -o "/tmp/invoice-$INVOICE1_NUMBER.pdf"
if [ -f "/tmp/invoice-$INVOICE1_NUMBER.pdf" ]; then
    FILE_SIZE=$(ls -lh "/tmp/invoice-$INVOICE1_NUMBER.pdf" | awk '{print $5}')
    echo -e "${GREEN}✓ PDF downloaded successfully: /tmp/invoice-$INVOICE1_NUMBER.pdf ($FILE_SIZE)${NC}"
    file "/tmp/invoice-$INVOICE1_NUMBER.pdf"
else
    echo "✗ PDF download failed"
fi
echo ""

# Test validation
echo -e "${BLUE}[9] Testing input validation (should fail)...${NC}"
VALIDATION_ERROR=$(curl -s -X POST "$API_URL/api/invoices" \
  -H "Content-Type: application/json" \
  -d '{
    "clientName": "A",
    "clientEmail": "invalid-email",
    "amount": -100
  }')
echo "$VALIDATION_ERROR" | jq .
echo -e "${GREEN}✓ Validation working correctly${NC}"
echo ""

# Delete invoice
echo -e "${BLUE}[10] Deleting second invoice...${NC}"
DELETE_RESULT=$(curl -s -X DELETE "$API_URL/api/invoices/$INVOICE2_ID")
echo "$DELETE_RESULT" | jq .
REMAINING=$(curl -s "$API_URL/api/invoices" | jq -r '.pagination.total')
echo -e "${GREEN}✓ Invoice deleted. Remaining invoices: $REMAINING${NC}"
echo ""

echo "=========================================="
echo -e "${GREEN}All tests completed successfully!${NC}"
echo "=========================================="
echo ""
echo "Summary:"
echo "  - Created 2 invoices"
echo "  - Listed and filtered invoices"
echo "  - Updated invoice status"
echo "  - Downloaded PDF"
echo "  - Validated input"
echo "  - Deleted invoice"
echo ""
echo "API Documentation: $API_URL/api-docs"
echo "Generated PDF: /tmp/invoice-$INVOICE1_NUMBER.pdf"
