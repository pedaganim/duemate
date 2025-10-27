# DueMate

**Reminders on Invoices** - Automated invoice reminder system to help businesses get paid on time.

## Overview

DueMate is an invoice management and reminder system designed to help small businesses and freelancers track invoices and automate payment reminders. Never miss a payment deadline again!

## Current Status

✅ **Invoice CRUD API with PDF Generation** - Fully implemented and operational!

The API provides complete invoice management capabilities with PDF generation and download features. See [API Documentation](API_README.md) for detailed usage.

## Features Implemented

### Core Features
- ✅ **Invoice Management** - Full CRUD operations (Create, Read, Update, Delete)
- ✅ **PDF Generation** - Professional invoice PDF templates
- ✅ **PDF Preview** - Preview invoices in browser before downloading
- ✅ **PDF Download** - Download invoices as PDF files
- ✅ **Input Validation** - Comprehensive validation for all invoice fields
- ✅ **API Documentation** - Interactive Swagger/OpenAPI documentation
- ✅ **No Authentication** - Public API access (as per requirements)
- ✅ **Filtering & Pagination** - Query invoices by status, client, date range
- ✅ **Auto-Generated Invoice Numbers** - Sequential invoice numbering (INV-YYYY-NNNNN)

### API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/invoices` | Create a new invoice |
| GET | `/api/invoices` | List invoices with filtering/pagination |
| GET | `/api/invoices/:id` | Get invoice by ID |
| PUT | `/api/invoices/:id` | Update invoice |
| DELETE | `/api/invoices/:id` | Delete invoice |
| GET | `/api/invoices/:id/preview` | Preview invoice PDF in browser |
| GET | `/api/invoices/:id/download` | Download invoice as PDF |

## Quick Start

### Prerequisites

- Node.js v16 or higher
- npm or yarn

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/pedaganim/duemate.git
cd duemate
```

2. **Install dependencies**
```bash
npm install
```

3. **Set up the database**
```bash
npm run prisma:migrate
```

4. **Start the server**
```bash
# Development mode with hot reload
npm run dev

# Production mode
npm run build
npm start
```

5. **Access the API**
- API Server: http://localhost:3000
- Swagger Documentation: http://localhost:3000/api-docs
- Health Check: http://localhost:3000/health

## Documentation

- **[API Documentation](API_README.md)** - Complete API reference with examples
- **[Product Backlog](PRODUCT_BACKLOG.md)** - Detailed MVP feature list and requirements
- **[Issues](issues.json)** - Structured JSON data of all planned features
- **[Scripts](scripts/README.md)** - Utility scripts including GitHub issue creation

## Tech Stack

- **Backend**: Node.js + TypeScript + Express.js
- **Database**: SQLite with Prisma ORM
- **PDF Generation**: PDFKit
- **Validation**: Joi
- **API Docs**: Swagger/OpenAPI

## Usage Examples

### Create an Invoice

```bash
curl -X POST http://localhost:3000/api/invoices \
  -H "Content-Type: application/json" \
  -d '{
    "clientName": "Acme Corp",
    "clientEmail": "billing@acme.com",
    "amount": 1500.00,
    "dueDate": "2024-12-31",
    "subtotal": 1500.00,
    "total": 1500.00,
    "items": [
      {
        "description": "Web Development",
        "quantity": 40,
        "unitPrice": 25.00,
        "amount": 1000.00
      }
    ]
  }'
```

### Get All Invoices

```bash
# Basic list
curl http://localhost:3000/api/invoices

# With filters
curl "http://localhost:3000/api/invoices?status=paid&page=1&limit=10"
```

### Download Invoice PDF

```bash
curl http://localhost:3000/api/invoices/{invoice-id}/download -o invoice.pdf
```

For more examples, see the [API Documentation](API_README.md).

## Development

### Available Scripts

```bash
npm run dev          # Start dev server with hot reload
npm run build        # Build TypeScript to JavaScript
npm start            # Start production server
npm run prisma:migrate    # Run database migrations
npm run prisma:studio     # Open Prisma Studio (DB GUI)
```

### Project Structure

```
duemate/
├── prisma/              # Database schema and migrations
├── src/
│   ├── config/         # Configuration (database, swagger)
│   ├── controllers/    # Request handlers
│   ├── routes/         # API routes
│   ├── services/       # Business logic
│   ├── types/          # TypeScript types
│   ├── utils/          # Utilities (validation)
│   ├── app.ts         # Express app
│   └── index.ts       # Server entry point
├── .env               # Environment variables
├── package.json
└── tsconfig.json
```

## Roadmap

### Coming Soon
- 👥 **Client Management** - Manage client information and payment terms
- ⏰ **Automated Reminders** - Schedule and send email reminders for due invoices
- 📊 **Dashboard** - Quick overview of invoice status and upcoming reminders

### Nice-to-Have Features
- 🏦 **Bank Sync** - Automatic payment tracking via bank account integration
- 🎙️ **AI Voice Reminders** - AI-powered voice call reminders
- 🏷️ **Whitelabel** - Multi-tenant support for reselling

See the [Product Backlog](PRODUCT_BACKLOG.md) for the complete feature roadmap.

## Contributing

Interested in contributing? Check out the [Product Backlog](PRODUCT_BACKLOG.md) for planned features or submit a Pull Request.

## License

TBD
