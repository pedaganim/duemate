# Scripts Directory

This directory contains utility scripts for the DueMate project.

## create-issues.sh

This script creates all the GitHub issues for the DueMate MVP product backlog.

### Prerequisites

1. Install GitHub CLI: https://cli.github.com/
2. Authenticate with GitHub:
   ```bash
   gh auth login
   ```

### Usage

```bash
./scripts/create-issues.sh
```

The script will create 16 GitHub issues in the `pedaganim/duemate` repository:

- **11 Core Features (P0)** - Essential for MVP
  - Project setup and infrastructure
  - Database schema
  - Client CRUD operations (2 issues)
  - Invoice CRUD operations (2 issues)
  - Reminder scheduling
  - Email delivery
  - Frontend UI (3 issues: clients, invoices, dashboard)

- **3 Nice-to-Have Features (P1)** - Valuable additions
  - Bank account sync
  - AI voice reminders
  - Whitelabel/multi-tenant support

- **2 Future Enhancements (P2)** - Long-term roadmap
  - Reporting and analytics
  - Mobile application

### Issue Structure

Each issue includes:
- Clear title
- Detailed description
- Acceptance criteria as checkboxes
- Appropriate labels (priority, category, feature area)

### Verification

After running the script, verify the issues were created:

```bash
gh issue list --repo pedaganim/duemate
```

### Manual Creation

If you prefer to create issues manually, refer to:
- `PRODUCT_BACKLOG.md` - Detailed documentation for each issue
- `issues.json` - Structured JSON data of all issues
