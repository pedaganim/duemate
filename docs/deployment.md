# Deployment Guide

This guide covers deploying DueMate to Vercel and connecting it to the duemate.org domain.

## Prerequisites

- A Vercel account (sign up at [vercel.com](https://vercel.com))
- Access to your domain registrar for DNS configuration
- GitHub repository access

## Deploying to Vercel

### Method 1: Deploy via Vercel Dashboard (Recommended)

1. **Connect Your GitHub Repository**
   - Visit [vercel.com/new](https://vercel.com/new)
   - Click "Import Project"
   - Select your GitHub repository `pedaganim/duemate`
   - Click "Import"

2. **Configure Project Settings**
   - **Framework Preset**: Next.js
   - **Root Directory**: `./` (leave as default)
   - **Build Command**: `npm run build` (auto-detected)
   - **Output Directory**: `.next` (auto-detected)
   - **Install Command**: `npm install` (auto-detected)

3. **Configure Environment Variables**

   Add the following environment variables in the Vercel dashboard:

   ```
   DATABASE_URL=file:./dev.db
   NODE_ENV=production
   API_BASE_URL=https://duemate.org
   ```

   For production, you may want to use a cloud database like:
   - **PostgreSQL**: Vercel Postgres, Supabase, or Neon
   - **MySQL**: PlanetScale

   Example with Vercel Postgres:

   ```
   DATABASE_URL=postgres://user:password@host:5432/database?sslmode=require
   ```

4. **Deploy**
   - Click "Deploy"
   - Wait for the build to complete (2-3 minutes)
   - Your site will be available at `https://your-project.vercel.app`

### Method 2: Deploy via Vercel CLI

1. **Install Vercel CLI**

   ```bash
   npm install -g vercel
   ```

2. **Login to Vercel**

   ```bash
   vercel login
   ```

3. **Deploy**

   ```bash
   # From your project directory
   vercel
   ```

4. **Follow the prompts**
   - Set up and deploy: Y
   - Which scope: Select your account
   - Link to existing project: N (first time)
   - Project name: duemate
   - Directory: ./ (press Enter)
   - Override settings: N

5. **Deploy to Production**
   ```bash
   vercel --prod
   ```

## Connecting Custom Domain (duemate.org)

### Step 1: Add Domain in Vercel

1. Go to your project in the Vercel Dashboard
2. Navigate to **Settings** → **Domains**
3. Click "Add" and enter `duemate.org`
4. Click "Add" again to add `www.duemate.org` (recommended)

### Step 2: Configure DNS Records

Vercel will provide you with DNS records to configure. You'll need to add these records at your domain registrar.

#### Option A: Using Vercel Nameservers (Recommended)

1. Vercel will provide nameserver addresses like:

   ```
   ns1.vercel-dns.com
   ns2.vercel-dns.com
   ```

2. Update your domain's nameservers at your registrar:
   - Log in to your domain registrar (GoDaddy, Namecheap, etc.)
   - Find DNS/Nameserver settings
   - Replace existing nameservers with Vercel's nameservers
   - Save changes

3. Wait for DNS propagation (can take 24-48 hours, usually faster)

#### Option B: Using CNAME Records

If you prefer to keep your existing nameservers:

1. Add these DNS records at your domain registrar:

   **For root domain (duemate.org):**
   - Type: A
   - Name: @ (or leave blank)
   - Value: 76.76.21.21

   **For www subdomain (www.duemate.org):**
   - Type: CNAME
   - Name: www
   - Value: cname.vercel-dns.com

2. Save the changes

3. Wait for DNS propagation (usually 5-30 minutes)

### Step 3: Verify Domain

1. Return to Vercel Dashboard → Settings → Domains
2. Wait for the domain status to show "Valid Configuration"
3. If you see any errors, click "Refresh" and wait a few minutes
4. Once verified, your site will be accessible at https://duemate.org

## SSL/HTTPS Configuration

Vercel automatically provisions and renews SSL certificates for your domains using Let's Encrypt. No additional configuration is needed!

- Your site will be accessible via HTTPS
- HTTP requests are automatically redirected to HTTPS
- Certificates are automatically renewed

## Environment Variables for Production

Set these in Vercel Dashboard → Settings → Environment Variables:

### Required Variables

```bash
# Database (use a production database)
DATABASE_URL="postgresql://user:password@host:5432/dbname"

# Node Environment
NODE_ENV="production"

# API Base URL
API_BASE_URL="https://duemate.org"
```

### Optional Variables (for future features)

```bash
# Email/SMTP for reminders
SMTP_HOST="smtp.sendgrid.net"
SMTP_PORT="587"
SMTP_USER="apikey"
SMTP_PASS="your-sendgrid-api-key"
SMTP_FROM="noreply@duemate.org"

# Error Tracking (optional)
SENTRY_DSN="https://your-sentry-dsn"

# Analytics (optional)
NEXT_PUBLIC_ANALYTICS_ID="your-analytics-id"
```

## Database Setup for Production

### Option 1: Vercel Postgres (Recommended)

1. In Vercel Dashboard, go to **Storage** tab
2. Click "Create Database" → Choose "Postgres"
3. Select your plan (Hobby is free)
4. Click "Create"
5. Copy the connection string to your environment variables

### Option 2: External Database Provider

Popular options:

- **Supabase**: Free tier with generous limits
- **Neon**: Serverless Postgres
- **PlanetScale**: MySQL alternative

After setting up your database:

1. Update `DATABASE_URL` in Vercel environment variables
2. Run migrations:
   ```bash
   # Using Vercel CLI
   vercel env pull .env.production.local
   npx prisma migrate deploy
   ```

## Continuous Deployment

Vercel automatically deploys your site when you push to your GitHub repository:

- **Push to `main` branch**: Deploys to production (duemate.org)
- **Push to other branches**: Creates preview deployments
- **Pull Requests**: Automatically creates preview URLs

## Monitoring and Logs

### View Deployment Logs

1. Go to Vercel Dashboard → Deployments
2. Click on any deployment
3. View build logs and runtime logs

### Analytics

Enable Vercel Analytics (optional):

1. Go to Analytics tab in Vercel Dashboard
2. Click "Enable Analytics"
3. View real-time traffic, Core Web Vitals, and performance metrics

## Troubleshooting

### Build Failures

1. Check build logs in Vercel Dashboard
2. Ensure all dependencies are in `package.json`
3. Verify environment variables are set correctly
4. Test build locally: `npm run build`

### Domain Not Working

1. Verify DNS records are correct
2. Check DNS propagation: https://dnschecker.org
3. Wait up to 48 hours for DNS to fully propagate
4. Try clearing your browser cache

### Database Connection Issues

1. Verify `DATABASE_URL` is correct
2. Ensure database allows connections from Vercel IPs
3. Check database is running and accessible
4. Run migrations: `npx prisma migrate deploy`

### SSL Certificate Issues

1. Vercel handles SSL automatically
2. If issues persist, try removing and re-adding the domain
3. Contact Vercel support if problems continue

## Rollback Deployments

To rollback to a previous deployment:

1. Go to Deployments in Vercel Dashboard
2. Find the deployment you want to rollback to
3. Click the three dots menu → "Promote to Production"

## Additional Resources

- [Vercel Documentation](https://vercel.com/docs)
- [Next.js Deployment](https://nextjs.org/docs/deployment)
- [Prisma Deployment](https://www.prisma.io/docs/guides/deployment)
- [Custom Domains on Vercel](https://vercel.com/docs/concepts/projects/domains)

## Support

If you encounter issues:

1. Check the [Vercel Status Page](https://www.vercel-status.com/)
2. Visit [Vercel Community](https://github.com/vercel/vercel/discussions)
3. Open an issue on the [DueMate GitHub repository](https://github.com/pedaganim/duemate/issues)
