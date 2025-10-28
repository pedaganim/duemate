# DueMate

**Invoice Management & Payment Reminders for Small Businesses** - Never miss a payment deadline again!

[![CI/CD](https://github.com/pedaganim/duemate/actions/workflows/ci.yml/badge.svg)](https://github.com/pedaganim/duemate/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Overview

DueMate is a modern invoice management and automated reminder system designed to help small businesses and freelancers track invoices and ensure timely payments. Built with Next.js 14+ for the frontend and Express.js for the backend API.

## 🚀 Features

### Current Features (MVP)
- ✅ **Modern Landing Page** - Professional, responsive landing page built with Next.js 14+ and Tailwind CSS
- ✅ **Invoice Management** - Full CRUD operations (Create, Read, Update, Delete)
- ✅ **PDF Generation** - Professional invoice PDF templates
- ✅ **PDF Preview & Download** - Preview invoices in browser or download as PDF files
- ✅ **Input Validation** - Comprehensive validation for all invoice fields
- ✅ **API Documentation** - Interactive Swagger/OpenAPI documentation
- ✅ **Filtering & Pagination** - Query invoices by status, client, date range
- ✅ **Auto-Generated Invoice Numbers** - Sequential invoice numbering (INV-YYYY-NNNNN)
- ✅ **No Authentication Required** - Public API access (as per MVP requirements)

### Coming Soon
- 👥 **Client Management** - Manage client information and payment terms
- ⏰ **Automated Reminders** - Schedule and send email reminders for due invoices
- 📊 **Dashboard** - Quick overview of invoice status and upcoming reminders
- 🔐 **Authentication** - User accounts and secure access

### Future Features
- 🏦 **Bank Sync** - Automatic payment tracking via bank account integration
- 🎙️ **AI Voice Reminders** - AI-powered voice call reminders
- 🏷️ **Whitelabel** - Multi-tenant support for reselling

## 🛠️ Tech Stack

### Frontend
- **Next.js 14+** - React framework with App Router
- **React 19** - UI library
- **TypeScript** - Type safety
- **Tailwind CSS** - Utility-first CSS framework
- **Vercel** - Deployment platform

### Backend
- **Node.js** - JavaScript runtime
- **Express.js** - Web framework
- **TypeScript** - Type safety
- **Prisma ORM** - Database toolkit
- **SQLite/PostgreSQL** - Database
- **PDFKit** - PDF generation
- **Joi** - Validation
- **Swagger/OpenAPI** - API documentation

## 📋 Quick Start

### Prerequisites

- Node.js v18 or higher
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

3. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. **Set up the database**
   ```bash
   npm run prisma:migrate
   npm run prisma:generate
   ```

5. **Start the development servers**
   
   **Option 1: Start Next.js frontend**
   ```bash
   npm run dev
   ```
   Frontend will be available at: http://localhost:3000
   
   **Option 2: Start Express.js API backend**
   ```bash
   npm run api:dev
   ```
   API will be available at: http://localhost:3000
   - Swagger Documentation: http://localhost:3000/api-docs
   - Health Check: http://localhost:3000/health

### Building for Production

```bash
# Build Next.js frontend
npm run build

# Build Express.js API
npm run api:build

# Start production servers
npm start           # Next.js
npm run api:start   # Express API
```

## 📚 Documentation

- **[Deployment Guide](docs/deployment.md)** - Step-by-step guide to deploy to Vercel and configure duemate.org domain
- **[Environment Variables](docs/environment-variables.md)** - Complete environment variables reference
- **[System Architecture](docs/system-architecture.md)** - Technical architecture and design decisions
- **[API Documentation](API_README.md)** - Complete REST API reference with examples
- **[Product Backlog](PRODUCT_BACKLOG.md)** - Roadmap and planned features

## 📖 API Usage Examples

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

## 🔧 Development

### Available Scripts

```bash
# Frontend (Next.js)
npm run dev              # Start Next.js dev server
npm run build            # Build Next.js for production
npm start                # Start Next.js production server
npm run lint             # Run ESLint
npm run format           # Format code with Prettier
npm run format:check     # Check code formatting

# Backend API (Express.js)
npm run api:dev          # Start API dev server with hot reload
npm run api:build        # Build API (TypeScript to JavaScript)
npm run api:start        # Start API production server

# Database
npm run prisma:generate  # Generate Prisma Client
npm run prisma:migrate   # Run database migrations
npm run prisma:studio    # Open Prisma Studio (DB GUI)

# Testing
npm test                 # Run tests
```

### Project Structure

```
duemate/
├── .github/
│   └── workflows/       # GitHub Actions CI/CD
├── docs/                # Documentation
│   ├── deployment.md
│   ├── environment-variables.md
│   └── system-architecture.md
├── prisma/              # Database schema and migrations
│   ├── schema.prisma
│   └── migrations/
├── src/
│   ├── app/            # Next.js App Router
│   │   ├── layout.tsx  # Root layout
│   │   ├── page.tsx    # Landing page
│   │   └── globals.css # Global styles
│   ├── components/     # React components (future)
│   ├── config/         # Backend configuration
│   ├── controllers/    # API controllers
│   ├── routes/         # API routes
│   ├── services/       # Business logic
│   ├── types/          # TypeScript types
│   ├── utils/          # Utilities
│   ├── app.ts         # Express app
│   └── index.ts       # Server entry point
├── .env.example        # Environment variables template
├── .eslintrc.json     # ESLint configuration
├── .prettierrc.json   # Prettier configuration
├── next.config.ts     # Next.js configuration
├── tailwind.config.ts # Tailwind CSS configuration
├── tsconfig.json      # TypeScript configuration
├── package.json
└── LICENSE            # MIT License
```

## 🚢 Deployment

DueMate is designed to be deployed on Vercel for the Next.js frontend and can use various platforms for the backend API.

### Quick Deploy to Vercel

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/pedaganim/duemate)

### Manual Deployment

See the comprehensive [Deployment Guide](docs/deployment.md) for:
- Step-by-step Vercel deployment
- Custom domain setup (duemate.org)
- Environment variable configuration
- Database setup for production
- CI/CD with GitHub Actions

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with [Next.js](https://nextjs.org/)
- Styled with [Tailwind CSS](https://tailwindcss.com/)
- Backend powered by [Express.js](https://expressjs.com/)
- Database managed by [Prisma](https://www.prisma.io/)
- Deployed on [Vercel](https://vercel.com/)

## 📧 Contact

Project Link: [https://github.com/pedaganim/duemate](https://github.com/pedaganim/duemate)

---

**DueMate** - Making invoice management simple and payment collection effortless! 💼✨
