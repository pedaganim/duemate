import { Invoice } from '../models/invoice.model';
import invoiceRepository from '../repositories/invoice.repository';
import { CreateInvoiceDTO, UpdateInvoiceDTO, InvoiceQueryParams } from '../types/invoice.types';

export class InvoiceService {
  /**
   * Generate a unique invoice number
   */
  private async generateInvoiceNumber(): Promise<string> {
    const year = new Date().getFullYear();
    const prefix = `INV-${year}`;
    
    // Find the last invoice with this year's prefix
    const lastInvoice = await invoiceRepository.findByInvoiceNumberPrefix(prefix);

    let nextNumber = 1;
    if (lastInvoice) {
      const lastNumber = parseInt(lastInvoice.invoiceNumber.split('-')[2] || '0');
      nextNumber = lastNumber + 1;
    }

    return `INV-${year}-${nextNumber.toString().padStart(5, '0')}`;
  }

  /**
   * Create a new invoice
   */
  async createInvoice(data: CreateInvoiceDTO): Promise<Invoice> {
    const invoiceNumber = data.invoiceNumber || (await this.generateInvoiceNumber());

    return invoiceRepository.create({
      ...data,
      invoiceNumber,
      issueDate: data.issueDate ? new Date(data.issueDate) : new Date(),
      dueDate: new Date(data.dueDate),
    });
  }

  /**
   * Get all invoices with filtering and pagination
   */
  async getInvoices(params: InvoiceQueryParams) {
    const {
      page = 1,
      limit = 10,
      status,
      clientEmail,
      startDate,
      endDate,
      sortBy = 'createdAt',
      sortOrder = 'desc',
    } = params;

    let items: Invoice[] = [];
    let totalCount = 0;

    // Use GSI for efficient queries when possible
    if (status && !clientEmail && !startDate && !endDate) {
      // Query by status using GSI2 with proper pagination
      let lastEvaluatedKey: any = undefined;
      let currentPage = 1;
      
      while (currentPage <= page) {
        const result = await invoiceRepository.findByStatus(status, limit, lastEvaluatedKey);
        
        if (currentPage === page) {
          items = result.items;
        }
        
        lastEvaluatedKey = result.lastEvaluatedKey;
        
        if (!lastEvaluatedKey || result.items.length === 0) {
          break;
        }
        
        currentPage++;
      }
      
      // Approximate total count (DynamoDB doesn't provide exact totals efficiently)
      totalCount = (page - 1) * limit + items.length;
    } else if (clientEmail && !status && !startDate && !endDate) {
      // Query by client email using GSI3 with proper pagination
      let lastEvaluatedKey: any = undefined;
      let currentPage = 1;
      
      while (currentPage <= page) {
        const result = await invoiceRepository.findByClientEmail(clientEmail, limit, lastEvaluatedKey);
        
        if (currentPage === page) {
          items = result.items;
        }
        
        lastEvaluatedKey = result.lastEvaluatedKey;
        
        if (!lastEvaluatedKey || result.items.length === 0) {
          break;
        }
        
        currentPage++;
      }
      
      // Approximate total count
      totalCount = (page - 1) * limit + items.length;
    } else {
      // Use scan for complex filtering
      let filterExpression = '';
      const expressionAttributeValues: any = {};

      if (status) {
        filterExpression = 'status = :status';
        expressionAttributeValues[':status'] = status;
      }

      if (clientEmail) {
        if (filterExpression) filterExpression += ' AND ';
        filterExpression += 'contains(clientEmail, :email)';
        expressionAttributeValues[':email'] = clientEmail;
      }

      if (startDate || endDate) {
        if (startDate) {
          if (filterExpression) filterExpression += ' AND ';
          filterExpression += 'issueDate >= :startDate';
          expressionAttributeValues[':startDate'] = new Date(startDate).toISOString();
        }
        if (endDate) {
          if (filterExpression) filterExpression += ' AND ';
          filterExpression += 'issueDate <= :endDate';
          expressionAttributeValues[':endDate'] = new Date(endDate).toISOString();
        }
      }

      // Fetch all matching items (DynamoDB scan with filters)
      const result = await invoiceRepository.findAll(
        1000, // Max items to scan
        undefined,
        filterExpression || undefined,
        Object.keys(expressionAttributeValues).length > 0 ? expressionAttributeValues : undefined
      );

      items = result.items;
      totalCount = items.length;

      // Sort items
      items.sort((a, b) => {
        const aVal = (a as any)[sortBy];
        const bVal = (b as any)[sortBy];
        
        if (aVal instanceof Date && bVal instanceof Date) {
          return sortOrder === 'desc' ? bVal.getTime() - aVal.getTime() : aVal.getTime() - bVal.getTime();
        }
        
        if (typeof aVal === 'string' && typeof bVal === 'string') {
          return sortOrder === 'desc' ? bVal.localeCompare(aVal) : aVal.localeCompare(bVal);
        }
        
        return sortOrder === 'desc' ? bVal - aVal : aVal - bVal;
      });

      // Paginate
      items = items.slice((page - 1) * limit, page * limit);
    }

    return {
      data: items,
      pagination: {
        page,
        limit,
        total: totalCount,
        totalPages: Math.ceil(totalCount / limit),
      },
    };
  }

  /**
   * Get a single invoice by ID
   */
  async getInvoiceById(id: string): Promise<Invoice | null> {
    return invoiceRepository.findById(id);
  }

  /**
   * Update an invoice
   */
  async updateInvoice(id: string, data: UpdateInvoiceDTO): Promise<Invoice> {
    const updateData: Partial<Invoice> = {
      ...data,
      issueDate: data.issueDate ? new Date(data.issueDate) : undefined,
      dueDate: data.dueDate ? new Date(data.dueDate) : undefined,
    };
    
    return invoiceRepository.update(id, updateData);
  }

  /**
   * Delete an invoice
   */
  async deleteInvoice(id: string): Promise<void> {
    await invoiceRepository.delete(id);
  }

  /**
   * Check if invoice exists
   */
  async invoiceExists(id: string): Promise<boolean> {
    return invoiceRepository.exists(id);
  }
}

export default new InvoiceService();
