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
  subtotal: number;
  total: number;
}

export interface UpdateInvoiceDTO {
  clientName?: string;
  clientEmail?: string;
  clientAddress?: string;
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
  subtotal?: number;
  total?: number;
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
