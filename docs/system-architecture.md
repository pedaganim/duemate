# DueMate System Architecture

## Overview

DueMate is a SaaS platform that provides automated invoice reminder functionality for businesses. The system sends timely reminders to customers about upcoming or overdue invoices via multiple channels (email, SMS) and integrates with payment gateways and banking systems to streamline payment collection.

**Version:** 1.0  
**Last Updated:** October 2025

---

## Table of Contents

1. [System Goals](#system-goals)
2. [Architecture Overview](#architecture-overview)
3. [Core Technology Stack](#core-technology-stack)
4. [System Components](#system-components)
5. [Third-Party Services](#third-party-services)
6. [Multi-Tenancy Strategy](#multi-tenancy-strategy)
7. [Whitelabel Approach](#whitelabel-approach)
8. [Customer AWS Account Deployment](#customer-aws-account-deployment)
9. [Data Flow](#data-flow)
10. [Security Considerations](#security-considerations)
11. [Scalability & Performance](#scalability--performance)

---

## System Goals

### Primary Objectives
- Automate invoice reminder delivery across multiple channels
- Provide configurable reminder schedules and templates
- Enable seamless payment collection
- Support multiple businesses (multi-tenancy)
- Offer whitelabel solutions for resellers/partners
- Ensure reliability, security, and scalability

### Key Features
- Invoice management and tracking
- Automated reminder scheduling
- Multi-channel notifications (Email, SMS)
- Payment gateway integration
- Bank account integration for payment verification
- Analytics and reporting dashboard
- Customer portal for invoice viewing and payment
- API for third-party integrations

---

## Architecture Overview

DueMate follows a **serverless-first architecture** using AWS services to minimize operational costs and infrastructure management. This approach provides near-zero costs during low usage periods while automatically scaling to handle growth.

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   Web App    │  │  Mobile App  │  │  API Client  │          │
│  │  (React)     │  │ (React Native│  │    (REST)    │          │
│  │  on S3 +     │  │  Expo)       │  │              │          │
│  │  CloudFront  │  │              │  │              │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│                                                                  │
└────────────────────────┬─────────────────────────────────────────┘
                         │
                         │ HTTPS
                         │
┌────────────────────────▼─────────────────────────────────────────┐
│                   AWS API GATEWAY (REST)                         │
│              - Authentication (Cognito Authorizer)               │
│              - Request validation & throttling                   │
│              - CORS handling                                     │
└────────────────────────┬─────────────────────────────────────────┘
                         │
         ┌───────────────┼───────────────────────────────┐
         │               │                               │
         │               │                               │
┌────────▼──────┐ ┌──────▼──────────┐ ┌────────▼────────┐
│               │ │                  │ │                  │
│  Lambda       │ │  Lambda          │ │  Lambda          │
│  Functions    │ │  Functions       │ │  Functions       │
│  (API Logic)  │ │  (Background)    │ │  (Webhooks)      │
│               │ │                  │ │                  │
└───────┬───────┘ └──────┬───────────┘ └──────────────────┘
        │                │
        │         ┌──────▼─────────────────────┐
        │         │   EventBridge / SQS        │
        │         │   (Event routing &         │
        │         │    async processing)       │
        │         └────────────────────────────┘
        │
┌───────▼────────────────────────────────────────────┐
│              AWS SERVICES CORE                     │
├────────────────────────────────────────────────────┤
│                                                    │
│  ┌──────────────┐  ┌──────────────┐              │
│  │  Cognito     │  │  DynamoDB    │              │
│  │  (Auth)      │  │  (Invoices,  │              │
│  │              │  │   Tenants,   │              │
│  │              │  │   Users)     │              │
│  └──────────────┘  └──────────────┘              │
│                                                    │
│  ┌──────────────┐  ┌──────────────┐              │
│  │  EventBridge │  │  Step         │              │
│  │  (Scheduler) │  │  Functions   │              │
│  │              │  │  (Workflows) │              │
│  └──────────────┘  └──────────────┘              │
│                                                    │
│  ┌──────────────┐  ┌──────────────┐              │
│  │  SQS/SNS     │  │  CloudWatch  │              │
│  │  (Queues)    │  │  (Logs/      │              │
│  │              │  │   Metrics)   │              │
│  └──────────────┘  └──────────────┘              │
│                                                    │
└────────────────────┬───────────────────────────────┘
                     │
         ┌───────────┼───────────────┐
         │           │               │
┌────────▼───┐ ┌─────▼──────┐ ┌──────▼────────┐
│            │ │            │ │               │
│ DynamoDB   │ │  S3        │ │  DAX          │
│ Tables     │ │  (Files,   │ │  (DynamoDB    │
│            │ │   Assets)  │ │   Cache)      │
│            │ │            │ │  *Optional    │
└────────────┘ └────────────┘ └───────────────┘
         │
         │
┌────────▼──────────────────────────────────────────┐
│           THIRD-PARTY INTEGRATIONS                │
├───────────────────────────────────────────────────┤
│                                                   │
│  Email       SMS        Payment     Banking      │
│  (SES/       (SNS/      (Stripe)    (Plaid)      │
│   SendGrid)  Twilio)    (PayPal)                 │
│                                                   │
└───────────────────────────────────────────────────┘
```

### Cost Optimization Strategy

**AWS Free Tier Benefits:**
- Lambda: 1M free requests/month + 400,000 GB-seconds compute
- DynamoDB: 25 GB storage + 25 read/write capacity units
- API Gateway: 1M API calls/month (first 12 months)
- S3: 5 GB storage + 20,000 GET requests
- CloudFront: 1 TB data transfer out (first 12 months)
- SES: 62,000 emails/month (when sending from EC2/Lambda)
- SNS: 1M publishes + 100,000 HTTP deliveries

**Estimated Monthly Costs (Beyond Free Tier):**
- **Low usage (< 100 invoices/month):** $0-5/month
- **Medium usage (1,000 invoices/month):** $10-30/month
- **High usage (10,000 invoices/month):** $50-150/month

---

## Core Technology Stack

### Frontend

**Web Application**
- **Framework:** React 18+ with TypeScript
- **State Management:** Redux Toolkit / Zustand
- **UI Library:** Material-UI (MUI) or Tailwind CSS + Headless UI
- **Build Tool:** Vite
- **API Communication:** Axios / React Query
- **Forms:** React Hook Form + Zod validation
- **Charts/Visualization:** Recharts / Chart.js

**Mobile Application** (Phase 2)
- **Framework:** React Native with TypeScript
- **Navigation:** React Navigation
- **State Management:** Redux Toolkit

**Reasoning:**
- React ecosystem provides excellent developer experience and community support
- TypeScript ensures type safety and better maintainability
- Component-based architecture enables whitelabeling
- Cross-platform mobile development reduces costs

### Backend

**Serverless Stack (AWS Lambda)**
- **Runtime:** Node.js 20 (AWS Lambda runtime)
- **Framework:** Serverless Framework / AWS SAM / CDK
- **Language:** TypeScript
- **API Style:** RESTful API via API Gateway
- **Authentication:** AWS Cognito (user pools) + JWT
- **Validation:** Zod (lightweight for Lambda)
- **Data Access:** AWS DynamoDB SDK / DynamoDB Toolbox
- **Testing:** Jest + AWS SAM Local

**Background Processing**
- **Event System:** Amazon EventBridge (scheduled events)
- **Queue System:** Amazon SQS (dead letter queues for retries)
- **Workflow Orchestration:** AWS Step Functions (complex workflows)
- **Scheduler:** EventBridge Scheduler (cron-like scheduling)

**Reasoning:**
- **Pay-per-use:** Only charged for actual execution time (no idle costs)
- **Auto-scaling:** Scales automatically from 0 to thousands of concurrent executions
- **Free tier:** 1M Lambda requests/month permanently free
- **TypeScript:** Enables code sharing with frontend
- **Managed services:** No server maintenance or patching required
- **Cold start mitigation:** Keep functions warm with EventBridge pings if needed

### Database

**Primary Database: Amazon DynamoDB**
- **Type:** NoSQL, Key-Value and Document database
- **Billing Mode:** On-Demand (pay per request) or Provisioned (with auto-scaling)
- **Free Tier:** 25 GB storage + 25 RCU/WCU permanently
- **Features Used:**
  - Single-table design for cost optimization
  - Global Secondary Indexes (GSI) for query patterns
  - DynamoDB Streams for change data capture
  - Time-to-Live (TTL) for automatic data expiration
  - Point-in-time recovery for backups

**Table Design Strategy:**
```
Primary Table: duemate-main

PK (Partition Key)         SK (Sort Key)              Attributes
─────────────────────────────────────────────────────────────────
TENANT#{tenantId}          METADATA                   name, plan, settings, branding
TENANT#{tenantId}          USER#{userId}              email, role, permissions
TENANT#{tenantId}          INVOICE#{invoiceId}        amount, dueDate, status, customerId
TENANT#{tenantId}          CUSTOMER#{customerId}      name, email, phone
TENANT#{tenantId}          REMINDER#{reminderId}      invoiceId, scheduledAt, status, type

GSI-1: Query invoices by status
GSI1PK: TENANT#{tenantId}#STATUS#{status}
GSI1SK: INVOICE#{invoiceId}

GSI-2: Query reminders by scheduled date
GSI2PK: TENANT#{tenantId}#DATE#{YYYY-MM-DD}
GSI2SK: REMINDER#{reminderId}
```

**Caching Layer (Optional)**
- **System:** Amazon DynamoDB Accelerator (DAX)
- **Use Cases:** Ultra-low latency reads (microseconds)
- **Cost:** Only enable when needed for high-traffic scenarios

**Reasoning:**
- **Cost-effective:** Pay only for reads/writes, 25GB free tier
- **Serverless:** No server management, automatic scaling
- **Performance:** Single-digit millisecond latency
- **Global tables:** Built-in multi-region replication if needed
- **No cold starts:** Always available, unlike RDS
- **Single-table design:** Minimize costs by reducing table count

### File Storage

**System:** AWS S3
- **Storage Classes:** S3 Standard (frequently accessed), S3 Standard-IA (archival)
- **Free Tier:** 5 GB storage + 20,000 GET requests/month (first 12 months)
- **Use Cases:**
  - Invoice PDF storage
  - Email attachments
  - Report exports
  - Logo/branding assets for whitelabel
  - Static website hosting (frontend)

**Content Delivery**
- **CDN:** Amazon CloudFront
- **Free Tier:** 1 TB data transfer out (first 12 months)
- **Benefits:** Fast global delivery, DDoS protection, SSL/TLS

### Infrastructure & DevOps

**Infrastructure as Code**
- **Primary Tool:** AWS CDK (TypeScript) or Serverless Framework
- **Alternative:** AWS SAM, Terraform
- **Benefits:** Version-controlled infrastructure, reproducible deployments

**CI/CD**
- **Platform:** GitHub Actions (free for public repos, 2,000 minutes/month for private)
- **Stages:** 
  - Lint & Type Check
  - Unit Tests
  - Build Lambda packages
  - Deploy to staging (on PR)
  - Deploy to production (on merge to main)

**Hosting**
- **Frontend:** S3 + CloudFront (static site)
- **Backend:** AWS Lambda (serverless functions)
- **Database:** DynamoDB (fully managed)
- **Total Infrastructure Cost at Low Scale:** Near $0 with free tiers

**Monitoring & Logging**
- **Logging:** CloudWatch Logs (automatic for Lambda)
- **Metrics:** CloudWatch Metrics (automatic for Lambda, API Gateway, DynamoDB)
- **Alarms:** CloudWatch Alarms (free tier: 10 alarms)
- **Tracing:** AWS X-Ray (optional, for debugging)
- **Error Tracking:** CloudWatch Insights or Sentry (free tier available)

**Reasoning:**
- **Cost optimization:** Serverless means no idle costs
- **Minimal operations:** Managed services reduce DevOps overhead
- **Generous free tiers:** Keep costs near zero during early stages
- **Production-ready:** AWS services are enterprise-grade
- **Quick deployment:** Serverless Framework enables rapid iteration

---

## System Components

### 1. Authentication & Authorization Service

**Responsibilities:**
- User registration and login
- Multi-factor authentication (MFA)
- Role-based access control (RBAC)
- OAuth2/OIDC for third-party integrations
- Session management
- API key management for integrations

**Implementation:**
- **AWS Cognito User Pools:** Managed user directory with built-in auth
- **Cognito Identity Pools:** Federated identities for third-party auth
- **Lambda Authorizers:** Custom authorization logic for API Gateway
- **JWT tokens:** Issued by Cognito, validated by API Gateway

**Lambda Functions:**
- `auth-signup`: Handle user registration with custom validations
- `auth-confirm`: Email/SMS confirmation handling
- `auth-login`: Custom login flows if needed (Cognito handles most)
- `auth-refresh`: Token refresh logic

### 2. Invoice Management Service

**Responsibilities:**
- CRUD operations for invoices
- Invoice versioning and history
- PDF generation
- Bulk import/export
- Invoice status tracking
- Custom fields per tenant

**Implementation:**
- **DynamoDB table:** Store invoice data with tenant isolation
- **S3:** Store generated PDF files
- **Lambda Layer:** Shared PDF generation library

**Lambda Functions:**
- `invoice-create`: Create new invoices
- `invoice-get`: Retrieve invoice details
- `invoice-update`: Update invoice information
- `invoice-delete`: Soft delete invoices
- `invoice-list`: List invoices with filtering/pagination
- `invoice-generate-pdf`: Generate PDF using Puppeteer or PDFKit
- `invoice-import`: Process bulk CSV/Excel uploads from S3
- CSV/Excel parsers for import

### 3. Reminder Scheduler Service

**Responsibilities:**
- Configure reminder rules per tenant
- Schedule reminders based on invoice due dates
- Support multiple reminder types (before due, on due, after due)
- Manage reminder templates
- Track reminder delivery status

**Implementation:**
- **EventBridge Scheduler:** Cron-based rule execution (replaces node-cron)
- **DynamoDB:** Store reminder configurations and schedules
- **SQS:** Queue reminder tasks for processing
- **Template storage:** S3 or DynamoDB for Handlebars/EJS templates

**Lambda Functions:**
- `reminder-schedule`: Calculate and create reminder schedules when invoice created
- `reminder-process`: Triggered by EventBridge to check due reminders
- `reminder-send`: Dequeue from SQS and send notifications
- `reminder-template-manage`: CRUD for reminder templates

**EventBridge Rules:**
- Daily cron: Check for reminders due today
- Hourly cron: Process urgent reminders
- DynamoDB Streams: Update schedules when invoices change

### 4. Notification Service

**Responsibilities:**
- Multi-channel message delivery (Email, SMS)
- Template rendering with dynamic data
- Delivery status tracking
- Retry logic for failed deliveries
- Unsubscribe management

**Implementation:**
- **Amazon SES:** Email sending (62,000 emails/month free from Lambda)
- **Amazon SNS:** SMS sending (or Twilio for better deliverability)
- **SQS with DLQ:** Retry failed deliveries with dead letter queue
- **DynamoDB:** Track delivery status and unsubscribe lists

**Lambda Functions:**
- `notification-send-email`: Render template and send via SES
- `notification-send-sms`: Send SMS via SNS or Twilio
- `notification-webhook`: Handle delivery status webhooks
- `notification-retry`: Process messages from DLQ

### 5. Payment Processing Service

**Responsibilities:**
- Payment gateway integration
- Payment link generation
- Payment status tracking
- Webhook handling from payment providers
- Invoice-payment reconciliation
- Refund processing

**Implementation:**
- **Stripe/PayPal SDK:** Payment processing
- **API Gateway:** Dedicated webhook endpoint with validation
- **DynamoDB:** Store payment records and link to invoices
- **Secrets Manager:** Store API keys securely

**Lambda Functions:**
- `payment-create-link`: Generate Stripe/PayPal payment link
- `payment-webhook-stripe`: Handle Stripe webhooks
- `payment-webhook-paypal`: Handle PayPal webhooks
- `payment-reconcile`: Match payments to invoices
- `payment-refund`: Process refund requests

### 6. Banking Integration Service

**Responsibilities:**
- Bank account connection
- Transaction retrieval
- Payment verification
- Balance checking
- Automated reconciliation

**Implementation:**
- **Plaid API:** Bank connectivity
- **Secrets Manager:** Secure storage of bank tokens
- **DynamoDB:** Store transaction data
- **EventBridge:** Schedule daily transaction syncs

**Lambda Functions:**
- `banking-connect`: Initialize Plaid Link flow
- `banking-exchange-token`: Exchange public token for access token
- `banking-sync-transactions`: Fetch new transactions daily
- `banking-match-payments`: Auto-match transactions to invoices
- `banking-webhook`: Handle Plaid webhooks

### 7. Analytics & Reporting Service

**Responsibilities:**
- Dashboard metrics (KPIs)
- Custom report generation
- Data export (CSV, Excel, PDF)
- Scheduled reports
- Payment trends and forecasting

**Implementation:**
- **DynamoDB:** Query and aggregate data using GSIs
- **S3:** Store generated report files
- **QuickSight (optional):** BI dashboards for enterprise customers
- **CloudWatch Logs Insights:** Query logs for analytics

**Lambda Functions:**
- `analytics-dashboard`: Calculate and return KPIs
- `analytics-generate-report`: Create custom reports (CSV, PDF)
- `analytics-schedule-report`: EventBridge-triggered scheduled reports
- `analytics-export-data`: Bulk export to S3

### 8. Tenant Management Service

**Responsibilities:**
- Organization/tenant provisioning
- Subscription plan management
- Usage tracking and limits
- Feature flags per tenant
- Billing and invoicing for the platform

**Implementation:**
- **DynamoDB:** Store tenant configuration and usage metrics
- **Parameter Store/Secrets Manager:** Store feature flags
- **CloudWatch Metrics:** Track usage for billing

**Lambda Functions:**
- `tenant-create`: Provision new tenant
- `tenant-update`: Update tenant settings
- `tenant-get-usage`: Calculate current usage against limits
- `tenant-check-limit`: Validate operations against limits

### 9. Customer Portal

**Responsibilities:**
- Invoice viewing for end customers
- Payment submission
- Payment history
- Notification preferences
- Receipt download

**Implementation:**
- **React SPA:** Hosted on S3 + CloudFront
- **API Gateway:** Public endpoints (no auth required for viewing with token)
- **Cognito:** Optional customer accounts for recurring customers

**Lambda Functions:**
- `customer-view-invoice`: Retrieve invoice by secure token
- `customer-payment-history`: Get payment records
- `customer-update-preferences`: Manage notification settings

---

## Third-Party Services

### Email Service

**Primary Provider:** Amazon SES
**Alternative:** SendGrid (if SES limits are restrictive)

**Features:**
- Transactional email delivery
- 62,000 emails/month free when sending from Lambda/EC2
- Template management via SES templates
- Bounce and complaint handling via SNS
- High deliverability rates

**Cost Comparison:**
- **SES:** $0.10 per 1,000 emails (after free tier)
- **SendGrid:** Free tier 100 emails/day, then $19.95/month for 50,000

**Reasoning:**
- SES is the most cost-effective option for AWS infrastructure
- Native integration with Lambda and SNS
- Generous free tier aligned with serverless strategy
- SendGrid as fallback for advanced template editor if needed

### SMS Service

**Primary Provider:** Amazon SNS
**Alternative:** Twilio (for better deliverability and advanced features)

**Features:**
- **SNS:** Simple SMS delivery, pay per message
- **Twilio:** Programmable messaging, delivery receipts, two-way messaging

**Cost Comparison:**
- **SNS:** $0.00645 per SMS (US), varies by country
- **Twilio:** $0.0079 per SMS (US), includes delivery tracking

**Reasoning:**
- SNS for basic SMS needs at lowest cost
- Twilio for production use when delivery confirmation is critical
- Both integrate easily with Lambda
- Can switch between providers based on tenant preferences

### Payment Gateway

**Primary Providers:**
- **Stripe:** For credit/debit cards, ACH, digital wallets
- **PayPal:** For PayPal account payments

**Features:**
- PCI compliance handled by provider
- Multiple payment methods
- Subscription billing
- Webhook notifications
- Dispute management
- International currencies

**Reasoning:**
- Stripe offers the best developer experience
- Comprehensive payment method support
- Strong security and compliance
- PayPal adds customer choice

### Banking Integration

**Primary Provider:** Plaid
**Alternative:** Yodlee, TrueLayer (for Europe)

**Features:**
- Bank account connection
- Transaction data retrieval
- Account verification
- Balance checking
- Real-time webhooks

**Reasoning:**
- Plaid has extensive bank coverage
- Secure authentication flow
- Reliable API
- Good documentation

### Additional Services

**Customer Support:**
- **Intercom** or **Zendesk** for customer support chat and ticketing

**Analytics:**
- **Google Analytics** for user behavior tracking
- **Mixpanel** or **Amplitude** for product analytics

**Communication:**
- **Slack** integration for team notifications
- **Webhook** support for custom integrations

---

## Multi-Tenancy Strategy

### Approach: Single-Table Design in DynamoDB

We will implement a **serverless multi-tenancy** approach using DynamoDB's single-table design pattern for cost optimization and performance.

#### Database Architecture

**Tenant Isolation Strategy:**
```typescript
// DynamoDB Single Table Design
// Every item includes tenant_id in the partition key for complete isolation

// Example item structures:
{
  PK: "TENANT#acme-corp-123",
  SK: "METADATA",
  name: "Acme Corporation",
  subdomain: "acme",
  plan: "professional",
  // ... tenant configuration
}

{
  PK: "TENANT#acme-corp-123",
  SK: "INVOICE#inv-456",
  invoiceId: "inv-456",
  customerId: "cust-789",
  amount: 1500.00,
  dueDate: "2025-11-15",
  status: "pending",
  // ... invoice data
}

{
  PK: "TENANT#acme-corp-123",
  SK: "USER#user-101",
  userId: "user-101",
  email: "john@acme.com",
  role: "admin",
  // ... user data
}
```

**Access Patterns:**
```typescript
// 1. Get tenant configuration
PK = "TENANT#{tenantId}" AND SK = "METADATA"

// 2. List all invoices for a tenant
PK = "TENANT#{tenantId}" AND SK begins_with "INVOICE#"

// 3. Get specific invoice
PK = "TENANT#{tenantId}" AND SK = "INVOICE#{invoiceId}"

// 4. Query invoices by status (using GSI)
GSI1PK = "TENANT#{tenantId}#STATUS#{status}"
GSI1SK = "INVOICE#{invoiceId}"

// 5. Query reminders by date (using GSI)
GSI2PK = "TENANT#{tenantId}#DATE#{YYYY-MM-DD}"
GSI2SK = "REMINDER#{reminderId}"
```

**Data Isolation Benefits:**
- **Complete Isolation:** Partition key includes tenant ID - impossible to access another tenant's data
- **Cost Efficient:** Single table = one set of RCU/WCU charges
- **Performance:** All tenant data co-located in same partition
- **Backup:** Single table to backup and restore

#### Tenant Configuration

Each tenant has:
```typescript
interface Tenant {
  // Primary identifiers (stored in DynamoDB)
  PK: string; // "TENANT#{tenantId}"
  SK: string; // "METADATA"
  
  id: string; // Tenant UUID
  name: string;
  subdomain: string; // e.g., acme.duemate.com
  customDomain?: string; // e.g., invoices.acme.com
  
  // Subscription & Limits
  plan: 'free' | 'basic' | 'professional' | 'enterprise';
  limits: {
    maxInvoices: number;
    maxUsers: number;
    maxMonthlyEmails: number;
    maxMonthlySMS: number;
  };
  
  // Current usage (updated by Lambda functions)
  usage: {
    invoiceCount: number;
    userCount: number;
    emailsSentThisMonth: number;
    smsSentThisMonth: number;
    lastResetDate: string; // ISO date
  };
  
  // Features
  features: {
    smsEnabled: boolean;
    apiAccess: boolean;
    customBranding: boolean;
    advancedReporting: boolean;
    bankingIntegration: boolean;
  };
  
  // Branding (for whitelabel)
  branding: {
    logoUrl?: string; // S3 URL
    primaryColor?: string;
    secondaryColor?: string;
    customCSS?: string; // S3 URL or inline
  };
  
  // Settings
  settings: {
    timezone: string;
    currency: string;
    dateFormat: string;
    emailFromAddress: string;
    emailFromName: string;
  };
  
  // Integration credentials (store ARNs to Secrets Manager)
  integrations: {
    stripeSecretArn?: string;
    twilioSecretArn?: string;
    plaidSecretArn?: string;
  };
  
  status: 'active' | 'suspended' | 'cancelled';
  createdAt: string; // ISO timestamp
  updatedAt: string; // ISO timestamp
}
```

#### Tenant Identification

**Request Flow:**
1. Client sends request to `acme.duemate.com` or with header `X-Tenant-ID`
2. API Gateway extracts tenant identifier from custom domain or header
3. Lambda authorizer or function code loads tenant from DynamoDB
4. All subsequent operations automatically scoped to tenant

**Implementation:**
```typescript
// Lambda function middleware for tenant context
export async function withTenantContext(event: APIGatewayEvent) {
  // Extract tenant from subdomain or header
  const subdomain = extractSubdomain(event.headers.Host);
  const tenantId = event.headers['x-tenant-id'];
  
  // Load tenant from DynamoDB (with caching via DAX if needed)
  const tenant = await getTenantBySubdomain(subdomain || tenantId);
  
  if (!tenant || tenant.status !== 'active') {
    return {
      statusCode: 403,
      body: JSON.stringify({ error: 'Invalid or inactive tenant' })
    };
  }
  
  // Check usage limits before processing
  await validateUsageLimits(tenant);
  
  return tenant;
}

// DynamoDB query with partition key ensures isolation
async function getInvoicesForTenant(tenantId: string) {
  const params = {
    TableName: 'duemate-main',
    KeyConditionExpression: 'PK = :pk AND begins_with(SK, :sk)',
    ExpressionAttributeValues: {
      ':pk': `TENANT#${tenantId}`,
      ':sk': 'INVOICE#'
    }
  };
  
  return dynamodb.query(params);
}
```

#### Data Isolation Benefits

- **Partition-Level Isolation:** Each tenant's data in separate partition key
- **No Cross-Tenant Queries:** DynamoDB requires partition key, making accidents impossible
- **Cost Efficient:** Single table with on-demand pricing
- **Scalability:** DynamoDB auto-scales per partition
- **Performance:** Sub-10ms reads with proper key design

#### Migration Path for Enterprise Customers

For customers requiring dedicated infrastructure:
- **Dedicated DynamoDB table:** Separate table per enterprise tenant
- **Dedicated AWS account:** Full isolation at AWS account level
- **VPC endpoints:** Private networking for maximum security
- **Reserved capacity:** Provisioned throughput for predictable performance

---

## Whitelabel Approach

### Levels of Whitelabeling

#### Level 1: Basic Customization (All Plans)
- Company name
- Logo
- Primary brand color
- Email footer customization

#### Level 2: Advanced Branding (Professional Plan)
- Custom color scheme (primary, secondary, accent colors)
- Custom email templates
- Custom notification messages
- Custom invoice templates
- Custom subdomain

#### Level 3: Full Whitelabel (Enterprise Plan)
- Custom domain with SSL
- Complete CSS customization
- White-labeled mobile apps
- Custom SMTP server
- Remove all DueMate branding
- API access for custom integrations

### Technical Implementation

#### 1. Dynamic Theme System

```typescript
// Theme configuration per tenant
interface TenantTheme {
  colors: {
    primary: string;
    secondary: string;
    accent: string;
    background: string;
    text: string;
  };
  typography: {
    fontFamily: string;
    fontSize: {
      base: string;
      heading: string;
    };
  };
  logo: {
    url: string;
    width: number;
    height: number;
  };
  customCSS?: string;
}

// React component using theme
function ThemedButton({ children }) {
  const theme = useTenantTheme();
  
  return (
    <button style={{
      backgroundColor: theme.colors.primary,
      color: theme.colors.text,
      fontFamily: theme.typography.fontFamily
    }}>
      {children}
    </button>
  );
}
```

#### 2. Custom Domain Support

**DNS Configuration:**
- Customer adds CNAME record: `invoices.acme.com` → `proxy.duemate.com`
- SSL certificate provisioned via Let's Encrypt
- Reverse proxy routes to correct tenant

**Implementation:**
- NGINX/Traefik for reverse proxy
- Automatic SSL via cert-manager (Kubernetes) or Certbot
- Domain verification before activation

#### 3. Template Customization

**Email Templates:**
- Handlebars/Liquid templates stored per tenant
- Visual template editor (optional)
- Variable injection for dynamic content
- Preview before sending

**Invoice Templates:**
- HTML/CSS templates
- PDF generation with custom styling
- Multiple template options per tenant

#### 4. Branded Mobile Apps

**Approach:** React Native + Dynamic Configuration
- Single codebase
- App configuration loaded from API at startup
- Dynamic app icon and splash screen (via CodePush or similar)
- For enterprise: Separate app store submissions with full branding

### Asset Management

**Storage:**
- Tenant assets stored in S3/Cloud Storage
- CDN for fast delivery (CloudFront/Cloudflare)
- Versioning for asset updates

**Organization:**
```
s3://duemate-assets/
  ├── tenants/
  │   ├── {tenant-id}/
  │   │   ├── logo.png
  │   │   ├── logo@2x.png
  │   │   ├── favicon.ico
  │   │   ├── email-header.png
  │   │   ├── invoice-template.html
  │   │   └── custom-styles.css
```

---

## Customer AWS Account Deployment

### Overview

DueMate supports **deployment into customer-owned AWS accounts** for enterprise customers who require:
- Complete infrastructure isolation and control
- Custom domain names (e.g., `invoices.acmecorp.com`)
- Compliance with data residency requirements
- Direct AWS cost visibility and control
- Full ownership of data and infrastructure

This deployment model uses **Infrastructure as Code (IaC)** to automate stack provisioning, making it straightforward to deploy and maintain multiple isolated instances.

### Deployment Models Comparison

| Feature | SaaS Multi-Tenant | Customer AWS Account |
|---------|-------------------|----------------------|
| **Infrastructure** | Shared AWS account | Dedicated customer account |
| **Data Isolation** | Logical (DynamoDB partitions) | Physical (separate account) |
| **Domain** | Subdomain (acme.duemate.com) | Custom domain (invoices.acme.com) |
| **Costs** | Included in subscription | Customer pays AWS directly |
| **Updates** | Automatic | Managed via CI/CD or manual |
| **Control** | Limited | Full administrative access |
| **Compliance** | Shared responsibility | Customer-controlled |
| **Best For** | SMBs, startups | Enterprises, regulated industries |

### Architecture for Customer AWS Deployment

The serverless architecture remains the same, but deployed entirely within the customer's AWS account:

```
Customer AWS Account: acmecorp-production
├── Region: us-east-1 (or customer choice)
│   ├── Lambda Functions
│   │   ├── API handlers (invoice-*, payment-*, etc.)
│   │   ├── Background workers (reminder-*, notification-*)
│   │   └── Scheduled jobs (EventBridge triggers)
│   │
│   ├── API Gateway
│   │   ├── REST API: api.invoices.acmecorp.com
│   │   └── Custom domain with ACM certificate
│   │
│   ├── DynamoDB
│   │   ├── Main table: acmecorp-duemate-main
│   │   └── Backup/PITR enabled
│   │
│   ├── S3 Buckets
│   │   ├── Frontend hosting: invoices.acmecorp.com
│   │   ├── Invoice PDFs: acmecorp-duemate-invoices
│   │   └── Assets/uploads: acmecorp-duemate-assets
│   │
│   ├── CloudFront Distribution
│   │   ├── Custom domain: invoices.acmecorp.com
│   │   └── SSL/TLS certificate (ACM)
│   │
│   ├── Cognito User Pool
│   │   └── User authentication & management
│   │
│   ├── EventBridge Rules
│   │   └── Scheduled reminder checks
│   │
│   ├── SQS Queues
│   │   ├── Notification queue
│   │   └── Dead letter queues
│   │
│   ├── Secrets Manager
│   │   ├── Stripe API keys
│   │   ├── Twilio credentials
│   │   └── Third-party integrations
│   │
│   └── CloudWatch
│       ├── Logs (all Lambda functions)
│       ├── Metrics & Dashboards
│       └── Alarms
```

### Prerequisites for Customer Deployment

**Customer Requirements:**
1. **AWS Account** with administrative access
2. **Domain name** registered (Route53 or external registrar)
3. **AWS CLI** configured with appropriate credentials
4. **Third-party accounts** (optional):
   - Stripe account for payments
   - Twilio account for SMS (or use AWS SNS)
   - Plaid account for banking integration

**Technical Prerequisites:**
```bash
# Required tools
- Node.js 20+
- AWS CLI v2
- Serverless Framework OR AWS SAM CLI
- Git

# Recommended tools
- Docker (for local testing)
- Terraform (alternative to Serverless Framework)
```

### Deployment Process

#### Option 1: Automated Deployment via Serverless Framework

**1. Configuration File (`serverless.yml`)**
```yaml
service: duemate-${self:custom.customerName}

provider:
  name: aws
  runtime: nodejs20.x
  region: ${opt:region, 'us-east-1'}
  stage: ${opt:stage, 'production'}
  
  # Customer-specific environment variables
  environment:
    CUSTOMER_NAME: ${self:custom.customerName}
    CUSTOM_DOMAIN: ${self:custom.customDomain}
    TABLE_NAME: ${self:custom.tableName}
    STAGE: ${self:provider.stage}

custom:
  # Customer-specific configuration
  customerName: acmecorp
  customDomain: invoices.acmecorp.com
  tableName: ${self:custom.customerName}-duemate-main
  
  # Custom domain configuration
  customDomain:
    domainName: ${self:custom.customDomain}
    certificateName: ${self:custom.customDomain}
    basePath: ''
    stage: ${self:provider.stage}
    createRoute53Record: true

resources:
  Resources:
    # DynamoDB Table
    DueMateMainTable:
      Type: AWS::DynamoDB::Table
      Properties:
        TableName: ${self:custom.tableName}
        BillingMode: PAY_PER_REQUEST
        AttributeDefinitions:
          - AttributeName: PK
            AttributeType: S
          - AttributeName: SK
            AttributeType: S
          - AttributeName: GSI1PK
            AttributeType: S
          - AttributeName: GSI1SK
            AttributeType: S
        KeySchema:
          - AttributeName: PK
            KeyType: HASH
          - AttributeName: SK
            KeyType: RANGE
        GlobalSecondaryIndexes:
          - IndexName: GSI1
            KeySchema:
              - AttributeName: GSI1PK
                KeyType: HASH
              - AttributeName: GSI1SK
                KeyType: RANGE
            Projection:
              ProjectionType: ALL
        PointInTimeRecoverySpecification:
          PointInTimeRecoveryEnabled: true
        SSESpecification:
          SSEEnabled: true

functions:
  # API Functions
  invoiceCreate:
    handler: src/handlers/invoice/create.handler
    events:
      - http:
          path: /invoices
          method: post
          cors: true
          authorizer:
            type: COGNITO_USER_POOLS
            authorizerId: !Ref ApiGatewayAuthorizer
  
  # ... (other functions)
```

**2. Deploy to Customer AWS Account**
```bash
# Configure AWS credentials for customer account
export AWS_PROFILE=acmecorp-production

# Deploy the stack
serverless deploy \
  --stage production \
  --region us-east-1 \
  --param="customerName=acmecorp" \
  --param="customDomain=invoices.acmecorp.com"

# Expected output:
# ✔ Service deployed to stack duemate-acmecorp-production
# ✔ API Gateway: https://api.invoices.acmecorp.com
# ✔ Frontend: https://invoices.acmecorp.com
# ✔ DynamoDB: acmecorp-duemate-main
```

#### Option 2: AWS SAM Deployment

**SAM Template (`template.yaml`)**
```yaml
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31

Parameters:
  CustomerName:
    Type: String
    Default: acmecorp
  CustomDomain:
    Type: String
    Default: invoices.acmecorp.com
  Environment:
    Type: String
    Default: production
    AllowedValues: [production, staging]

Globals:
  Function:
    Runtime: nodejs20.x
    Timeout: 30
    MemorySize: 512
    Environment:
      Variables:
        TABLE_NAME: !Ref DueMateMainTable
        CUSTOMER_NAME: !Ref CustomerName

Resources:
  # API Gateway
  DueMateApi:
    Type: AWS::Serverless::Api
    Properties:
      StageName: !Ref Environment
      Domain:
        DomainName: !Sub 'api.${CustomDomain}'
        CertificateArn: !Ref ApiCertificate

  # Lambda Functions
  InvoiceCreateFunction:
    Type: AWS::Serverless::Function
    Properties:
      CodeUri: dist/
      Handler: invoice-create.handler
      Events:
        CreateInvoice:
          Type: Api
          Properties:
            RestApiId: !Ref DueMateApi
            Path: /invoices
            Method: POST

  # DynamoDB Table
  DueMateMainTable:
    Type: AWS::DynamoDB::Table
    Properties:
      TableName: !Sub '${CustomerName}-duemate-main'
      BillingMode: PAY_PER_REQUEST
      # ... (same as serverless config)

Outputs:
  ApiEndpoint:
    Value: !Sub 'https://api.${CustomDomain}'
  FrontendUrl:
    Value: !Sub 'https://${CustomDomain}'
  TableName:
    Value: !Ref DueMateMainTable
```

**Deploy with SAM**
```bash
# Build
sam build

# Deploy
sam deploy \
  --stack-name duemate-acmecorp \
  --parameter-overrides \
    CustomerName=acmecorp \
    CustomDomain=invoices.acmecorp.com \
    Environment=production \
  --capabilities CAPABILITY_IAM \
  --region us-east-1
```

#### Option 3: Terraform Deployment (Alternative)

```hcl
# main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "customer_name" {
  default = "acmecorp"
}

variable "custom_domain" {
  default = "invoices.acmecorp.com"
}

# DynamoDB Table
resource "aws_dynamodb_table" "main" {
  name           = "${var.customer_name}-duemate-main"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "PK"
  range_key      = "SK"

  attribute {
    name = "PK"
    type = "S"
  }
  
  # ... (rest of configuration)
}

# Deploy with:
# terraform init
# terraform apply -var="customer_name=acmecorp"
```

### Custom Domain Configuration

**Step 1: Request SSL Certificate**
```bash
# Using AWS Certificate Manager
aws acm request-certificate \
  --domain-name invoices.acmecorp.com \
  --subject-alternative-names '*.invoices.acmecorp.com' \
  --validation-method DNS \
  --region us-east-1

# Note: For CloudFront, certificate MUST be in us-east-1
```

**Step 2: DNS Configuration**

If customer uses **Route53**:
```bash
# Serverless Framework automatically creates Route53 records
# OR manually:
aws route53 change-resource-record-sets \
  --hosted-zone-id Z1234567890ABC \
  --change-batch file://dns-changes.json
```

If customer uses **external DNS provider** (GoDaddy, Cloudflare, etc.):
```
# Add these DNS records:

# Frontend (CloudFront)
CNAME  invoices.acmecorp.com  -> d1234567890.cloudfront.net

# API (API Gateway)
CNAME  api.invoices.acmecorp.com  -> xyz123.execute-api.us-east-1.amazonaws.com

# Email verification (SES - if using custom domain)
TXT  _amazonses.acmecorp.com  -> verification-token
MX   acmecorp.com  -> 10 inbound-smtp.us-east-1.amazonaws.com
```

**Step 3: Validate Certificate**
```bash
# Check certificate status
aws acm describe-certificate \
  --certificate-arn arn:aws:acm:us-east-1:123456789012:certificate/abc...

# Once validated, certificate is ready for use
```

### Configuration File Structure

**Customer-specific configuration (`config/acmecorp.json`)**
```json
{
  "customerName": "acmecorp",
  "customDomain": "invoices.acmecorp.com",
  "awsRegion": "us-east-1",
  "environment": "production",
  
  "branding": {
    "companyName": "Acme Corporation",
    "logoUrl": "https://invoices.acmecorp.com/assets/logo.png",
    "primaryColor": "#0066CC",
    "supportEmail": "support@acmecorp.com"
  },
  
  "features": {
    "smsEnabled": true,
    "emailProvider": "ses",
    "smsProvider": "twilio",
    "paymentsEnabled": true,
    "bankingIntegration": true
  },
  
  "integrations": {
    "stripe": {
      "secretArn": "arn:aws:secretsmanager:us-east-1:123456789012:secret:acmecorp/stripe"
    },
    "twilio": {
      "secretArn": "arn:aws:secretsmanager:us-east-1:123456789012:secret:acmecorp/twilio"
    },
    "plaid": {
      "secretArn": "arn:aws:secretsmanager:us-east-1:123456789012:secret:acmecorp/plaid"
    }
  },
  
  "security": {
    "mfaRequired": true,
    "passwordMinLength": 12,
    "sessionTimeoutMinutes": 60,
    "ipWhitelist": []
  },
  
  "notifications": {
    "adminEmail": "admin@acmecorp.com",
    "alertEmail": "alerts@acmecorp.com"
  }
}
```

### Updates and Maintenance

**Option 1: Managed Updates (Recommended)**

Create a CI/CD pipeline that customer controls:

```yaml
# .github/workflows/deploy-customer.yml
name: Deploy to Customer AWS

on:
  push:
    branches: [main]
    tags: ['v*']

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          role-to-assume: arn:aws:iam::${{ secrets.CUSTOMER_AWS_ACCOUNT }}:role/DueMateDeployRole
          aws-region: us-east-1
      
      - name: Deploy Stack
        run: |
          npm ci
          npm run build
          serverless deploy --stage production
      
      - name: Run Smoke Tests
        run: npm run test:smoke
```

**Option 2: Manual Updates**

Customer can update when ready:
```bash
# Pull latest version
git pull origin main

# Review changes
git log --oneline -5

# Deploy update
serverless deploy --stage production

# Rollback if needed
serverless deploy --stage production --package .serverless-backup
```

**Option 3: Versioned Releases**

Tag releases for controlled updates:
```bash
# List available versions
git tag

# Deploy specific version
git checkout v1.2.0
serverless deploy --stage production
```

### Monitoring and Observability

Customer has full access to CloudWatch:

```bash
# View Lambda logs
aws logs tail /aws/lambda/duemate-acmecorp-invoiceCreate --follow

# Create custom dashboard
aws cloudwatch put-dashboard \
  --dashboard-name DueMate-Overview \
  --dashboard-body file://dashboard.json

# Set up alarms
aws cloudwatch put-metric-alarm \
  --alarm-name duemate-high-errors \
  --alarm-description "Alert on high error rate" \
  --metric-name Errors \
  --namespace AWS/Lambda \
  --statistic Sum \
  --period 300 \
  --threshold 10 \
  --comparison-operator GreaterThanThreshold
```

### Cost Management

Customer pays AWS directly and can:

1. **Enable Cost Allocation Tags**
```bash
# Tag all resources
serverless deploy --tags Project=DueMate,Customer=acmecorp,Environment=production
```

2. **Set Budget Alerts**
```bash
aws budgets create-budget \
  --account-id 123456789012 \
  --budget file://budget.json \
  --notifications-with-subscribers file://notifications.json
```

3. **Use AWS Cost Explorer**
- Filter by tags: `Project=DueMate`
- View daily/monthly costs
- Forecast future costs

### Data Backup and Disaster Recovery

**DynamoDB Backups:**
```bash
# Automated backups (PITR enabled by default)
# Manual backup
aws dynamodb create-backup \
  --table-name acmecorp-duemate-main \
  --backup-name manual-backup-$(date +%Y%m%d)

# Restore from backup
aws dynamodb restore-table-from-backup \
  --target-table-name acmecorp-duemate-main-restored \
  --backup-arn arn:aws:dynamodb:...
```

**S3 Versioning:**
```bash
# Enable versioning on invoice bucket
aws s3api put-bucket-versioning \
  --bucket acmecorp-duemate-invoices \
  --versioning-configuration Status=Enabled
```

### Security Considerations

**IAM Roles and Permissions:**
- Lambda execution role with least privilege
- API Gateway invoke permissions
- DynamoDB read/write permissions only for specific tables
- Secrets Manager read-only for integration credentials

**Network Security:**
- Optional: Deploy Lambda in VPC for enhanced security
- VPC endpoints for AWS services (no internet traffic)
- Security groups and NACLs as needed

**Compliance:**
- Customer controls data residency (AWS region choice)
- Customer owns encryption keys (option to use customer-managed KMS keys)
- CloudTrail enabled for audit logging
- AWS Config for compliance monitoring

### Migration from SaaS to Customer AWS

If customer starts on shared SaaS and wants to migrate:

**1. Export Data**
```bash
# Export all tenant data from shared account
npm run export:tenant -- --tenant-id=acmecorp --output=acmecorp-export.json
```

**2. Deploy Stack in Customer Account**
```bash
serverless deploy --stage production
```

**3. Import Data**
```bash
# Import to customer's DynamoDB
npm run import:data -- --file=acmecorp-export.json --table=acmecorp-duemate-main
```

**4. Update DNS**
```bash
# Point custom domain to new deployment
# Update DNS records to new CloudFront/API Gateway endpoints
```

**5. Validate and Cutover**
```bash
# Run validation tests
npm run test:migration

# Monitor for 24-48 hours before decommissioning old tenant
```

### Licensing and Distribution

**Licensing Models:**

1. **Perpetual License**
   - One-time fee for specific version
   - Customer deploys and manages
   - Updates available via annual support contract

2. **Subscription License**
   - Annual/monthly licensing fee
   - Includes updates and support
   - Customer still pays AWS costs directly

3. **Hybrid Model**
   - Base platform fee + usage-based fee
   - Platform license + support
   - Customer pays AWS directly

**Code Distribution:**

```bash
# Option 1: Private GitHub repository access
# Grant customer read access to private repo

# Option 2: Packaged release
# Provide ZIP/TAR of specific version

# Option 3: Container image
# Push to customer's ECR (if using containers)

# Option 4: AWS Marketplace
# Publish as AWS Marketplace solution (CloudFormation template)
```

### Support Model

**Support Tiers:**

1. **Self-Service**
   - Documentation only
   - Community forums
   - Bug fixes via updates

2. **Email Support**
   - Response within 24-48 hours
   - Deployment assistance
   - Configuration guidance

3. **Premium Support**
   - Priority response (4-hour SLA)
   - Dedicated Slack channel
   - Quarterly architecture reviews
   - Assisted deployments

### Deployment Checklist

**Pre-Deployment:**
- [ ] Customer AWS account created and accessible
- [ ] Domain name registered and accessible
- [ ] SSL certificate requested in ACM (us-east-1)
- [ ] Third-party API keys obtained (Stripe, Twilio, Plaid)
- [ ] Customer configuration file created
- [ ] IaC templates customized for customer

**Deployment:**
- [ ] Deploy infrastructure via Serverless/SAM/Terraform
- [ ] Validate all Lambda functions deployed
- [ ] Verify DynamoDB table created with correct schema
- [ ] Configure custom domain with certificate
- [ ] Update DNS records
- [ ] Deploy frontend to S3 + CloudFront
- [ ] Configure Cognito user pool
- [ ] Store secrets in Secrets Manager
- [ ] Set up EventBridge rules for scheduling

**Post-Deployment:**
- [ ] Verify SSL certificates active
- [ ] Test all API endpoints
- [ ] Create initial admin user
- [ ] Configure CloudWatch alarms
- [ ] Set up cost monitoring and budgets
- [ ] Enable CloudTrail for audit logging
- [ ] Create backups of DynamoDB table
- [ ] Document customer-specific configuration
- [ ] Provide access credentials to customer
- [ ] Conduct deployment handoff meeting

---

## Data Flow

### 1. Invoice Creation & Reminder Flow

```
┌──────────────┐
│   Client     │
│ (Web/Mobile) │
└──────┬───────┘
       │ 1. Create Invoice
       ▼
┌──────────────┐
│   API        │ 2. Validate & Store
│   Gateway    │────────────────────┐
└──────────────┘                    │
                                    ▼
                            ┌───────────────┐
                            │  PostgreSQL   │
                            │  (Invoices)   │
                            └───────┬───────┘
                                    │
                    3. Trigger Reminder Schedule
                                    │
                                    ▼
                            ┌───────────────┐
                            │  Scheduler    │
                            │  Service      │
                            └───────┬───────┘
                                    │
                    4. Enqueue Reminder Jobs
                                    │
                                    ▼
                            ┌───────────────┐
                            │  Bull Queue   │
                            │  (Redis)      │
                            └───────┬───────┘
                                    │
                    5. Process Reminder
                                    │
                ┌───────────────────┼───────────────────┐
                │                   │                   │
                ▼                   ▼                   ▼
        ┌───────────────┐   ┌──────────────┐   ┌─────────────┐
        │  Email Worker │   │  SMS Worker  │   │ Webhook     │
        │  (SendGrid)   │   │  (Twilio)    │   │ Worker      │
        └───────┬───────┘   └──────┬───────┘   └─────┬───────┘
                │                   │                  │
                └───────────────────┼──────────────────┘
                                    │
                    6. Log Delivery Status
                                    │
                                    ▼
                            ┌───────────────┐
                            │  PostgreSQL   │
                            │  (Logs)       │
                            └───────────────┘
```

### 2. Payment Flow

```
┌──────────────┐
│  Customer    │
│  Portal      │
└──────┬───────┘
       │ 1. Click Pay Invoice
       ▼
┌──────────────┐
│  Payment     │ 2. Create Payment Intent
│  Service     │────────────────────┐
└──────────────┘                    │
                                    ▼
                            ┌───────────────┐
                            │  Stripe API   │
                            └───────┬───────┘
                                    │
                    3. Return Payment UI/Link
                                    │
                                    ▼
                            ┌───────────────┐
                            │  Customer     │
                            │  Completes    │
                            │  Payment      │
                            └───────┬───────┘
                                    │
                        4. Webhook Notification
                                    │
                                    ▼
                            ┌───────────────┐
                            │  Webhook      │
                            │  Handler      │
                            └───────┬───────┘
                                    │
                5. Update Invoice Status
                                    │
                                    ▼
                            ┌───────────────┐
                            │  PostgreSQL   │
                            │  (Invoices)   │
                            └───────┬───────┘
                                    │
                    6. Send Confirmation
                                    │
                ┌───────────────────┴───────────────────┐
                │                                       │
                ▼                                       ▼
        ┌───────────────┐                      ┌──────────────┐
        │  Customer      │                      │  Business    │
        │  Receipt Email │                      │  Notification│
        └────────────────┘                      └──────────────┘
```

### 3. Bank Reconciliation Flow

```
┌──────────────┐
│  Scheduled   │ 1. Daily Sync Job
│  Job         │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  Banking     │ 2. Fetch Transactions
│  Integration │────────────────────┐
│  Service     │                    │
└──────────────┘                    ▼
                            ┌───────────────┐
                            │  Plaid API    │
                            └───────┬───────┘
                                    │
                        3. Return Transactions
                                    │
                                    ▼
                            ┌───────────────┐
                            │  Matching     │
                            │  Algorithm    │
                            └───────┬───────┘
                                    │
                    4. Match with Invoices
                                    │
                ┌───────────────────┴───────────────────┐
                │                                       │
                ▼                                       ▼
        ┌───────────────┐                      ┌──────────────┐
        │  Auto-Match   │                      │  Manual      │
        │  Invoices     │                      │  Review      │
        └───────┬───────┘                      └──────┬───────┘
                │                                      │
                └──────────────┬───────────────────────┘
                               │
                5. Update Invoice Status
                               │
                               ▼
                        ┌───────────────┐
                        │  PostgreSQL   │
                        │  (Invoices)   │
                        └───────────────┘
```

---

## Security Considerations

### 1. Authentication & Authorization

- **Multi-Factor Authentication (MFA):** Optional for users, mandatory for admin accounts
- **Password Policy:** Minimum length, complexity requirements, rotation
- **Session Management:** Secure JWT tokens with short expiration, refresh tokens
- **API Security:** API key authentication, rate limiting, IP whitelisting (optional)

### 2. Data Protection

- **Encryption at Rest:** Database encryption, encrypted file storage
- **Encryption in Transit:** TLS 1.3 for all communications
- **PII Handling:** Customer data encrypted, right to deletion (GDPR compliance)
- **Credential Storage:** Vault (HashiCorp Vault / AWS Secrets Manager) for API keys and secrets

### 3. Multi-Tenancy Security

- **Data Isolation:** Row-level security enforced at database level
- **Tenant Validation:** Every request validates tenant context
- **No Cross-Tenant Access:** Strict middleware enforcement
- **Audit Logging:** All data access logged per tenant

### 4. Payment Security

- **PCI Compliance:** Never store card details; use Stripe/PayPal tokenization
- **Webhook Validation:** Verify signatures for all payment webhooks
- **Idempotency:** Prevent duplicate charges
- **Secure Transmission:** All payment data over HTTPS

### 5. Application Security

- **Input Validation:** All user inputs validated and sanitized
- **SQL Injection Prevention:** Parameterized queries via ORM
- **XSS Prevention:** Content Security Policy, output encoding
- **CSRF Protection:** CSRF tokens for state-changing operations
- **Rate Limiting:** API rate limits per tenant and user
- **DDoS Protection:** Cloudflare or AWS Shield

### 6. Infrastructure Security

- **Network Isolation:** VPC with private subnets for databases
- **Firewall Rules:** Restrictive security groups, minimal port exposure
- **Regular Updates:** Automated security patches
- **Vulnerability Scanning:** Regular security audits
- **Penetration Testing:** Annual third-party security assessment

### 7. Compliance

- **GDPR:** Data privacy controls, right to access and deletion
- **SOC 2:** Security and availability controls (for enterprise)
- **CCPA:** California privacy law compliance
- **PCI DSS:** Payment card industry compliance via third-party processors

---

## Scalability & Performance

### Serverless Scaling Strategy

**Automatic Scaling:**
- **Lambda:** Scales from 0 to 1,000+ concurrent executions automatically
- **DynamoDB:** On-demand mode auto-scales based on traffic
- **API Gateway:** Handles 10,000 requests/second by default
- **S3 & CloudFront:** Virtually unlimited scale

**No Traditional Scaling Concerns:**
- No server provisioning or capacity planning
- No load balancer configuration
- No connection pool management
- No horizontal/vertical scaling decisions

### Caching Strategy

**API Gateway Caching (Optional):**
- Enable for GET endpoints with predictable responses
- Reduces Lambda invocations and costs
- TTL: 5-60 minutes based on data volatility

**DynamoDB DAX (Optional for High Traffic):**
- In-memory cache for DynamoDB
- Microsecond latency for reads
- Only enable when consistently > 1M requests/day
- Cost: ~$0.12/hour for smallest node

**CloudFront Caching:**
- Cache static assets (frontend, images, PDFs)
- Edge location caching reduces S3 costs
- Automatic cache invalidation on deployment

### Performance Targets

- **API Response Time:** <300ms for 95th percentile (includes cold starts)
- **Cold Start Time:** <1s for Node.js Lambda (optimized with esbuild)
- **Warm Invocation:** <100ms for business logic
- **DynamoDB Read:** <10ms single-item get
- **DynamoDB Query:** <50ms for paginated results
- **Email Delivery:** Within 5 minutes of scheduled time
- **SMS Delivery:** Within 2 minutes of scheduled time
- **Uptime:** 99.9% SLA (leveraging AWS managed services)

### Cold Start Mitigation

**Strategies:**
- Use Node.js (fastest cold start runtime)
- Bundle with esbuild for smaller packages (<1MB)
- Provisioned concurrency for critical functions (costs $$$, use sparingly)
- EventBridge scheduled pings to keep warm (optional)
- Minimize dependencies in Lambda functions

### Monitoring & Optimization

**CloudWatch Metrics (Automatic):**
- Lambda: Invocations, Duration, Errors, Throttles, Cold Starts
- DynamoDB: Read/Write capacity, Throttled requests, Latency
- API Gateway: Request count, Latency, 4xx/5xx errors
- SQS: Messages sent, received, deleted, queue depth

**CloudWatch Alarms (Free Tier: 10 alarms):**
- Lambda error rate > 1%
- API Gateway 5xx errors > 5%
- DynamoDB throttled requests > 0
- SQS queue depth > 100 messages
- Lambda concurrent executions > 80% of limit

**Cost Monitoring:**
- AWS Cost Explorer for daily cost tracking
- Budget alerts for monthly spending thresholds
- Tag resources by tenant for cost allocation

### Cost Optimization Strategies

1. **Right-size Lambda memory:** Start at 512MB, optimize based on metrics
2. **Use on-demand DynamoDB:** Pay per request vs. provisioned capacity
3. **S3 Intelligent-Tiering:** Automatic cost optimization for file storage
4. **CloudFront compression:** Reduce data transfer costs
5. **SES over SendGrid:** 62,000 free emails/month
6. **SNS over Twilio:** Lower SMS costs for basic delivery
7. **Reserved capacity:** Only for proven consistent workloads

---

## Cost Breakdown & Projections

### Monthly Cost Estimates (USD)

#### Scenario 1: Startup Phase (1-10 tenants, ~100 invoices/month)

| Service | Usage | Cost |
|---------|-------|------|
| **Lambda** | 50,000 requests, 100ms avg, 512MB | $0 (free tier) |
| **API Gateway** | 50,000 API calls | $0 (free tier 1st year) |
| **DynamoDB** | 5GB storage, 100K reads, 50K writes | $0 (free tier) |
| **S3** | 2GB storage, 10K requests | $0 (free tier 1st year) |
| **CloudFront** | 10GB data transfer | $0 (free tier 1st year) |
| **SES** | 5,000 emails | $0 (free tier) |
| **SNS SMS** | 100 SMS (US) | $0.65 |
| **Cognito** | 500 MAU | $0 (free tier) |
| **EventBridge** | 1M events | $0 (free tier) |
| **CloudWatch Logs** | 2GB ingested | $0.50 |
| **Secrets Manager** | 3 secrets | $1.20 |
| **Route53** | 1 hosted zone | $0.50 |
| **TOTAL** | | **~$3/month** |

#### Scenario 2: Growth Phase (50 tenants, ~1,000 invoices/month)

| Service | Usage | Cost |
|---------|-------|------|
| **Lambda** | 500K requests, 100ms avg, 512MB | $0.83 |
| **API Gateway** | 500K API calls | $1.75 |
| **DynamoDB** | 15GB storage, 1M reads, 500K writes | $3.75 |
| **S3** | 20GB storage, 100K requests | $0.85 |
| **CloudFront** | 100GB data transfer | $8.50 |
| **SES** | 50,000 emails | $5.00 |
| **SNS SMS** | 1,000 SMS (US) | $6.45 |
| **Cognito** | 5,000 MAU | $13.75 |
| **EventBridge** | 10M events | $1.00 |
| **CloudWatch** | 15GB logs, alarms | $7.50 |
| **Secrets Manager** | 5 secrets | $2.00 |
| **Route53** | 2 hosted zones | $1.00 |
| **TOTAL** | | **~$52/month** |

#### Scenario 3: Scale Phase (500 tenants, ~10,000 invoices/month)

| Service | Usage | Cost |
|---------|-------|------|
| **Lambda** | 5M requests, 100ms avg, 512MB | $8.33 |
| **API Gateway** | 5M API calls | $17.50 |
| **DynamoDB** | 100GB storage, 10M reads, 5M writes | $33.00 |
| **S3** | 200GB storage, 1M requests | $6.60 |
| **CloudFront** | 1TB data transfer | $85.00 |
| **SES** | 500,000 emails | $50.00 |
| **SNS SMS** | 10,000 SMS (US) | $64.50 |
| **Cognito** | 50,000 MAU | $275.00 |
| **EventBridge** | 100M events | $10.00 |
| **CloudWatch** | 100GB logs, monitoring | $51.00 |
| **Secrets Manager** | 10 secrets | $4.00 |
| **Route53** | 5 hosted zones | $2.50 |
| **TOTAL** | | **~$607/month** |

### Cost Optimization Tips

1. **Use AWS Free Tier maximally in first year**
2. **Choose on-demand DynamoDB** until predictable traffic
3. **Enable S3 Intelligent-Tiering** for older files
4. **Use SES instead of SendGrid** (free tier is 62K emails/month)
5. **Compress CloudFront responses** to reduce data transfer
6. **Archive old CloudWatch Logs** to S3 after 30 days
7. **Right-size Lambda memory** based on actual usage metrics
8. **Use AWS Cost Anomaly Detection** for unexpected charges
9. **Tag all resources** for cost allocation per tenant
10. **Set billing alarms** at $10, $50, $100, $500 thresholds

### Revenue Model Suggestions

To ensure profitability with these costs:

| Plan | Price/Month | Invoices Included | Margins |
|------|-------------|-------------------|---------|
| **Free** | $0 | 50 invoices | Loss leader |
| **Starter** | $19 | 200 invoices | ~60% margin |
| **Professional** | $49 | 1,000 invoices | ~75% margin |
| **Business** | $149 | 5,000 invoices | ~80% margin |
| **Enterprise** | Custom | Unlimited | 85%+ margin |

**Additional revenue streams:**
- SMS credits: $0.02/SMS (vs $0.0065 cost)
- Extra users: $5/user/month
- API access: $29/month add-on
- White-label branding: $99/month add-on
- Premium support: $199/month
- **Customer AWS deployment:** One-time setup fee ($5,000-$15,000) + annual license

---

## Future Considerations

### Phase 2 Enhancements
- Mobile applications (iOS/Android) using React Native
- Advanced analytics with QuickSight dashboards
- Machine learning for payment prediction (SageMaker)
- Multi-currency and international support
- Accounting software integrations (QuickBooks, Xero) via OAuth

### Serverless Evolution
- **AWS AppSync:** GraphQL API for real-time features
- **Step Functions:** Complex workflow orchestration
- **Aurora Serverless:** If relational data needs grow (hybrid approach)
- **EventBridge Pipes:** Enhanced event routing
- **Lambda@Edge:** Geo-distributed logic

### Advanced Features
- Voice call reminders (Amazon Connect or Twilio)
- WhatsApp/Telegram notifications (Business APIs)
- Automated payment plans with Step Functions
- Customer credit scoring using SageMaker
- Blockchain-based payment verification (experimental)

### Global Expansion
- **CloudFront** for global CDN
- **DynamoDB Global Tables** for multi-region active-active
- **Route53 geolocation routing** for regional API endpoints
- **Multi-region Lambda** deployment via AWS SAM
- **Currency localization** with automated exchange rates

---

## Conclusion

This serverless architecture provides DueMate with:
- **Near-zero baseline costs** during early development and low-traffic periods
- **Automatic scalability** from 0 to millions of requests without manual intervention
- **No infrastructure management** - focus entirely on business logic
- **Predictable scaling costs** - pay only for actual usage
- **Production-grade reliability** - leveraging AWS managed services
- **Fast iteration cycles** - deploy changes in minutes via CI/CD
- **Multi-tenancy ready** - secure isolation via DynamoDB partition keys
- **Whitelabel support** - flexible branding via S3 and CloudFront
- **Flexible deployment** - SaaS multi-tenant OR customer AWS accounts

The chosen **serverless-first AWS stack** balances:
- ✅ **Minimal operational overhead** (no servers to manage)
- ✅ **Extremely low startup costs** (leveraging generous free tiers)
- ✅ **Linear cost scaling** (costs grow proportionally with usage)
- ✅ **Production reliability** (AWS SLAs and managed services)
- ✅ **Developer productivity** (TypeScript, modern tooling, IaC)
- ✅ **Deployment flexibility** (shared SaaS or dedicated customer accounts)

This approach enables a **solo developer or small team** to build and launch DueMate with near-zero infrastructure costs while maintaining the ability to:
- Scale to thousands of customers in a shared SaaS model
- Deploy dedicated instances in customer AWS accounts with custom domains
- Support both deployment models simultaneously with the same codebase

---

## Appendix

### Development Environment Setup

**Prerequisites:**
- Node.js 20 LTS
- AWS CLI configured with credentials
- AWS SAM CLI or Serverless Framework
- Docker (for local Lambda testing)

**Local Development:**
```bash
# Clone repository
git clone https://github.com/yourorg/duemate.git
cd duemate

# Install dependencies
npm install

# Install Serverless Framework globally (or use SAM)
npm install -g serverless

# Configure environment variables
cp .env.example .env.local
# Edit .env.local with local DynamoDB, etc.

# Start local DynamoDB (using Docker)
docker run -p 8000:8000 amazon/dynamodb-local

# Create local tables
npm run db:setup-local

# Start local API using SAM or Serverless Offline
serverless offline start
# OR
sam local start-api

# Frontend development
cd frontend
npm install
npm run dev
```

**Testing Locally:**
```bash
# Unit tests
npm test

# Integration tests with local DynamoDB
npm run test:integration

# E2E tests
npm run test:e2e

# Invoke specific Lambda locally
sam local invoke InvoiceCreateFunction --event events/invoice-create.json
```

### Deployment Pipeline

**GitHub Actions Workflow:**
```yaml
# .github/workflows/deploy.yml
name: Deploy to AWS

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '20'
      - run: npm ci
      - run: npm test
      - run: npm run lint

  deploy-staging:
    needs: test
    if: github.ref == 'refs/heads/develop'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm ci
      - run: serverless deploy --stage staging

  deploy-production:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm ci
      - run: serverless deploy --stage production
```

**Deployment Stages:**
1. **Development:** Local development with SAM/Serverless Offline
2. **Staging:** Auto-deploy on merge to `develop` branch
3. **Production:** Auto-deploy on merge to `main` branch
4. **Rollback:** Use AWS Lambda versions/aliases for instant rollback

**Infrastructure as Code:**
```bash
# Deploy entire stack
serverless deploy

# Deploy single function (faster iteration)
serverless deploy function -f invoiceCreate

# Remove stack
serverless remove

# View logs
serverless logs -f invoiceCreate -t
```

### API Documentation

**OpenAPI/Swagger:**
- Auto-generated from API Gateway configuration
- Available at: `https://api.duemate.com/docs`
- Export: `aws apigateway get-export --rest-api-id xxx --export-type swagger`

**Postman Collection:**
- Import from OpenAPI spec
- Environment variables for staging/production
- Pre-request scripts for authentication

### DynamoDB Table Design

**Main Table: `duemate-main`**
```
Attributes:
- PK (String, Partition Key)
- SK (String, Sort Key)
- GSI1PK (String, GSI-1 Partition Key)
- GSI1SK (String, GSI-1 Sort Key)
- GSI2PK (String, GSI-2 Partition Key)
- GSI2SK (String, GSI-2 Sort Key)
- [Additional attributes as needed]

Global Secondary Indexes:
- GSI-1: GSI1PK (PK) + GSI1SK (SK)
- GSI-2: GSI2PK (PK) + GSI2SK (SK)

Billing Mode: On-Demand (PAY_PER_REQUEST)
Point-in-time Recovery: Enabled
Encryption: AWS-managed KMS key
```

### Useful AWS CLI Commands

```bash
# Invoke Lambda function
aws lambda invoke \
  --function-name duemate-prod-invoiceCreate \
  --payload '{"tenantId":"123","amount":100}' \
  response.json

# Query DynamoDB
aws dynamodb query \
  --table-name duemate-main \
  --key-condition-expression "PK = :pk" \
  --expression-attribute-values '{":pk":{"S":"TENANT#123"}}'

# View CloudWatch Logs
aws logs tail /aws/lambda/duemate-prod-invoiceCreate --follow

# Get API Gateway endpoint
aws apigateway get-rest-apis --query 'items[?name==`duemate-prod`]'

# List S3 buckets
aws s3 ls

# Invalidate CloudFront cache
aws cloudfront create-invalidation \
  --distribution-id E1234567890ABC \
  --paths "/*"
```

### Monitoring Dashboards

**CloudWatch Dashboard:**
- Lambda performance (invocations, duration, errors, throttles)
- DynamoDB metrics (read/write capacity, throttles)
- API Gateway metrics (requests, latency, errors)
- Cost estimates by service

**Recommended Alarms:**
1. Lambda error rate > 1%
2. API Gateway 5xx errors > 5%
3. DynamoDB throttled requests > 0
4. SQS queue depth > 100
5. Monthly cost > budget threshold

### Team Onboarding Resources

- [Development Setup Guide](./development-setup.md) *(to be created)*
- [API Documentation](./api-documentation.md) *(to be created)*
- [DynamoDB Schema & Access Patterns](./database-schema.md) *(to be created)*
- [Deployment Guide](./deployment-guide.md) *(to be created)*
- [Serverless Best Practices](./serverless-best-practices.md) *(to be created)*
- [Cost Optimization Guide](./cost-optimization.md) *(to be created)*

### Security Checklist

- [ ] Enable AWS CloudTrail for audit logging
- [ ] Use Secrets Manager for all API keys and credentials
- [ ] Enable DynamoDB encryption at rest
- [ ] Enable S3 bucket versioning and encryption
- [ ] Configure IAM roles with least privilege
- [ ] Enable API Gateway request validation
- [ ] Implement rate limiting on API Gateway
- [ ] Use WAF for DDoS protection (if needed)
- [ ] Enable MFA for AWS root account
- [ ] Regular security audits with AWS Inspector
- [ ] HTTPS only for all endpoints
- [ ] Rotate Cognito user pool secrets regularly

---

**Document Owner:** Engineering Team  
**Last Updated:** October 2025  
**Review Schedule:** Quarterly or as needed for major changes  
**Architecture Version:** 2.0 (Serverless-First)
