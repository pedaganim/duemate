import { Router } from 'express';
import invoiceController from '../controllers/invoice.controller';

const router = Router();

/**
 * @swagger
 * components:
 *   schemas:
 *     InvoiceItem:
 *       type: object
 *       required:
 *         - description
 *         - quantity
 *         - unitPrice
 *         - amount
 *       properties:
 *         description:
 *           type: string
 *         quantity:
 *           type: number
 *         unitPrice:
 *           type: number
 *         amount:
 *           type: number
 *     Invoice:
 *       type: object
 *       required:
 *         - clientName
 *         - clientEmail
 *         - amount
 *         - dueDate
 *         - subtotal
 *         - total
 *       properties:
 *         id:
 *           type: string
 *         invoiceNumber:
 *           type: string
 *         clientName:
 *           type: string
 *         clientEmail:
 *           type: string
 *         clientAddress:
 *           type: string
 *         clientDetails:
 *           type: string
 *           description: Client company details (name, ABN, address, etc.)
 *         customerDetails:
 *           type: string
 *           description: Vendor/Seller company details (name, ABN, address, etc.)
 *         amount:
 *           type: number
 *         currency:
 *           type: string
 *           default: AUD
 *           enum: [AUD, USD, EUR, GBP, JPY, CAD, CHF, CNY, SEK, NZD, MXN, SGD, HKD, NOK, KRW, TRY, RUB, INR, BRL, ZAR]
 *         issueDate:
 *           type: string
 *           format: date-time
 *         dueDate:
 *           type: string
 *           format: date-time
 *         status:
 *           type: string
 *           enum: [draft, sent, paid, overdue, cancelled]
 *         description:
 *           type: string
 *         items:
 *           type: array
 *           items:
 *             $ref: '#/components/schemas/InvoiceItem'
 *         notes:
 *           type: string
 *         taxRate:
 *           type: number
 *           description: Tax rate percentage (0-100)
 *         taxAmount:
 *           type: number
 *         discount:
 *           type: number
 *           description: Discount percentage (0-100)
 *         discountAmount:
 *           type: number
 *         shipping:
 *           type: number
 *         subtotal:
 *           type: number
 *         total:
 *           type: number
 *         amountPaid:
 *           type: number
 *         balanceDue:
 *           type: number
 */

/**
 * @swagger
 * /api/invoices:
 *   post:
 *     summary: Create a new invoice
 *     tags: [Invoices]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/Invoice'
 *     responses:
 *       201:
 *         description: Invoice created successfully
 *       400:
 *         description: Validation error
 *       500:
 *         description: Server error
 */
router.post('/', (req, res) => invoiceController.create(req, res));

/**
 * @swagger
 * /api/invoices:
 *   get:
 *     summary: Get all invoices with optional filtering
 *     tags: [Invoices]
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           default: 1
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 10
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *           enum: [draft, sent, paid, overdue, cancelled]
 *       - in: query
 *         name: clientEmail
 *         schema:
 *           type: string
 *       - in: query
 *         name: startDate
 *         schema:
 *           type: string
 *           format: date
 *       - in: query
 *         name: endDate
 *         schema:
 *           type: string
 *           format: date
 *       - in: query
 *         name: sortBy
 *         schema:
 *           type: string
 *           default: createdAt
 *       - in: query
 *         name: sortOrder
 *         schema:
 *           type: string
 *           enum: [asc, desc]
 *           default: desc
 *     responses:
 *       200:
 *         description: List of invoices
 *       400:
 *         description: Validation error
 *       500:
 *         description: Server error
 */
router.get('/', (req, res) => invoiceController.getAll(req, res));

/**
 * @swagger
 * /api/invoices/{id}:
 *   get:
 *     summary: Get a single invoice by ID
 *     tags: [Invoices]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Invoice details
 *       404:
 *         description: Invoice not found
 *       500:
 *         description: Server error
 */
router.get('/:id', (req, res) => invoiceController.getById(req, res));

/**
 * @swagger
 * /api/invoices/{id}:
 *   put:
 *     summary: Update an invoice
 *     tags: [Invoices]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/Invoice'
 *     responses:
 *       200:
 *         description: Invoice updated successfully
 *       400:
 *         description: Validation error
 *       404:
 *         description: Invoice not found
 *       500:
 *         description: Server error
 */
router.put('/:id', (req, res) => invoiceController.update(req, res));

/**
 * @swagger
 * /api/invoices/{id}:
 *   delete:
 *     summary: Delete an invoice
 *     tags: [Invoices]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Invoice deleted successfully
 *       404:
 *         description: Invoice not found
 *       500:
 *         description: Server error
 */
router.delete('/:id', (req, res) => invoiceController.delete(req, res));

/**
 * @swagger
 * /api/invoices/{id}/preview:
 *   get:
 *     summary: Preview invoice as PDF in browser
 *     tags: [Invoices]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: PDF preview
 *         content:
 *           application/pdf:
 *             schema:
 *               type: string
 *               format: binary
 *       404:
 *         description: Invoice not found
 *       500:
 *         description: Server error
 */
router.get('/:id/preview', (req, res) => invoiceController.preview(req, res));

/**
 * @swagger
 * /api/invoices/{id}/download:
 *   get:
 *     summary: Download invoice as PDF
 *     tags: [Invoices]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: PDF download
 *         content:
 *           application/pdf:
 *             schema:
 *               type: string
 *               format: binary
 *       404:
 *         description: Invoice not found
 *       500:
 *         description: Server error
 */
router.get('/:id/download', (req, res) => invoiceController.download(req, res));

export default router;
