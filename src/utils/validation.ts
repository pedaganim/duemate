import Joi from 'joi';

const invoiceItemSchema = Joi.object({
  description: Joi.string().required(),
  quantity: Joi.number().positive().required(),
  unitPrice: Joi.number().min(0).required(),
  amount: Joi.number().min(0).required(),
});

export const createInvoiceSchema = Joi.object({
  invoiceNumber: Joi.string().optional(),
  clientName: Joi.string().required().min(2).max(255),
  clientEmail: Joi.string().email().required(),
  clientAddress: Joi.string().optional().allow(''),
  amount: Joi.number().min(0).required(),
  currency: Joi.string().length(3).default('USD'),
  issueDate: Joi.date().iso().optional(),
  dueDate: Joi.date().iso().required(),
  status: Joi.string()
    .valid('draft', 'sent', 'paid', 'overdue', 'cancelled')
    .default('draft'),
  description: Joi.string().optional().allow(''),
  items: Joi.array().items(invoiceItemSchema).optional(),
  notes: Joi.string().optional().allow(''),
  taxRate: Joi.number().min(0).max(100).optional(),
  taxAmount: Joi.number().min(0).optional(),
  subtotal: Joi.number().min(0).required(),
  total: Joi.number().min(0).required(),
});

export const updateInvoiceSchema = Joi.object({
  clientName: Joi.string().min(2).max(255).optional(),
  clientEmail: Joi.string().email().optional(),
  clientAddress: Joi.string().optional().allow(''),
  amount: Joi.number().min(0).optional(),
  currency: Joi.string().length(3).optional(),
  issueDate: Joi.date().iso().optional(),
  dueDate: Joi.date().iso().optional(),
  status: Joi.string()
    .valid('draft', 'sent', 'paid', 'overdue', 'cancelled')
    .optional(),
  description: Joi.string().optional().allow(''),
  items: Joi.array().items(invoiceItemSchema).optional(),
  notes: Joi.string().optional().allow(''),
  taxRate: Joi.number().min(0).max(100).optional(),
  taxAmount: Joi.number().min(0).optional(),
  subtotal: Joi.number().min(0).optional(),
  total: Joi.number().min(0).optional(),
}).min(1);

export const queryInvoicesSchema = Joi.object({
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(10),
  status: Joi.string()
    .valid('draft', 'sent', 'paid', 'overdue', 'cancelled')
    .optional(),
  clientEmail: Joi.string().email().optional(),
  startDate: Joi.date().iso().optional(),
  endDate: Joi.date().iso().optional(),
  sortBy: Joi.string()
    .valid('invoiceNumber', 'issueDate', 'dueDate', 'amount', 'status', 'createdAt')
    .default('createdAt'),
  sortOrder: Joi.string().valid('asc', 'desc').default('desc'),
});
