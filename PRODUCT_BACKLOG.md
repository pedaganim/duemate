# DueMate MVP Product Backlog

This document contains the prioritized product backlog for DueMate's Minimum Viable Product (MVP). Each item should be created as a GitHub issue for sprint planning.

## Priority: HIGH (Core Features)

### Issue 1: Project Setup and Infrastructure
**Title:** Set up project infrastructure and development environment

**Description:**
Initialize the project with necessary infrastructure:
- Set up project structure (frontend, backend, database)
- Configure development environment (Docker, dev dependencies)
- Set up CI/CD pipeline basics
- Configure linting and code quality tools
- Add basic project documentation (CONTRIBUTING.md, setup instructions)

**Acceptance Criteria:**
- [ ] Project structure is defined and documented
- [ ] Development environment can be set up with clear instructions
- [ ] Basic CI/CD pipeline runs successfully
- [ ] Code quality tools are configured

**Labels:** setup, infrastructure, P0

---

### Issue 2: Database Schema Design and Setup
**Title:** Design and implement database schema for invoices and clients

**Description:**
Create the database schema for core entities:
- Clients table (name, email, phone, address, payment terms)
- Invoices table (invoice number, amount, due date, status, client reference)
- Reminders table (invoice reference, reminder date, status, type)
- Set up migrations
- Add database seeding for development

**Acceptance Criteria:**
- [ ] Database schema is designed and documented
- [ ] Migration scripts are created
- [ ] Database can be initialized with seed data
- [ ] Schema supports all core MVP features

**Labels:** database, backend, P0

---

### Issue 3: Client Management - Create and List Clients
**Title:** Implement client creation and listing functionality

**Description:**
Build the ability to manage clients:
- API endpoint to create new clients
- API endpoint to list all clients
- API endpoint to get client details
- Input validation for client data
- Basic client model and repository pattern

**Acceptance Criteria:**
- [ ] POST /api/clients creates a new client
- [ ] GET /api/clients returns list of clients
- [ ] GET /api/clients/:id returns client details
- [ ] Input validation prevents invalid data
- [ ] Unit tests cover client endpoints

**Labels:** backend, feature, clients, P0

---

### Issue 4: Client Management - Update and Delete Clients
**Title:** Implement client update and deletion functionality

**Description:**
Complete client management CRUD operations:
- API endpoint to update existing clients
- API endpoint to delete clients
- Handle client deletion with existing invoices (soft delete or validation)
- Update validation rules

**Acceptance Criteria:**
- [ ] PUT /api/clients/:id updates client information
- [ ] DELETE /api/clients/:id removes or soft-deletes client
- [ ] Cannot delete clients with active invoices (or handle gracefully)
- [ ] Unit tests cover update and delete operations

**Labels:** backend, feature, clients, P0

---

### Issue 5: Invoice CRUD - Create and List Invoices
**Title:** Implement invoice creation and listing functionality

**Description:**
Build core invoice management:
- API endpoint to create new invoices
- API endpoint to list invoices with filtering (by client, status, date range)
- Link invoices to clients
- Calculate and store invoice metadata (days until due, overdue status)
- Invoice number generation

**Acceptance Criteria:**
- [ ] POST /api/invoices creates a new invoice
- [ ] GET /api/invoices returns paginated list with filters
- [ ] Invoice automatically calculates due date based on client payment terms
- [ ] Invoice numbers are generated automatically and sequentially
- [ ] Unit tests cover invoice creation and listing

**Labels:** backend, feature, invoices, P0

---

### Issue 6: Invoice CRUD - Update and Delete Invoices
**Title:** Implement invoice update, deletion, and status management

**Description:**
Complete invoice management operations:
- API endpoint to update invoice details
- API endpoint to delete invoices
- Invoice status management (draft, sent, paid, overdue, cancelled)
- Handle status transitions and validations

**Acceptance Criteria:**
- [ ] PUT /api/invoices/:id updates invoice information
- [ ] PATCH /api/invoices/:id/status updates invoice status
- [ ] DELETE /api/invoices/:id removes invoice
- [ ] Status transitions follow business rules
- [ ] Unit tests cover all operations

**Labels:** backend, feature, invoices, P0

---

### Issue 7: Reminder Scheduling System
**Title:** Implement automated reminder scheduling and triggering

**Description:**
Build the reminder scheduling system:
- Reminder scheduling logic (before due date, on due date, after due date)
- Background job/cron system for checking and triggering reminders
- Reminder status tracking (scheduled, sent, failed)
- Configurable reminder templates
- Support for multiple reminder types (email initially)

**Acceptance Criteria:**
- [ ] Reminders are automatically scheduled when invoices are created
- [ ] Background job checks for due reminders every hour
- [ ] Reminders can be manually triggered via API
- [ ] Reminder history is tracked and viewable
- [ ] Configurable reminder timing (e.g., 7 days before, 1 day before, on due date)

**Labels:** backend, feature, reminders, P0

---

### Issue 8: Email Reminder Delivery
**Title:** Implement email delivery for invoice reminders

**Description:**
Build email reminder functionality:
- Email service integration (SendGrid, AWS SES, or SMTP)
- Email template system for reminders
- Personalized email content (client name, invoice details, amount due)
- Email delivery tracking and status
- Handle email failures and retries

**Acceptance Criteria:**
- [ ] Email service is configured and tested
- [ ] Professional email templates are created
- [ ] Emails include invoice details and payment instructions
- [ ] Email delivery status is tracked
- [ ] Failed emails are retried with exponential backoff

**Labels:** backend, feature, reminders, notifications, P0

---

### Issue 9: Frontend - Client Management UI
**Title:** Build client management user interface

**Description:**
Create UI for managing clients:
- Client list view with search and sorting
- Client detail view
- Create/Edit client form
- Delete client confirmation
- Responsive design for mobile and desktop

**Acceptance Criteria:**
- [ ] Users can view list of all clients
- [ ] Users can search and filter clients
- [ ] Users can create new clients via form
- [ ] Users can edit existing clients
- [ ] Users can delete clients with confirmation
- [ ] UI is responsive and user-friendly

**Labels:** frontend, feature, clients, P0

---

### Issue 10: Frontend - Invoice Management UI
**Title:** Build invoice management user interface

**Description:**
Create UI for managing invoices:
- Invoice list view with filters (status, client, date range)
- Invoice detail view showing all information and reminder history
- Create/Edit invoice form
- Invoice status management
- Visual indicators for overdue invoices

**Acceptance Criteria:**
- [ ] Users can view list of invoices with filtering
- [ ] Users can create new invoices
- [ ] Users can edit invoice details
- [ ] Users can update invoice status
- [ ] Overdue invoices are visually highlighted
- [ ] Invoice details show reminder history

**Labels:** frontend, feature, invoices, P0

---

### Issue 11: Frontend - Dashboard Overview
**Title:** Create dashboard with invoice and reminder overview

**Description:**
Build a dashboard for quick overview:
- Summary cards (total invoices, overdue amount, upcoming reminders)
- Recent activity feed
- Quick actions (create invoice, add client)
- Charts showing invoice status distribution
- Upcoming reminders list

**Acceptance Criteria:**
- [ ] Dashboard shows key metrics at a glance
- [ ] Users can see overdue invoices prominently
- [ ] Recent activity is displayed
- [ ] Quick action buttons are easily accessible
- [ ] Dashboard is the default landing page

**Labels:** frontend, feature, dashboard, P0

---

## Priority: MEDIUM (Nice-to-Have Features)

### Issue 12: Bank Account Sync Integration
**Title:** Integrate bank account synchronization for payment tracking

**Description:**
Add bank sync capability to automatically track payments:
- Research and integrate banking API (Plaid, Yodlee, or similar)
- Match bank transactions to invoices
- Automatically mark invoices as paid when payment detected
- Bank account connection management UI
- Transaction history view

**Acceptance Criteria:**
- [ ] Users can connect their bank accounts
- [ ] Bank transactions are synced regularly
- [ ] Payments are matched to invoices automatically
- [ ] Users can manually match transactions if needed
- [ ] Bank connection status is visible in settings

**Labels:** backend, frontend, feature, bank-sync, P1

---

### Issue 13: AI Voice Reminder System
**Title:** Implement AI-powered voice call reminders

**Description:**
Add AI voice reminder capability:
- Integrate with voice API service (Twilio, AWS Connect, or similar)
- Text-to-speech for invoice reminders
- AI voice agent for answering basic questions
- Call scheduling and status tracking
- Voice reminder configuration (opt-in/opt-out)

**Acceptance Criteria:**
- [ ] System can place automated voice calls
- [ ] Voice message includes invoice details
- [ ] Call status is tracked (answered, no answer, failed)
- [ ] Users can enable/disable voice reminders per client
- [ ] Voice reminders respect time zones and business hours

**Labels:** backend, feature, ai, voice-reminders, P1

---

### Issue 14: Whitelabel Functionality
**Title:** Add whitelabel/multi-tenant support

**Description:**
Enable whitelabel capability for reselling:
- Multi-tenant architecture (tenant isolation)
- Custom branding per tenant (logo, colors, domain)
- Tenant management admin interface
- Separate database schemas or row-level security
- Tenant-specific email templates

**Acceptance Criteria:**
- [ ] Multiple tenants can use the system independently
- [ ] Each tenant can customize branding
- [ ] Data is completely isolated between tenants
- [ ] Tenant admin can manage their own settings
- [ ] Custom domains can be configured per tenant

**Labels:** backend, frontend, feature, whitelabel, multi-tenant, P1

---

### Issue 15: Reporting and Analytics
**Title:** Build reporting and analytics dashboard

**Description:**
Create reporting capabilities:
- Revenue reports (by period, by client)
- Aging reports (invoice age, overdue duration)
- Reminder effectiveness metrics
- Client payment behavior analysis
- Export reports to CSV/PDF

**Acceptance Criteria:**
- [ ] Users can generate various financial reports
- [ ] Reports can be filtered by date range and client
- [ ] Visual charts display key metrics
- [ ] Reports can be exported
- [ ] Report data is accurate and up-to-date

**Labels:** frontend, backend, feature, reporting, P2

---

## Priority: LOW (Future Enhancements)

### Issue 16: Mobile Application
**Title:** Develop mobile application for iOS and Android

**Description:**
Create mobile apps for on-the-go management:
- React Native or Flutter mobile app
- Core features from web app
- Push notifications for reminders
- Mobile-optimized UI
- Offline capability for viewing invoices

**Acceptance Criteria:**
- [ ] Mobile app available on iOS and Android
- [ ] Users can manage clients and invoices
- [ ] Push notifications work reliably
- [ ] App works offline for viewing data
- [ ] App syncs when connection is restored

**Labels:** mobile, feature, P2

---

## Issue Creation Checklist

When creating these issues in GitHub:
1. Copy the title as the issue title
2. Copy the description section as the issue body
3. Add the acceptance criteria as checkboxes
4. Apply the suggested labels
5. Add priority label (P0 for High, P1 for Medium, P2 for Low)
6. Assign to appropriate milestone if sprints are defined
7. Add to project board if using GitHub Projects

## Sprint Planning Guidelines

**Sprint 1 (Foundation):** Issues 1, 2
**Sprint 2 (Core Backend):** Issues 3, 4, 5, 6
**Sprint 3 (Reminders):** Issues 7, 8
**Sprint 4 (Core Frontend):** Issues 9, 10, 11
**Sprint 5+ (Enhancements):** Issues 12, 13, 14, 15, 16

Each sprint should be 1-2 weeks depending on team size and velocity.
