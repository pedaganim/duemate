export interface InvoiceItem {
  description: string;
  quantity: number;
  unitPrice: number;
  amount: number;
}

export interface CreateInvoiceDTO {
  invoiceNumber?: string;
  clientName: string;
  clientEmail: string;
  clientAddress?: string;
  clientDetails?: string;
  customerDetails?: string;
  amount: number;
  currency?: string;
  issueDate?: Date | string;
  dueDate: Date | string;
  status?: string;
  description?: string;
  items?: InvoiceItem[];
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
}

export interface UpdateInvoiceDTO {
  clientName?: string;
  clientEmail?: string;
  clientAddress?: string;
  clientDetails?: string;
  customerDetails?: string;
  amount?: number;
  currency?: string;
  issueDate?: Date | string;
  dueDate?: Date | string;
  status?: string;
  description?: string;
  items?: InvoiceItem[];
  notes?: string;
  taxRate?: number;
  taxAmount?: number;
  discount?: number;
  discountAmount?: number;
  shipping?: number;
  subtotal?: number;
  total?: number;
  amountPaid?: number;
  balanceDue?: number;
}

export interface InvoiceQueryParams {
  page?: number;
  limit?: number;
  status?: string;
  clientEmail?: string;
  startDate?: string;
  endDate?: string;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}
