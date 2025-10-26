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
8. [Data Flow](#data-flow)
9. [Security Considerations](#security-considerations)
10. [Scalability & Performance](#scalability--performance)

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

DueMate follows a **modern microservices-oriented architecture** with a monolithic core for rapid initial development, designed to evolve into full microservices as needed.

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   Web App    │  │  Mobile App  │  │  API Client  │          │
│  │  (React)     │  │ (React Native│  │  (REST/GraphQL)│        │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│                                                                  │
└────────────────────────┬─────────────────────────────────────────┘
                         │
                         │ HTTPS
                         │
┌────────────────────────▼─────────────────────────────────────────┐
│                   API GATEWAY / LOAD BALANCER                    │
│                     (NGINX / AWS ALB)                            │
└────────────────────────┬─────────────────────────────────────────┘
                         │
         ┌───────────────┼───────────────┐
         │               │               │
┌────────▼──────┐ ┌──────▼──────┐ ┌─────▼──────────┐
│               │ │              │ │                 │
│  Web API      │ │  Background  │ │  WebSocket     │
│  Service      │ │  Workers     │ │  Service       │
│  (Node.js/    │ │  (Bull Queue)│ │  (Real-time    │
│   Express)    │ │              │ │   updates)     │
│               │ │              │ │                 │
└───────┬───────┘ └──────┬───────┘ └────────────────┘
        │                │
        │         ┌──────▼─────────────────────┐
        │         │   Message Queue            │
        │         │   (Redis / RabbitMQ)       │
        │         └────────────────────────────┘
        │
┌───────▼────────────────────────────────────────────┐
│              APPLICATION CORE                      │
├────────────────────────────────────────────────────┤
│                                                    │
│  ┌──────────────┐  ┌──────────────┐              │
│  │  Auth &      │  │  Invoice     │              │
│  │  User Mgmt   │  │  Management  │              │
│  └──────────────┘  └──────────────┘              │
│                                                    │
│  ┌──────────────┐  ┌──────────────┐              │
│  │  Reminder    │  │  Notification│              │
│  │  Scheduler   │  │  Service     │              │
│  └──────────────┘  └──────────────┘              │
│                                                    │
│  ┌──────────────┐  ┌──────────────┐              │
│  │  Payment     │  │  Analytics & │              │
│  │  Processing  │  │  Reporting   │              │
│  └──────────────┘  └──────────────┘              │
│                                                    │
└────────────────────┬───────────────────────────────┘
                     │
         ┌───────────┼───────────────┐
         │           │               │
┌────────▼───┐ ┌─────▼──────┐ ┌──────▼────────┐
│            │ │            │ │               │
│ PostgreSQL │ │   Redis    │ │  File Storage │
│ (Primary)  │ │  (Cache)   │ │  (S3/MinIO)   │
│            │ │            │ │               │
└────────────┘ └────────────┘ └───────────────┘
         │
         │
┌────────▼──────────────────────────────────────────┐
│           THIRD-PARTY INTEGRATIONS                │
├───────────────────────────────────────────────────┤
│                                                   │
│  Email       SMS        Payment     Banking      │
│  (SendGrid)  (Twilio)   (Stripe)    (Plaid)      │
│                         (PayPal)    (Yodlee)     │
│                                                   │
└───────────────────────────────────────────────────┘
```

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

**Primary Stack**
- **Runtime:** Node.js 20 LTS
- **Framework:** Express.js / NestJS
- **Language:** TypeScript
- **API Style:** RESTful API + GraphQL (optional for complex queries)
- **Authentication:** JWT + Passport.js
- **Validation:** Joi / Zod
- **ORM:** Prisma / TypeORM
- **Testing:** Jest + Supertest

**Background Processing**
- **Queue System:** Bull / BullMQ (Redis-backed)
- **Scheduler:** node-cron / Agenda
- **Email Processing:** Dedicated worker processes
- **SMS Processing:** Dedicated worker processes

**Reasoning:**
- Node.js provides excellent performance for I/O-heavy operations
- TypeScript across frontend and backend enables code sharing
- Express/NestJS are battle-tested and scalable
- Prisma offers type-safe database access
- Bull provides reliable job processing with retries

### Database

**Primary Database**
- **System:** PostgreSQL 15+
- **Hosting:** AWS RDS / Google Cloud SQL / Managed PostgreSQL
- **Features Used:**
  - JSONB for flexible schema fields
  - Row-level security for multi-tenancy
  - Full-text search
  - Partitioning for large tables (invoices, logs)

**Caching Layer**
- **System:** Redis 7+
- **Use Cases:**
  - Session storage
  - API response caching
  - Rate limiting
  - Job queue backend
  - Real-time features (pub/sub)

**Reasoning:**
- PostgreSQL offers excellent reliability, ACID compliance, and advanced features
- JSONB enables flexible configuration per tenant
- Redis provides high-performance caching and job queuing
- Both have excellent Node.js support

### File Storage

**System:** AWS S3 / Google Cloud Storage / MinIO (self-hosted)
**Use Cases:**
- Invoice PDF storage
- Email attachments
- Report exports
- Logo/branding assets for whitelabel

### Infrastructure & DevOps

**Containerization**
- **Container Runtime:** Docker
- **Orchestration:** Kubernetes (production) / Docker Compose (development)

**CI/CD**
- **Platform:** GitHub Actions / GitLab CI
- **Stages:** Lint → Test → Build → Deploy

**Hosting Options**
- **Cloud Providers:** AWS / Google Cloud Platform / DigitalOcean
- **Managed Kubernetes:** EKS / GKE / DOKS
- **Serverless Option:** AWS Lambda + API Gateway (alternative approach)

**Monitoring & Logging**
- **APM:** New Relic / Datadog / Grafana
- **Logging:** Winston + ELK Stack (Elasticsearch, Logstash, Kibana)
- **Error Tracking:** Sentry

**Reasoning:**
- Docker ensures consistent environments
- Kubernetes provides scalability and self-healing
- GitHub Actions integrates seamlessly with our workflow
- Comprehensive monitoring ensures reliability

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

**Technology:**
- JWT for stateless authentication
- Passport.js for strategy management
- bcrypt for password hashing
- Redis for session storage

### 2. Invoice Management Service

**Responsibilities:**
- CRUD operations for invoices
- Invoice versioning and history
- PDF generation
- Bulk import/export
- Invoice status tracking
- Custom fields per tenant

**Technology:**
- PostgreSQL for data storage
- Puppeteer/PDFKit for PDF generation
- CSV/Excel parsers for import

### 3. Reminder Scheduler Service

**Responsibilities:**
- Configure reminder rules per tenant
- Schedule reminders based on invoice due dates
- Support multiple reminder types (before due, on due, after due)
- Manage reminder templates
- Track reminder delivery status

**Technology:**
- node-cron for scheduling
- Bull queue for reliable execution
- Template engine (Handlebars/EJS)

### 4. Notification Service

**Responsibilities:**
- Multi-channel message delivery (Email, SMS)
- Template rendering with dynamic data
- Delivery status tracking
- Retry logic for failed deliveries
- Unsubscribe management

**Technology:**
- Bull queue for async processing
- Third-party service integrations
- Template engine for customization

### 5. Payment Processing Service

**Responsibilities:**
- Payment gateway integration
- Payment link generation
- Payment status tracking
- Webhook handling from payment providers
- Invoice-payment reconciliation
- Refund processing

**Technology:**
- Stripe SDK / PayPal SDK
- Webhook signature verification
- Idempotency handling

### 6. Banking Integration Service

**Responsibilities:**
- Bank account connection
- Transaction retrieval
- Payment verification
- Balance checking
- Automated reconciliation

**Technology:**
- Plaid API / Yodlee API
- Secure credential storage
- Transaction matching algorithms

### 7. Analytics & Reporting Service

**Responsibilities:**
- Dashboard metrics (KPIs)
- Custom report generation
- Data export (CSV, Excel, PDF)
- Scheduled reports
- Payment trends and forecasting

**Technology:**
- PostgreSQL aggregations
- Redis for caching
- Chart libraries for visualization

### 8. Tenant Management Service

**Responsibilities:**
- Organization/tenant provisioning
- Subscription plan management
- Usage tracking and limits
- Feature flags per tenant
- Billing and invoicing for the platform

**Technology:**
- PostgreSQL with tenant isolation
- Feature flag service (LaunchDarkly / custom)

### 9. Customer Portal

**Responsibilities:**
- Invoice viewing for end customers
- Payment submission
- Payment history
- Notification preferences
- Receipt download

**Technology:**
- Separate React application
- Public API endpoints
- Optimized for mobile

---

## Third-Party Services

### Email Service

**Primary Provider:** SendGrid
**Alternatives:** Amazon SES, Mailgun, Postmark

**Features:**
- Transactional email delivery
- Template management
- Deliverability analytics
- Webhook notifications
- High volume sending

**Reasoning:**
- SendGrid offers excellent deliverability rates
- Robust API and SDK support
- Template editor and version control
- Detailed analytics

### SMS Service

**Primary Provider:** Twilio
**Alternatives:** Vonage (Nexmo), Plivo, AWS SNS

**Features:**
- Global SMS delivery
- Programmable messaging
- Delivery receipts
- Two-way messaging (optional)
- Phone number verification

**Reasoning:**
- Twilio is industry-leading for SMS
- Excellent documentation and SDKs
- Reliable delivery worldwide
- Competitive pricing

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

### Approach: Hybrid Multi-Tenancy

We will implement a **shared database with logical separation** approach:

#### Database Architecture

**Tenant Isolation Strategy:**
```sql
-- Every table includes tenant_id for data isolation
CREATE TABLE invoices (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  customer_id UUID NOT NULL,
  amount DECIMAL(10,2),
  due_date DATE,
  status VARCHAR(50),
  created_at TIMESTAMP DEFAULT NOW(),
  
  -- Ensure tenant isolation at DB level
  CONSTRAINT fk_tenant FOREIGN KEY (tenant_id) 
    REFERENCES tenants(id) ON DELETE CASCADE
);

-- Index for performance
CREATE INDEX idx_invoices_tenant_id ON invoices(tenant_id);

-- Row-level security (PostgreSQL)
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation_policy ON invoices
  USING (tenant_id = current_setting('app.current_tenant')::UUID);
```

#### Tenant Configuration

Each tenant has:
```typescript
interface Tenant {
  id: string;
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
    logoUrl?: string;
    primaryColor?: string;
    secondaryColor?: string;
    customCSS?: string;
  };
  
  // Settings
  settings: {
    timezone: string;
    currency: string;
    dateFormat: string;
    emailFromAddress: string;
    emailFromName: string;
  };
  
  // Integration credentials (encrypted)
  integrations: {
    stripeAccountId?: string;
    twilioAccountSid?: string;
    customSMTPSettings?: object;
  };
  
  status: 'active' | 'suspended' | 'cancelled';
  createdAt: Date;
  updatedAt: Date;
}
```

#### Tenant Identification

**Request Flow:**
1. Client sends request to `acme.duemate.com` or with header `X-Tenant-ID`
2. Middleware extracts tenant identifier (subdomain or header)
3. Middleware loads tenant configuration from cache/database
4. Middleware sets tenant context for request
5. All database queries automatically filter by tenant_id

**Implementation:**
```typescript
// Express middleware
async function tenantMiddleware(req, res, next) {
  // Extract tenant from subdomain or header
  const subdomain = extractSubdomain(req.hostname);
  const tenantId = req.headers['x-tenant-id'];
  
  // Load tenant (with caching)
  const tenant = await getTenant(subdomain || tenantId);
  
  if (!tenant || tenant.status !== 'active') {
    return res.status(403).json({ error: 'Invalid or inactive tenant' });
  }
  
  // Set tenant context
  req.tenant = tenant;
  
  // Set PostgreSQL session variable for RLS
  await db.query('SET app.current_tenant = $1', [tenant.id]);
  
  next();
}
```

#### Data Isolation Benefits

- **Shared Infrastructure:** Lower operational costs
- **Logical Isolation:** Strong data separation
- **Row-Level Security:** Database-enforced isolation
- **Scalability:** Easy to add new tenants
- **Performance:** Efficient resource utilization

#### Migration Path to Physical Isolation

For enterprise customers requiring dedicated infrastructure:
- Database sharding by tenant
- Dedicated database instance per enterprise tenant
- Separate application instances if needed

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

### Horizontal Scaling Strategy

**Application Tier:**
- Stateless API servers
- Load balancer distributes traffic
- Auto-scaling based on CPU/memory metrics
- Kubernetes Horizontal Pod Autoscaler

**Background Workers:**
- Multiple worker instances
- Job distribution via Bull queue
- Scale workers independently from API

**Database Tier:**
- Read replicas for read-heavy operations
- Connection pooling (PgBouncer)
- Query optimization and indexing
- Partitioning for large tables (invoices, logs)

### Caching Strategy

**Redis Cache Layers:**
- **L1:** Tenant configuration (1 hour TTL)
- **L2:** Frequently accessed invoices (15 min TTL)
- **L3:** API responses (5 min TTL)
- **L4:** User sessions

**Cache Invalidation:**
- Event-driven invalidation on data updates
- TTL-based expiration for safety

### Performance Targets

- **API Response Time:** <200ms for 95th percentile
- **Page Load Time:** <2 seconds for initial load
- **Email Delivery:** Within 5 minutes of scheduled time
- **SMS Delivery:** Within 2 minutes of scheduled time
- **Database Queries:** <50ms for standard operations
- **Uptime:** 99.9% SLA (8.76 hours downtime/year max)

### Monitoring & Optimization

**Key Metrics:**
- Request throughput and latency
- Database connection pool usage
- Queue depth and processing time
- Cache hit ratio
- Error rates
- User session duration

**Alerts:**
- High error rates (>1%)
- Slow API responses (>1s)
- Queue backlog (>1000 jobs)
- Database connection exhaustion
- Low disk space
- SSL certificate expiration

---

## Future Considerations

### Phase 2 Enhancements
- Mobile applications (iOS/Android)
- Advanced analytics and forecasting
- Machine learning for payment prediction
- Multi-currency and international support
- Accounting software integrations (QuickBooks, Xero)

### Microservices Evolution
- Split monolith into focused microservices as scale demands
- Service mesh for inter-service communication (Istio)
- Event-driven architecture with message brokers

### Advanced Features
- Voice call reminders (Twilio Voice)
- WhatsApp/Telegram notifications
- Automated payment plans
- Customer credit scoring
- Blockchain-based payment verification

---

## Conclusion

This architecture provides a solid foundation for DueMate to:
- Deliver reliable invoice reminder functionality
- Scale to thousands of tenants
- Support whitelabel requirements
- Integrate with modern payment and banking systems
- Maintain security and compliance
- Evolve with business needs

The chosen technology stack balances proven reliability with modern developer experience, ensuring rapid development while maintaining production-grade quality.

---

## Appendix

### Development Environment Setup

1. **Prerequisites:** Node.js 20+, PostgreSQL 15+, Redis 7+, Docker
2. **Repository:** Clone and install dependencies
3. **Environment Variables:** Copy `.env.example` to `.env`
4. **Database:** Run migrations with Prisma
5. **Start Services:** `docker-compose up` for dependencies
6. **Run Application:** `npm run dev`

### Deployment Pipeline

1. **Development:** Feature branches → Pull requests
2. **Staging:** Automatic deployment on merge to `develop`
3. **Production:** Tagged releases deployed to production
4. **Rollback:** Automatic rollback on health check failures

### API Documentation

- **OpenAPI/Swagger:** Auto-generated API documentation
- **Postman Collection:** Available for API testing
- **GraphQL Playground:** Interactive query builder (if GraphQL used)

### Team Onboarding Resources

- [Development Setup Guide](./development-setup.md) *(to be created)*
- [API Documentation](./api-documentation.md) *(to be created)*
- [Database Schema](./database-schema.md) *(to be created)*
- [Deployment Guide](./deployment-guide.md) *(to be created)*

---

**Document Owner:** Engineering Team  
**Review Schedule:** Quarterly or as needed for major changes
