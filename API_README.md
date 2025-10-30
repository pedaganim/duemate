# DueMate Invoice API

A RESTful API for invoice management with PDF generation capabilities.

## Features

- ✅ Full CRUD operations for invoices
- ✅ PDF preview and download functionality
- ✅ Input validation using Joi
- ✅ Swagger/OpenAPI documentation
- ✅ Amazon DynamoDB for data storage
- ✅ No authentication required (public access)
- ✅ Pagination and filtering support
- ✅ Professional PDF invoice templates

## Tech Stack

- **Runtime**: Node.js with TypeScript
- **Framework**: Express.js
- **Database**: Amazon DynamoDB
- **PDF Generation**: PDFKit
- **Validation**: Joi
- **API Documentation**: Swagger/OpenAPI

## Getting Started

### Prerequisites

- Node.js (v16 or higher)
- npm or yarn

### Installation

1. Clone the repository:
```bash
git clone https://github.com/pedaganim/duemate.git
cd duemate
```

2. Install dependencies:
```bash
npm install
```

3. Set up DynamoDB:
```bash
# For local development, see DYNAMODB_SETUP.md for detailed instructions
# Quick start with Docker:
docker run -d -p 8000:8000 amazon/dynamodb-local
```

4. Configure environment:
```bash
cp .env.example .env
# Edit .env with your configuration
```

5. Start the development server:
```bash
npm run dev
```

The server will start on `http://localhost:3000`

## API Documentation

Once the server is running, visit:
- **Swagger UI**: http://localhost:3000/api-docs
- **OpenAPI JSON**: http://localhost:3000/api-docs.json

## API Endpoints

### Invoice CRUD Operations

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/invoices` | Create a new invoice |
| GET | `/api/invoices` | Get all invoices (with pagination & filtering) |
| GET | `/api/invoices/:id` | Get a single invoice by ID |
| PUT | `/api/invoices/:id` | Update an invoice |
| DELETE | `/api/invoices/:id` | Delete an invoice |
| GET | `/api/invoices/:id/preview` | Preview invoice as PDF in browser |
| GET | `/api/invoices/:id/download` | Download invoice as PDF |

### Other Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | API information |
| GET | `/health` | Health check |

## Usage Examples

### Create an Invoice

```bash
curl -X POST http://localhost:3000/api/invoices \
  -H "Content-Type: application/json" \
  -d '{
    "clientName": "Acme Corp",
    "clientEmail": "billing@acme.com",
    "clientAddress": "123 Business St, City, State 12345",
    "clientDetails": "Acme Corporation\nABN: 12 345 678 901\n123 Business St\nSydney, NSW 2000",
    "customerDetails": "DueMate Pty Ltd\nABN: 98 765 432 109\n456 Vendor Ave\nMelbourne, VIC 3000",
    "amount": 1500.00,
    "currency": "AUD",
    "dueDate": "2024-12-31",
    "subtotal": 1500.00,
    "discount": 10,
    "discountAmount": 150.00,
    "shipping": 50.00,
    "taxRate": 10,
    "taxAmount": 140.00,
    "total": 1540.00,
    "amountPaid": 500.00,
    "balanceDue": 1040.00,
    "status": "draft",
    "description": "Web development services",
    "items": [
      {
        "description": "Frontend Development",
        "quantity": 40,
        "unitPrice": 25.00,
        "amount": 1000.00
      },
      {
        "description": "Backend Development",
        "quantity": 20,
        "unitPrice": 25.00,
        "amount": 500.00
      }
    ],
    "notes": "Payment due within 30 days"
  }'
```

### Get All Invoices

```bash
# Get all invoices
curl http://localhost:3000/api/invoices

# With pagination
curl "http://localhost:3000/api/invoices?page=1&limit=10"

# Filter by status
curl "http://localhost:3000/api/invoices?status=paid"

# Filter by client email
curl "http://localhost:3000/api/invoices?clientEmail=billing@acme.com"

# Sort by due date
curl "http://localhost:3000/api/invoices?sortBy=dueDate&sortOrder=asc"
```

### Get Single Invoice

```bash
curl http://localhost:3000/api/invoices/{invoice-id}
```

### Update an Invoice

```bash
curl -X PUT http://localhost:3000/api/invoices/{invoice-id} \
  -H "Content-Type: application/json" \
  -d '{
    "status": "paid",
    "notes": "Paid via bank transfer"
  }'
```

### Delete an Invoice

```bash
curl -X DELETE http://localhost:3000/api/invoices/{invoice-id}
```

### Preview Invoice PDF

Open in browser:
```
http://localhost:3000/api/invoices/{invoice-id}/preview
```

### Download Invoice PDF

```bash
curl http://localhost:3000/api/invoices/{invoice-id}/download -o invoice.pdf
```

## Invoice Schema

### Required Fields

- `clientName` (string): Name of the client
- `clientEmail` (string): Client's email address
- `amount` (number): Total invoice amount
- `dueDate` (date): Payment due date
- `subtotal` (number): Subtotal before tax
- `total` (number): Total amount including tax

### Optional Fields

- `invoiceNumber` (string): Auto-generated if not provided
- `clientAddress` (string): Client's address
- `clientDetails` (string): Detailed client information (company name, ABN, address, etc.)
- `customerDetails` (string): Vendor/Seller details (company name, ABN, address, etc.)
- `currency` (string): Currency code - supports AUD, USD, EUR, GBP, JPY, CAD, CHF, CNY, SEK, NZD, MXN, SGD, HKD, NOK, KRW, TRY, RUB, INR, BRL, ZAR (default: AUD)
- `issueDate` (date): Invoice issue date (default: now)
- `status` (enum): draft, sent, paid, overdue, cancelled (default: draft)
- `description` (string): Invoice description
- `items` (array): Line items with description, quantity, unitPrice, amount
- `notes` (string): Additional notes
- `taxRate` (number): Tax percentage (0-100)
- `taxAmount` (number): Calculated tax amount
- `discount` (number): Discount percentage (0-100)
- `discountAmount` (number): Calculated discount amount
- `shipping` (number): Shipping cost
- `amountPaid` (number): Amount already paid
- `balanceDue` (number): Remaining balance due

## Query Parameters

### List Invoices

- `page` (number): Page number (default: 1)
- `limit` (number): Items per page (default: 10, max: 100)
- `status` (string): Filter by status (draft, sent, paid, overdue, cancelled)
- `clientEmail` (string): Filter by client email
- `startDate` (date): Filter by issue date (from)
- `endDate` (date): Filter by issue date (to)
- `sortBy` (string): Sort field (invoiceNumber, issueDate, dueDate, amount, status, createdAt)
- `sortOrder` (string): Sort direction (asc, desc)

## Development

### Available Scripts

- `npm run dev` - Start development server with hot reload
- `npm run build` - Build TypeScript to JavaScript
- `npm start` - Start production server

### Project Structure

```
duemate/
├── src/
│   ├── config/            # Configuration files
│   │   ├── database.ts    # DynamoDB client
│   │   └── swagger.ts     # Swagger configuration
│   ├── controllers/       # Request handlers
│   │   └── invoice.controller.ts
│   ├── models/           # Data models
│   │   └── invoice.model.ts
│   ├── repositories/     # DynamoDB data access
│   │   └── invoice.repository.ts
│   ├── routes/           # API routes
│   │   └── invoice.routes.ts
│   ├── services/         # Business logic
│   │   ├── invoice.service.ts
│   │   └── pdf.service.ts
│   ├── types/           # TypeScript types
│   │   └── invoice.types.ts
│   ├── utils/           # Utilities
│   │   └── validation.ts
│   ├── app.ts          # Express app setup
│   └── index.ts        # Server entry point
├── .env                # Environment variables
├── .gitignore
├── package.json
├── tsconfig.json
└── README.md
```

## Environment Variables

Create a `.env` file in the root directory:

```env
# AWS Configuration
AWS_REGION=us-east-1

# DynamoDB Configuration
TABLE_NAME=duemate-dev-main

# Server
PORT=3000
NODE_ENV=development
```

**Note**: DueMate uses DynamoDB. See `.env.example` for full configuration options.

## Database Schema

The Invoice model includes:

- `id` - UUID primary key
- `invoiceNumber` - Unique invoice number (auto-generated)
- `clientName` - Client's name
- `clientEmail` - Client's email
- `clientAddress` - Client's address (optional)
- `amount` - Invoice amount
- `currency` - Currency code (default: AUD)
- `issueDate` - Date invoice was issued
- `dueDate` - Payment due date
- `status` - Invoice status (draft, sent, paid, overdue, cancelled)
- `description` - Invoice description
- `items` - JSON array of line items
- `notes` - Additional notes
- `taxRate` - Tax percentage
- `taxAmount` - Tax amount
- `subtotal` - Subtotal before tax
- `total` - Total amount
- `createdAt` - Creation timestamp
- `updatedAt` - Last update timestamp

## PDF Features

The generated PDF invoices include:

- Professional invoice layout
- Company header with contact information
- Invoice details (number, dates, status)
- Client billing information
- Itemized line items with quantities and prices
- Subtotal, tax, and total calculations
- Notes and description fields
- Clean, printable format

## Error Handling

The API returns consistent error responses:

```json
{
  "success": false,
  "error": "Error message",
  "details": ["Validation error details"]
}
```

Common HTTP status codes:
- `200` - Success
- `201` - Created
- `400` - Bad Request (validation error)
- `404` - Not Found
- `500` - Internal Server Error

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

TBD
