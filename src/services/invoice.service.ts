import { Invoice } from '@prisma/client';
import prisma from '../config/database';
import { CreateInvoiceDTO, UpdateInvoiceDTO, InvoiceQueryParams } from '../types/invoice.types';

export class InvoiceService {
  /**
   * Generate a unique invoice number
   */
  private async generateInvoiceNumber(): Promise<string> {
    const year = new Date().getFullYear();
    const lastInvoice = await prisma.invoice.findFirst({
      where: {
        invoiceNumber: {
          startsWith: `INV-${year}`,
        },
      },
      orderBy: {
        invoiceNumber: 'desc',
      },
    });

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

    return prisma.invoice.create({
      data: {
        ...data,
        invoiceNumber,
        issueDate: data.issueDate ? new Date(data.issueDate) : new Date(),
        dueDate: new Date(data.dueDate),
        items: data.items ? JSON.stringify(data.items) : undefined,
      },
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

    const skip = (page - 1) * limit;

    const where: any = {};

    if (status) {
      where.status = status;
    }

    if (clientEmail) {
      where.clientEmail = {
        contains: clientEmail,
        mode: 'insensitive',
      };
    }

    if (startDate || endDate) {
      where.issueDate = {};
      if (startDate) {
        where.issueDate.gte = new Date(startDate);
      }
      if (endDate) {
        where.issueDate.lte = new Date(endDate);
      }
    }

    const [invoices, total] = await Promise.all([
      prisma.invoice.findMany({
        where,
        skip,
        take: limit,
        orderBy: {
          [sortBy]: sortOrder,
        },
      }),
      prisma.invoice.count({ where }),
    ]);

    return {
      data: invoices.map((invoice) => ({
        ...invoice,
        items: invoice.items ? JSON.parse(invoice.items as string) : null,
      })),
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Get a single invoice by ID
   */
  async getInvoiceById(id: string): Promise<Invoice | null> {
    const invoice = await prisma.invoice.findUnique({
      where: { id },
    });

    if (!invoice) {
      return null;
    }

    return {
      ...invoice,
      items: invoice.items ? JSON.parse(invoice.items as string) : null,
    } as Invoice;
  }

  /**
   * Update an invoice
   */
  async updateInvoice(id: string, data: UpdateInvoiceDTO): Promise<Invoice> {
    return prisma.invoice.update({
      where: { id },
      data: {
        ...data,
        issueDate: data.issueDate ? new Date(data.issueDate) : undefined,
        dueDate: data.dueDate ? new Date(data.dueDate) : undefined,
        items: data.items ? JSON.stringify(data.items) : undefined,
      },
    });
  }

  /**
   * Delete an invoice
   */
  async deleteInvoice(id: string): Promise<Invoice> {
    return prisma.invoice.delete({
      where: { id },
    });
  }

  /**
   * Check if invoice exists
   */
  async invoiceExists(id: string): Promise<boolean> {
    const count = await prisma.invoice.count({
      where: { id },
    });
    return count > 0;
  }
}

export default new InvoiceService();
