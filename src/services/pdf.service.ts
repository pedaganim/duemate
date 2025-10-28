import PDFDocument from 'pdfkit';
import { Invoice } from '../models/invoice.model';
import { InvoiceItem } from '../types/invoice.types';
import { formatCurrency } from '../utils/currency';

export class PDFService {
  /**
   * Generate a PDF invoice
   */
  generateInvoicePDF(invoice: Invoice): PDFKit.PDFDocument {
    const doc = new PDFDocument({ margin: 50 });

    // Parse items if they're stored as JSON string
    const items: InvoiceItem[] = invoice.items
      ? typeof invoice.items === 'string'
        ? JSON.parse(invoice.items)
        : invoice.items
      : [];

    this.addHeader(doc, invoice);
    this.addInvoiceDetails(doc, invoice);
    this.addClientDetails(doc, invoice);
    this.addLineItems(doc, items, invoice.currency);
    this.addTotals(doc, invoice);
    this.addFooter(doc, invoice);

    doc.end();
    return doc;
  }

  private addHeader(doc: PDFKit.PDFDocument, invoice: Invoice) {
    doc
      .fontSize(20)
      .font('Helvetica-Bold')
      .text('INVOICE', 50, 50, { align: 'right' });

    // Vendor/Customer details (if provided)
    if (invoice.customerDetails) {
      doc
        .fontSize(10)
        .font('Helvetica')
        .text(invoice.customerDetails, 50, 50, { width: 250 });
    } else {
      doc
        .fontSize(10)
        .font('Helvetica')
        .text('DueMate Invoice System', 50, 50)
        .text('123 Business Street', 50, 65)
        .text('City, State 12345', 50, 80)
        .text('contact@duemate.com', 50, 95);
    }

    doc.moveDown(2);
  }

  private addInvoiceDetails(doc: PDFKit.PDFDocument, invoice: Invoice) {
    const y = 140;
    doc
      .fontSize(10)
      .font('Helvetica-Bold')
      .text('Invoice Number:', 350, y)
      .font('Helvetica')
      .text(invoice.invoiceNumber, 460, y);

    doc
      .font('Helvetica-Bold')
      .text('Issue Date:', 350, y + 15)
      .font('Helvetica')
      .text(new Date(invoice.issueDate).toLocaleDateString(), 460, y + 15);

    doc
      .font('Helvetica-Bold')
      .text('Due Date:', 350, y + 30)
      .font('Helvetica')
      .text(new Date(invoice.dueDate).toLocaleDateString(), 460, y + 30);

    doc
      .font('Helvetica-Bold')
      .text('Status:', 350, y + 45)
      .font('Helvetica')
      .text(invoice.status.toUpperCase(), 460, y + 45);
  }

  private addClientDetails(doc: PDFKit.PDFDocument, invoice: Invoice) {
    const y = 140;
    doc
      .fontSize(10)
      .font('Helvetica-Bold')
      .text('BILL TO:', 50, y);

    // Use clientDetails if provided, otherwise fall back to individual fields
    if (invoice.clientDetails) {
      doc
        .font('Helvetica')
        .text(invoice.clientDetails, 50, y + 15, { width: 250 });
    } else {
      doc
        .font('Helvetica')
        .text(invoice.clientName, 50, y + 15)
        .text(invoice.clientEmail, 50, y + 30);

      if (invoice.clientAddress) {
        doc.text(invoice.clientAddress, 50, y + 45);
      }
    }

    doc.moveDown(3);
  }

  private addLineItems(doc: PDFKit.PDFDocument, items: InvoiceItem[], currency: string) {
    const tableTop = 280;
    const itemCodeX = 50;
    const descriptionX = 150;
    const quantityX = 320;
    const priceX = 390;
    const amountX = 480;

    // Table header
    doc
      .fontSize(10)
      .font('Helvetica-Bold')
      .text('Description', descriptionX, tableTop)
      .text('Qty', quantityX, tableTop)
      .text('Unit Price', priceX, tableTop)
      .text('Amount', amountX, tableTop);

    // Draw line under header
    doc
      .strokeColor('#aaaaaa')
      .lineWidth(1)
      .moveTo(50, tableTop + 15)
      .lineTo(550, tableTop + 15)
      .stroke();

    // Table rows
    let position = tableTop + 25;
    doc.font('Helvetica');

    if (items && items.length > 0) {
      items.forEach((item, index) => {
        doc
          .fontSize(9)
          .text(item.description, descriptionX, position, { width: 150 })
          .text(item.quantity.toString(), quantityX, position)
          .text(formatCurrency(item.unitPrice, currency), priceX, position)
          .text(formatCurrency(item.amount, currency), amountX, position);

        position += 25;
      });
    } else {
      doc.fontSize(9).text('No line items', descriptionX, position);
      position += 25;
    }

    // Draw line after items
    doc
      .strokeColor('#aaaaaa')
      .lineWidth(1)
      .moveTo(50, position)
      .lineTo(550, position)
      .stroke();

    return position;
  }

  private addTotals(doc: PDFKit.PDFDocument, invoice: Invoice) {
    const position = 480;
    let yOffset = position;

    doc.fontSize(10).font('Helvetica-Bold');

    // Subtotal
    doc.text('Subtotal:', 380, yOffset).text(formatCurrency(invoice.subtotal, invoice.currency), 480, yOffset);
    yOffset += 20;

    // Discount
    if (invoice.discount && invoice.discount > 0) {
      doc
        .text(`Discount (${invoice.discount}%):`, 380, yOffset)
        .text(`-${formatCurrency(invoice.discountAmount || 0, invoice.currency)}`, 480, yOffset);
      yOffset += 20;
    }

    // Shipping
    if (invoice.shipping && invoice.shipping > 0) {
      doc
        .text('Shipping:', 380, yOffset)
        .text(formatCurrency(invoice.shipping, invoice.currency), 480, yOffset);
      yOffset += 20;
    }

    // Tax
    if (invoice.taxRate && invoice.taxRate > 0) {
      doc
        .text(`Tax (${invoice.taxRate}%):`, 380, yOffset)
        .text(formatCurrency(invoice.taxAmount || 0, invoice.currency), 480, yOffset);
      yOffset += 20;
    }

    // Total
    doc
      .fontSize(12)
      .text('TOTAL:', 380, yOffset)
      .text(`${invoice.currency} ${formatCurrency(invoice.total, invoice.currency)}`, 480, yOffset);
    yOffset += 30;

    // Amount Paid
    if (invoice.amountPaid && invoice.amountPaid > 0) {
      doc
        .fontSize(10)
        .text('Amount Paid:', 380, yOffset)
        .text(formatCurrency(invoice.amountPaid, invoice.currency), 480, yOffset);
      yOffset += 20;
    }

    // Balance Due
    if (invoice.balanceDue !== undefined && invoice.balanceDue !== null) {
      doc
        .fontSize(12)
        .font('Helvetica-Bold')
        .text('BALANCE DUE:', 380, yOffset)
        .text(`${invoice.currency} ${formatCurrency(invoice.balanceDue, invoice.currency)}`, 480, yOffset);
    }

    doc.fontSize(10).font('Helvetica');
  }

  private addFooter(doc: PDFKit.PDFDocument, invoice: Invoice) {
    const y = 650;

    if (invoice.notes) {
      doc
        .fontSize(9)
        .font('Helvetica-Bold')
        .text('Notes:', 50, y)
        .font('Helvetica')
        .text(invoice.notes, 50, y + 15, { width: 500 });
    }

    if (invoice.description) {
      doc
        .fontSize(9)
        .font('Helvetica-Bold')
        .text('Description:', 50, y + 50)
        .font('Helvetica')
        .text(invoice.description, 50, y + 65, { width: 500 });
    }

    // Add footer
    doc
      .fontSize(8)
      .font('Helvetica')
      .text(
        'Thank you for your business!',
        50,
        doc.page.height - 50,
        { align: 'center', width: doc.page.width - 100 }
      );
  }
}

export default new PDFService();
