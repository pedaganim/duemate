-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_Invoice" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "invoiceNumber" TEXT NOT NULL,
    "clientName" TEXT NOT NULL,
    "clientEmail" TEXT NOT NULL,
    "clientAddress" TEXT,
    "clientDetails" TEXT,
    "customerDetails" TEXT,
    "amount" REAL NOT NULL,
    "currency" TEXT NOT NULL DEFAULT 'AUD',
    "issueDate" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "dueDate" DATETIME NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'draft',
    "description" TEXT,
    "items" JSONB,
    "notes" TEXT,
    "taxRate" REAL DEFAULT 0,
    "taxAmount" REAL DEFAULT 0,
    "discount" REAL DEFAULT 0,
    "discountAmount" REAL DEFAULT 0,
    "shipping" REAL DEFAULT 0,
    "subtotal" REAL NOT NULL,
    "total" REAL NOT NULL,
    "amountPaid" REAL DEFAULT 0,
    "balanceDue" REAL DEFAULT 0,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);
INSERT INTO "new_Invoice" ("amount", "clientAddress", "clientEmail", "clientName", "createdAt", "currency", "description", "dueDate", "id", "invoiceNumber", "issueDate", "items", "notes", "status", "subtotal", "taxAmount", "taxRate", "total", "updatedAt") SELECT "amount", "clientAddress", "clientEmail", "clientName", "createdAt", "currency", "description", "dueDate", "id", "invoiceNumber", "issueDate", "items", "notes", "status", "subtotal", "taxAmount", "taxRate", "total", "updatedAt" FROM "Invoice";
DROP TABLE "Invoice";
ALTER TABLE "new_Invoice" RENAME TO "Invoice";
CREATE UNIQUE INDEX "Invoice_invoiceNumber_key" ON "Invoice"("invoiceNumber");
CREATE INDEX "Invoice_invoiceNumber_idx" ON "Invoice"("invoiceNumber");
CREATE INDEX "Invoice_status_idx" ON "Invoice"("status");
CREATE INDEX "Invoice_clientEmail_idx" ON "Invoice"("clientEmail");
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;
