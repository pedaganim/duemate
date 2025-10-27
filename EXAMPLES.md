# DueMate API - Quick Start Examples

This guide provides practical examples for using the DueMate Invoice API.

## Prerequisites

Make sure the server is running:
```bash
npm run dev
```

Server should be available at: http://localhost:3000

## Example 1: Create Your First Invoice

```bash
curl -X POST http://localhost:3000/api/invoices \
  -H "Content-Type: application/json" \
  -d '{
    "clientName": "John Doe Consulting",
    "clientEmail": "john@example.com",
    "clientAddress": "789 Main St, Anytown, USA 12345",
    "amount": 1000.00,
    "currency": "USD",
    "dueDate": "2025-12-31",
    "subtotal": 1000.00,
    "total": 1000.00,
    "status": "draft",
    "description": "Monthly consulting services",
    "items": [
      {
        "description": "Consulting Hours",
        "quantity": 10,
        "unitPrice": 100.00,
        "amount": 1000.00
      }
    ],
    "notes": "Thank you for your business!"
  }'
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "invoiceNumber": "INV-2025-00001",
    "clientName": "John Doe Consulting",
    ...
  }
}
```

## Example 2: List All Invoices

```bash
# Get all invoices
curl http://localhost:3000/api/invoices

# With pagination
curl "http://localhost:3000/api/invoices?page=1&limit=5"

# Filter by status
curl "http://localhost:3000/api/invoices?status=paid"

# Filter by client
curl "http://localhost:3000/api/invoices?clientEmail=john@example.com"

# Combine filters
curl "http://localhost:3000/api/invoices?status=sent&page=1&limit=10&sortBy=dueDate&sortOrder=asc"
```

## Example 3: Get Invoice Details

```bash
# Replace {id} with actual invoice ID
curl http://localhost:3000/api/invoices/{id}
```

**Example with jq (pretty print):**
```bash
curl -s http://localhost:3000/api/invoices/{id} | jq .
```

## Example 4: Update an Invoice

### Update Status
```bash
curl -X PUT http://localhost:3000/api/invoices/{id} \
  -H "Content-Type: application/json" \
  -d '{
    "status": "sent"
  }'
```

### Update Multiple Fields
```bash
curl -X PUT http://localhost:3000/api/invoices/{id} \
  -H "Content-Type: application/json" \
  -d '{
    "status": "paid",
    "notes": "Payment received via bank transfer on 2025-10-27"
  }'
```

## Example 5: Download Invoice as PDF

```bash
# Download PDF
curl http://localhost:3000/api/invoices/{id}/download -o invoice.pdf

# Download with invoice number in filename
INVOICE_NUM=$(curl -s http://localhost:3000/api/invoices/{id} | jq -r '.data.invoiceNumber')
curl http://localhost:3000/api/invoices/{id}/download -o "invoice-${INVOICE_NUM}.pdf"
```

## Example 6: Preview Invoice in Browser

Open in your web browser:
```
http://localhost:3000/api/invoices/{id}/preview
```

Or use curl to check:
```bash
curl -I http://localhost:3000/api/invoices/{id}/preview
```

## Example 7: Delete an Invoice

```bash
curl -X DELETE http://localhost:3000/api/invoices/{id}
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Invoice deleted successfully"
}
```

## Example 8: Create Invoice with Tax

```bash
curl -X POST http://localhost:3000/api/invoices \
  -H "Content-Type: application/json" \
  -d '{
    "clientName": "ABC Company",
    "clientEmail": "billing@abc.com",
    "amount": 5000.00,
    "currency": "USD",
    "dueDate": "2025-12-31",
    "subtotal": 5000.00,
    "taxRate": 8.5,
    "taxAmount": 425.00,
    "total": 5425.00,
    "status": "draft",
    "description": "Software Development - October 2025",
    "items": [
      {
        "description": "Backend Development",
        "quantity": 40,
        "unitPrice": 75.00,
        "amount": 3000.00
      },
      {
        "description": "Database Design",
        "quantity": 20,
        "unitPrice": 100.00,
        "amount": 2000.00
      }
    ],
    "notes": "Net 30 payment terms apply"
  }'
```

## Example 9: Search Invoices by Date Range

```bash
# Get invoices issued between two dates
curl "http://localhost:3000/api/invoices?startDate=2025-10-01&endDate=2025-10-31"
```

## Example 10: Get Invoice Statistics

```bash
# Count total invoices
curl -s http://localhost:3000/api/invoices | jq '.pagination.total'

# Count by status
curl -s "http://localhost:3000/api/invoices?status=paid" | jq '.pagination.total'

# List all invoice numbers
curl -s http://localhost:3000/api/invoices | jq '.data[].invoiceNumber'
```

## Example 11: Bulk Operations

### Create Multiple Invoices
```bash
#!/bin/bash

CLIENTS=("client1@example.com" "client2@example.com" "client3@example.com")

for email in "${CLIENTS[@]}"; do
  curl -X POST http://localhost:3000/api/invoices \
    -H "Content-Type: application/json" \
    -d "{
      \"clientName\": \"${email%@*}\",
      \"clientEmail\": \"$email\",
      \"amount\": 1000.00,
      \"dueDate\": \"2025-12-31\",
      \"subtotal\": 1000.00,
      \"total\": 1000.00
    }"
  echo ""
done
```

### Download All Invoices as PDFs
```bash
#!/bin/bash

INVOICES=$(curl -s http://localhost:3000/api/invoices | jq -r '.data[] | .id + ":" + .invoiceNumber')

for invoice in $INVOICES; do
  ID="${invoice%:*}"
  NUMBER="${invoice#*:}"
  curl -s "http://localhost:3000/api/invoices/$ID/download" -o "invoices/$NUMBER.pdf"
  echo "Downloaded: $NUMBER.pdf"
done
```

## Example 12: Using with JavaScript/Node.js

```javascript
const axios = require('axios');

const API_URL = 'http://localhost:3000';

// Create Invoice
async function createInvoice() {
  const response = await axios.post(`${API_URL}/api/invoices`, {
    clientName: 'Tech Corp',
    clientEmail: 'billing@techcorp.com',
    amount: 2500.00,
    dueDate: '2025-12-31',
    subtotal: 2500.00,
    total: 2500.00,
    items: [
      {
        description: 'Web Development',
        quantity: 25,
        unitPrice: 100.00,
        amount: 2500.00
      }
    ]
  });
  
  return response.data.data;
}

// Get All Invoices
async function getInvoices(filters = {}) {
  const response = await axios.get(`${API_URL}/api/invoices`, {
    params: filters
  });
  
  return response.data.data;
}

// Download Invoice PDF
async function downloadInvoice(id, filename) {
  const response = await axios.get(
    `${API_URL}/api/invoices/${id}/download`,
    { responseType: 'arraybuffer' }
  );
  
  require('fs').writeFileSync(filename, response.data);
}

// Usage
(async () => {
  const invoice = await createInvoice();
  console.log('Created invoice:', invoice.invoiceNumber);
  
  const invoices = await getInvoices({ status: 'draft' });
  console.log('Draft invoices:', invoices.length);
  
  await downloadInvoice(invoice.id, `${invoice.invoiceNumber}.pdf`);
  console.log('PDF downloaded');
})();
```

## Example 13: Using with Python

```python
import requests
import json

API_URL = 'http://localhost:3000'

# Create Invoice
def create_invoice():
    invoice_data = {
        'clientName': 'Python Corp',
        'clientEmail': 'billing@pythoncorp.com',
        'amount': 3000.00,
        'dueDate': '2025-12-31',
        'subtotal': 3000.00,
        'total': 3000.00,
        'items': [
            {
                'description': 'Python Development',
                'quantity': 30,
                'unitPrice': 100.00,
                'amount': 3000.00
            }
        ]
    }
    
    response = requests.post(f'{API_URL}/api/invoices', json=invoice_data)
    return response.json()['data']

# Get All Invoices
def get_invoices(status=None):
    params = {'status': status} if status else {}
    response = requests.get(f'{API_URL}/api/invoices', params=params)
    return response.json()['data']

# Download PDF
def download_invoice(invoice_id, filename):
    response = requests.get(f'{API_URL}/api/invoices/{invoice_id}/download')
    with open(filename, 'wb') as f:
        f.write(response.content)

# Usage
if __name__ == '__main__':
    invoice = create_invoice()
    print(f"Created invoice: {invoice['invoiceNumber']}")
    
    invoices = get_invoices(status='draft')
    print(f"Draft invoices: {len(invoices)}")
    
    download_invoice(invoice['id'], f"{invoice['invoiceNumber']}.pdf")
    print("PDF downloaded")
```

## Troubleshooting

### Error: Connection Refused
Make sure the server is running:
```bash
npm run dev
```

### Error: Validation Failed
Check the error details in the response:
```bash
curl -X POST http://localhost:3000/api/invoices ... | jq '.details'
```

### Error: Invoice Not Found
Verify the invoice ID exists:
```bash
curl http://localhost:3000/api/invoices | jq '.data[].id'
```

## API Documentation

For complete API documentation, visit:
- **Swagger UI:** http://localhost:3000/api-docs
- **API README:** [API_README.md](API_README.md)

## Additional Resources

- Test Script: `./test-api.sh` - Comprehensive API testing
- Testing Results: [TESTING_RESULTS.md](TESTING_RESULTS.md)
- Main README: [README.md](README.md)
