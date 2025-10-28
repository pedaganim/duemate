/**
 * Invoice Model - DynamoDB Entity
 * 
 * This interface defines the structure of an Invoice entity in DynamoDB
 */

export interface Invoice {
  id: string;
  invoiceNumber: string;
  clientName: string;
  clientEmail: string;
  clientAddress?: string;
  clientDetails?: string;
  customerDetails?: string;
  amount: number;
  currency: string;
  issueDate: Date;
  dueDate: Date;
  status: string;
  description?: string;
  items?: any; // Will be stored as JSON in DynamoDB
  notes?: string;
  taxRate?: number;
  taxAmount?: number;
  discount?: number;
  discountAmount?: number;
  shipping?: number;
  subtotal: number;
  total: number;
  amountPaid?: number;
  balanceDue?: number;
  createdAt: Date;
  updatedAt: Date;
}

/**
 * DynamoDB Item representation of Invoice
 * This is how the data is stored in DynamoDB with all fields as strings/numbers
 */
export interface InvoiceDynamoDBItem {
  PK: string; // Partition Key: INVOICE#<id>
  SK: string; // Sort Key: INVOICE#<id>
  GSI1PK: string; // Global Secondary Index 1 PK: INVOICE_NUMBER#<invoiceNumber>
  GSI1SK: string; // Global Secondary Index 1 SK: INVOICE_NUMBER#<invoiceNumber>
  GSI2PK: string; // Global Secondary Index 2 PK: STATUS#<status>
  GSI2SK: string; // Global Secondary Index 2 SK: <createdAt>
  GSI3PK: string; // Global Secondary Index 3 PK: CLIENT_EMAIL#<clientEmail>
  GSI3SK: string; // Global Secondary Index 3 SK: <createdAt>
  id: string;
  invoiceNumber: string;
  clientName: string;
  clientEmail: string;
  clientAddress?: string;
  clientDetails?: string;
  customerDetails?: string;
  amount: number;
  currency: string;
  issueDate: string; // ISO string
  dueDate: string; // ISO string
  status: string;
  description?: string;
  items?: string; // JSON string
  notes?: string;
  taxRate?: number;
  taxAmount?: number;
  discount?: number;
  discountAmount?: number;
  shipping?: number;
  subtotal: number;
  total: number;
  amountPaid?: number;
  balanceDue?: number;
  createdAt: string; // ISO string
  updatedAt: string; // ISO string
  entityType: string; // Always "INVOICE"
}
