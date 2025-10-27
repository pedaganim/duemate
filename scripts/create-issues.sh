#!/bin/bash

# Script to create GitHub issues from the product backlog
# This script requires GitHub CLI (gh) to be installed and authenticated

REPO="pedaganim/duemate"

echo "Creating DueMate MVP Product Backlog Issues..."
echo "Repository: $REPO"
echo ""

# Issue 1: Project Setup
gh issue create \
  --repo "$REPO" \
  --title "Set up project infrastructure and development environment" \
  --body "Initialize the project with necessary infrastructure:
- Set up project structure (frontend, backend, database)
- Configure development environment (Docker, dev dependencies)
- Set up CI/CD pipeline basics
- Configure linting and code quality tools
- Add basic project documentation (CONTRIBUTING.md, setup instructions)

**Acceptance Criteria:**
- [ ] Project structure is defined and documented
- [ ] Development environment can be set up with clear instructions
- [ ] Basic CI/CD pipeline runs successfully
- [ ] Code quality tools are configured" \
  --label "setup,infrastructure,P0"

echo "✓ Created Issue 1: Project Setup"

# Issue 2: Database Schema
gh issue create \
  --repo "$REPO" \
  --title "Design and implement database schema for invoices and clients" \
  --body "Create the database schema for core entities:
- Clients table (name, email, phone, address, payment terms)
- Invoices table (invoice number, amount, due date, status, client reference)
- Reminders table (invoice reference, reminder date, status, type)
- Set up migrations
- Add database seeding for development

**Acceptance Criteria:**
- [ ] Database schema is designed and documented
- [ ] Migration scripts are created
- [ ] Database can be initialized with seed data
- [ ] Schema supports all core MVP features" \
  --label "database,backend,P0"

echo "✓ Created Issue 2: Database Schema"

# Issue 3: Client Management - Create and List
gh issue create \
  --repo "$REPO" \
  --title "Implement client creation and listing functionality" \
  --body "Build the ability to manage clients:
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
- [ ] Unit tests cover client endpoints" \
  --label "backend,feature,clients,P0"

echo "✓ Created Issue 3: Client Management - Create and List"

# Issue 4: Client Management - Update and Delete
gh issue create \
  --repo "$REPO" \
  --title "Implement client update and deletion functionality" \
  --body "Complete client management CRUD operations:
- API endpoint to update existing clients
- API endpoint to delete clients
- Handle client deletion with existing invoices (soft delete or validation)
- Update validation rules

**Acceptance Criteria:**
- [ ] PUT /api/clients/:id updates client information
- [ ] DELETE /api/clients/:id removes or soft-deletes client
- [ ] Cannot delete clients with active invoices (or handle gracefully)
- [ ] Unit tests cover update and delete operations" \
  --label "backend,feature,clients,P0"

echo "✓ Created Issue 4: Client Management - Update and Delete"

# Issue 5: Invoice CRUD - Create and List
gh issue create \
  --repo "$REPO" \
  --title "Implement invoice creation and listing functionality" \
  --body "Build core invoice management:
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
- [ ] Unit tests cover invoice creation and listing" \
  --label "backend,feature,invoices,P0"

echo "✓ Created Issue 5: Invoice CRUD - Create and List"

# Issue 6: Invoice CRUD - Update and Delete
gh issue create \
  --repo "$REPO" \
  --title "Implement invoice update, deletion, and status management" \
  --body "Complete invoice management operations:
- API endpoint to update invoice details
- API endpoint to delete invoices
- Invoice status management (draft, sent, paid, overdue, cancelled)
- Handle status transitions and validations

**Acceptance Criteria:**
- [ ] PUT /api/invoices/:id updates invoice information
- [ ] PATCH /api/invoices/:id/status updates invoice status
- [ ] DELETE /api/invoices/:id removes invoice
- [ ] Status transitions follow business rules
- [ ] Unit tests cover all operations" \
  --label "backend,feature,invoices,P0"

echo "✓ Created Issue 6: Invoice CRUD - Update and Delete"

# Issue 7: Reminder Scheduling
gh issue create \
  --repo "$REPO" \
  --title "Implement automated reminder scheduling and triggering" \
  --body "Build the reminder scheduling system:
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
- [ ] Configurable reminder timing (e.g., 7 days before, 1 day before, on due date)" \
  --label "backend,feature,reminders,P0"

echo "✓ Created Issue 7: Reminder Scheduling"

# Issue 8: Email Reminder Delivery
gh issue create \
  --repo "$REPO" \
  --title "Implement email delivery for invoice reminders" \
  --body "Build email reminder functionality:
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
- [ ] Failed emails are retried with exponential backoff" \
  --label "backend,feature,reminders,notifications,P0"

echo "✓ Created Issue 8: Email Reminder Delivery"

# Issue 9: Frontend - Client Management UI
gh issue create \
  --repo "$REPO" \
  --title "Build client management user interface" \
  --body "Create UI for managing clients:
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
- [ ] UI is responsive and user-friendly" \
  --label "frontend,feature,clients,P0"

echo "✓ Created Issue 9: Frontend - Client Management UI"

# Issue 10: Frontend - Invoice Management UI
gh issue create \
  --repo "$REPO" \
  --title "Build invoice management user interface" \
  --body "Create UI for managing invoices:
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
- [ ] Invoice details show reminder history" \
  --label "frontend,feature,invoices,P0"

echo "✓ Created Issue 10: Frontend - Invoice Management UI"

# Issue 11: Frontend - Dashboard
gh issue create \
  --repo "$REPO" \
  --title "Create dashboard with invoice and reminder overview" \
  --body "Build a dashboard for quick overview:
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
- [ ] Dashboard is the default landing page" \
  --label "frontend,feature,dashboard,P0"

echo "✓ Created Issue 11: Frontend - Dashboard"

# Issue 12: Bank Sync (Nice-to-have)
gh issue create \
  --repo "$REPO" \
  --title "Integrate bank account synchronization for payment tracking" \
  --body "Add bank sync capability to automatically track payments:
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
- [ ] Bank connection status is visible in settings" \
  --label "backend,frontend,feature,bank-sync,P1"

echo "✓ Created Issue 12: Bank Account Sync"

# Issue 13: AI Voice Reminders (Nice-to-have)
gh issue create \
  --repo "$REPO" \
  --title "Implement AI-powered voice call reminders" \
  --body "Add AI voice reminder capability:
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
- [ ] Voice reminders respect time zones and business hours" \
  --label "backend,feature,ai,voice-reminders,P1"

echo "✓ Created Issue 13: AI Voice Reminders"

# Issue 14: Whitelabel (Nice-to-have)
gh issue create \
  --repo "$REPO" \
  --title "Add whitelabel/multi-tenant support" \
  --body "Enable whitelabel capability for reselling:
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
- [ ] Custom domains can be configured per tenant" \
  --label "backend,frontend,feature,whitelabel,multi-tenant,P1"

echo "✓ Created Issue 14: Whitelabel Functionality"

# Issue 15: Reporting and Analytics
gh issue create \
  --repo "$REPO" \
  --title "Build reporting and analytics dashboard" \
  --body "Create reporting capabilities:
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
- [ ] Report data is accurate and up-to-date" \
  --label "frontend,backend,feature,reporting,P2"

echo "✓ Created Issue 15: Reporting and Analytics"

# Issue 16: Mobile App
gh issue create \
  --repo "$REPO" \
  --title "Develop mobile application for iOS and Android" \
  --body "Create mobile apps for on-the-go management:
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
- [ ] App syncs when connection is restored" \
  --label "mobile,feature,P2"

echo "✓ Created Issue 16: Mobile Application"

echo ""
echo "✅ All 16 issues created successfully!"
echo ""
echo "Sprint Planning Suggestion:"
echo "  Sprint 1 (Foundation): Issues #1, #2"
echo "  Sprint 2 (Core Backend): Issues #3, #4, #5, #6"
echo "  Sprint 3 (Reminders): Issues #7, #8"
echo "  Sprint 4 (Core Frontend): Issues #9, #10, #11"
echo "  Sprint 5+ (Enhancements): Issues #12, #13, #14, #15, #16"
