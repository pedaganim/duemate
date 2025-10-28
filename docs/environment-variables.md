# Environment Variables Reference

This document provides a comprehensive reference for all environment variables used in the DueMate application.

## Overview

Environment variables are used to configure the application for different environments (development, staging, production). These variables should be set in a `.env` file locally or in your deployment platform's environment configuration.

## Required Variables

### Database Configuration

#### `DATABASE_URL`

- **Description**: Connection string for the database
- **Type**: String
- **Required**: Yes
- **Default**: `file:./dev.db` (SQLite for development)
- **Examples**:

  ```bash
  # SQLite (Development)
  DATABASE_URL="file:./dev.db"

  # PostgreSQL (Production)
  DATABASE_URL="postgresql://user:password@host:5432/database?sslmode=require"

  # MySQL (Alternative)
  DATABASE_URL="mysql://user:password@host:3306/database"
  ```

- **Notes**:
  - For production, use a managed database service
  - Ensure the connection string includes SSL for security
  - See [Prisma Connection URLs](https://www.prisma.io/docs/reference/database-reference/connection-urls)

### Server Configuration

#### `PORT`

- **Description**: Port number for the API server
- **Type**: Number
- **Required**: No
- **Default**: `3000`
- **Example**: `PORT=3000`
- **Notes**: Used by the Express API server. Next.js uses a different port configuration.

#### `NODE_ENV`

- **Description**: Application environment
- **Type**: String
- **Required**: No
- **Default**: `development`
- **Allowed Values**: `development`, `production`, `test`
- **Example**: `NODE_ENV=production`
- **Notes**:
  - Affects logging levels, error handling, and optimizations
  - Automatically set by most deployment platforms

### API Configuration

#### `API_BASE_URL`

- **Description**: Base URL for API endpoints
- **Type**: String
- **Required**: No
- **Default**: `http://localhost:3000`
- **Examples**:

  ```bash
  # Development
  API_BASE_URL="http://localhost:3000"

  # Production
  API_BASE_URL="https://duemate.org"
  ```

- **Notes**: Used for generating links and API references

## Optional Variables

### Email Configuration (For Future Reminder Feature)

#### `SMTP_HOST`

- **Description**: SMTP server hostname
- **Type**: String
- **Required**: No (for email reminders)
- **Examples**:

  ```bash
  # SendGrid
  SMTP_HOST="smtp.sendgrid.net"

  # Gmail
  SMTP_HOST="smtp.gmail.com"

  # AWS SES
  SMTP_HOST="email-smtp.us-east-1.amazonaws.com"
  ```

#### `SMTP_PORT`

- **Description**: SMTP server port
- **Type**: Number
- **Required**: No (for email reminders)
- **Default**: `587`
- **Common Values**:
  - `587` - TLS (recommended)
  - `465` - SSL
  - `25` - Non-encrypted (not recommended)
- **Example**: `SMTP_PORT=587`

#### `SMTP_USER`

- **Description**: SMTP authentication username
- **Type**: String
- **Required**: No (for email reminders)
- **Example**: `SMTP_USER="apikey"` (for SendGrid)
- **Notes**: Often an API key or email address

#### `SMTP_PASS`

- **Description**: SMTP authentication password
- **Type**: String
- **Required**: No (for email reminders)
- **Example**: `SMTP_PASS="your-api-key-here"`
- **Security**: Never commit this to version control

#### `SMTP_FROM`

- **Description**: Default "from" email address for reminders
- **Type**: String (email)
- **Required**: No (for email reminders)
- **Example**: `SMTP_FROM="noreply@duemate.org"`
- **Notes**: Must be a verified sender on your SMTP provider

### Error Tracking

#### `SENTRY_DSN`

- **Description**: Sentry Data Source Name for error tracking
- **Type**: String (URL)
- **Required**: No
- **Example**: `SENTRY_DSN="https://abc123@o123456.ingest.sentry.io/7890123"`
- **Notes**:
  - Get from [Sentry.io](https://sentry.io)
  - Enables automatic error reporting and tracking

### Analytics

#### `NEXT_PUBLIC_ANALYTICS_ID`

- **Description**: Analytics tracking ID (Google Analytics, Plausible, etc.)
- **Type**: String
- **Required**: No
- **Example**:

  ```bash
  # Google Analytics
  NEXT_PUBLIC_ANALYTICS_ID="G-XXXXXXXXXX"

  # Plausible
  NEXT_PUBLIC_ANALYTICS_ID="duemate.org"
  ```

- **Notes**:
  - Prefix `NEXT_PUBLIC_` makes it available in browser
  - Configure your analytics provider separately

### Development & Debugging

#### `DEBUG`

- **Description**: Enable debug logging
- **Type**: Boolean or String
- **Required**: No
- **Example**:
  ```bash
  DEBUG="true"
  DEBUG="prisma:*"
  ```
- **Notes**: Useful for troubleshooting database queries and app behavior

#### `LOG_LEVEL`

- **Description**: Logging verbosity level
- **Type**: String
- **Required**: No
- **Default**: `info`
- **Allowed Values**: `error`, `warn`, `info`, `debug`, `trace`
- **Example**: `LOG_LEVEL="debug"`

## Environment-Specific Configurations

### Development Environment (.env.local)

```bash
# Database
DATABASE_URL="file:./dev.db"

# Server
PORT=3000
NODE_ENV=development

# API
API_BASE_URL="http://localhost:3000"

# Debug
DEBUG="true"
LOG_LEVEL="debug"
```

### Production Environment (Vercel/Cloud)

```bash
# Database (use managed service)
DATABASE_URL="postgresql://user:pass@host:5432/db?sslmode=require"

# Server
NODE_ENV=production

# API
API_BASE_URL="https://duemate.org"

# Email (if enabled)
SMTP_HOST="smtp.sendgrid.net"
SMTP_PORT=587
SMTP_USER="apikey"
SMTP_PASS="SG.xxx"
SMTP_FROM="noreply@duemate.org"

# Error Tracking
SENTRY_DSN="https://xxx@xxx.ingest.sentry.io/xxx"

# Analytics
NEXT_PUBLIC_ANALYTICS_ID="G-XXXXXXXXXX"

# Logging
LOG_LEVEL="warn"
```

### Test Environment (.env.test)

```bash
# Database (use test database)
DATABASE_URL="file:./test.db"

# Server
NODE_ENV=test

# API
API_BASE_URL="http://localhost:3001"

# Disable external services
SMTP_HOST=""
SENTRY_DSN=""

# Logging
LOG_LEVEL="error"
```

## Setting Environment Variables

### Local Development

1. Copy `.env.example` to `.env`:

   ```bash
   cp .env.example .env
   ```

2. Edit `.env` with your values:

   ```bash
   nano .env
   ```

3. Never commit `.env` to version control (it's in `.gitignore`)

### Vercel Deployment

1. Via Vercel Dashboard:
   - Go to Project Settings → Environment Variables
   - Add each variable with appropriate scope (Production/Preview/Development)

2. Via Vercel CLI:

   ```bash
   vercel env add DATABASE_URL
   # Follow prompts to enter value and select environments
   ```

3. Pull environment variables locally:
   ```bash
   vercel env pull .env.local
   ```

### GitHub Actions

Set secrets in GitHub repository:

1. Go to Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Add each secret

Reference in workflow:

```yaml
env:
  DATABASE_URL: ${{ secrets.DATABASE_URL }}
```

## Security Best Practices

### Do's ✅

- Use different credentials for each environment
- Rotate secrets regularly
- Use managed secrets services (AWS Secrets Manager, etc.)
- Limit access to production environment variables
- Use strong, random passwords and API keys
- Enable SSL/TLS for all database connections
- Use `.env.example` to document required variables (without actual values)

### Don'ts ❌

- Never commit `.env` files to version control
- Don't hardcode secrets in code
- Don't share production credentials
- Don't use development credentials in production
- Don't log sensitive environment variables
- Don't use weak or default passwords

## Validation

The application validates required environment variables on startup. If critical variables are missing, the application will fail to start with a descriptive error message.

Example validation error:

```
Error: DATABASE_URL environment variable is required
```

## Troubleshooting

### Variable Not Loading

1. Verify `.env` file exists and is in the root directory
2. Check for typos in variable names
3. Ensure no spaces around `=` sign
4. Restart the development server
5. For Next.js public variables, ensure they start with `NEXT_PUBLIC_`

### Production Variables Not Working

1. Verify variables are set in deployment platform
2. Check environment scope (Production/Preview/Development)
3. Redeploy after changing environment variables
4. Check deployment logs for errors

### Database Connection Issues

1. Verify `DATABASE_URL` format is correct
2. Test connection string separately
3. Check firewall rules allow connections
4. Verify database user has correct permissions

## Additional Resources

- [Next.js Environment Variables](https://nextjs.org/docs/basic-features/environment-variables)
- [Prisma Connection Strings](https://www.prisma.io/docs/reference/database-reference/connection-urls)
- [Vercel Environment Variables](https://vercel.com/docs/concepts/projects/environment-variables)
- [Twelve-Factor App Config](https://12factor.net/config)
