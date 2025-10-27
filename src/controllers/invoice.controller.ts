import { Request, Response } from 'express';
import invoiceService from '../services/invoice.service';
import pdfService from '../services/pdf.service';
import {
  createInvoiceSchema,
  updateInvoiceSchema,
  queryInvoicesSchema,
} from '../utils/validation';

export class InvoiceController {
  /**
   * Create a new invoice
   * POST /api/invoices
   */
  async create(req: Request, res: Response): Promise<void> {
    try {
      const { error, value } = createInvoiceSchema.validate(req.body);

      if (error) {
        res.status(400).json({
          success: false,
          error: 'Validation error',
          details: error.details.map((d) => d.message),
        });
        return;
      }

      const invoice = await invoiceService.createInvoice(value);

      res.status(201).json({
        success: true,
        data: invoice,
      });
    } catch (error: any) {
      res.status(500).json({
        success: false,
        error: 'Failed to create invoice',
        message: error.message,
      });
    }
  }

  /**
   * Get all invoices with filtering and pagination
   * GET /api/invoices
   */
  async getAll(req: Request, res: Response): Promise<void> {
    try {
      const { error, value } = queryInvoicesSchema.validate(req.query);

      if (error) {
        res.status(400).json({
          success: false,
          error: 'Validation error',
          details: error.details.map((d) => d.message),
        });
        return;
      }

      const result = await invoiceService.getInvoices(value);

      res.status(200).json({
        success: true,
        ...result,
      });
    } catch (error: any) {
      res.status(500).json({
        success: false,
        error: 'Failed to fetch invoices',
        message: error.message,
      });
    }
  }

  /**
   * Get a single invoice by ID
   * GET /api/invoices/:id
   */
  async getById(req: Request, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      const invoice = await invoiceService.getInvoiceById(id);

      if (!invoice) {
        res.status(404).json({
          success: false,
          error: 'Invoice not found',
        });
        return;
      }

      res.status(200).json({
        success: true,
        data: invoice,
      });
    } catch (error: any) {
      res.status(500).json({
        success: false,
        error: 'Failed to fetch invoice',
        message: error.message,
      });
    }
  }

  /**
   * Update an invoice
   * PUT /api/invoices/:id
   */
  async update(req: Request, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      const { error, value } = updateInvoiceSchema.validate(req.body);

      if (error) {
        res.status(400).json({
          success: false,
          error: 'Validation error',
          details: error.details.map((d) => d.message),
        });
        return;
      }

      const exists = await invoiceService.invoiceExists(id);
      if (!exists) {
        res.status(404).json({
          success: false,
          error: 'Invoice not found',
        });
        return;
      }

      const invoice = await invoiceService.updateInvoice(id, value);

      res.status(200).json({
        success: true,
        data: invoice,
      });
    } catch (error: any) {
      res.status(500).json({
        success: false,
        error: 'Failed to update invoice',
        message: error.message,
      });
    }
  }

  /**
   * Delete an invoice
   * DELETE /api/invoices/:id
   */
  async delete(req: Request, res: Response): Promise<void> {
    try {
      const { id } = req.params;

      const exists = await invoiceService.invoiceExists(id);
      if (!exists) {
        res.status(404).json({
          success: false,
          error: 'Invoice not found',
        });
        return;
      }

      await invoiceService.deleteInvoice(id);

      res.status(200).json({
        success: true,
        message: 'Invoice deleted successfully',
      });
    } catch (error: any) {
      res.status(500).json({
        success: false,
        error: 'Failed to delete invoice',
        message: error.message,
      });
    }
  }

  /**
   * Preview invoice (returns PDF in browser)
   * GET /api/invoices/:id/preview
   */
  async preview(req: Request, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      const invoice = await invoiceService.getInvoiceById(id);

      if (!invoice) {
        res.status(404).json({
          success: false,
          error: 'Invoice not found',
        });
        return;
      }

      const pdfDoc = pdfService.generateInvoicePDF(invoice);

      res.setHeader('Content-Type', 'application/pdf');
      res.setHeader('Content-Disposition', `inline; filename=invoice-${invoice.invoiceNumber}.pdf`);

      pdfDoc.pipe(res);
    } catch (error: any) {
      res.status(500).json({
        success: false,
        error: 'Failed to generate invoice preview',
        message: error.message,
      });
    }
  }

  /**
   * Download invoice as PDF
   * GET /api/invoices/:id/download
   */
  async download(req: Request, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      const invoice = await invoiceService.getInvoiceById(id);

      if (!invoice) {
        res.status(404).json({
          success: false,
          error: 'Invoice not found',
        });
        return;
      }

      const pdfDoc = pdfService.generateInvoicePDF(invoice);

      res.setHeader('Content-Type', 'application/pdf');
      res.setHeader('Content-Disposition', `attachment; filename=invoice-${invoice.invoiceNumber}.pdf`);

      pdfDoc.pipe(res);
    } catch (error: any) {
      res.status(500).json({
        success: false,
        error: 'Failed to download invoice',
        message: error.message,
      });
    }
  }
}

export default new InvoiceController();
