import {
  GetCommand,
  PutCommand,
  UpdateCommand,
  DeleteCommand,
  QueryCommand,
  ScanCommand,
} from '@aws-sdk/lib-dynamodb';
import { v4 as uuidv4 } from 'uuid';
import ddbDocClient, { TABLE_NAME } from '../config/database';
import { Invoice, InvoiceDynamoDBItem } from '../models/invoice.model';

/**
 * InvoiceRepository - Handles all DynamoDB operations for Invoices
 */
export class InvoiceRepository {
  private tableName: string;

  constructor() {
    this.tableName = TABLE_NAME;
  }

  /**
   * Convert Invoice to DynamoDB Item format
   */
  private toDynamoDBItem(invoice: Partial<Invoice>): Partial<InvoiceDynamoDBItem> {
    const item: Partial<InvoiceDynamoDBItem> = {
      ...invoice,
      issueDate: invoice.issueDate ? invoice.issueDate.toISOString() : undefined,
      dueDate: invoice.dueDate ? invoice.dueDate.toISOString() : undefined,
      createdAt: invoice.createdAt ? invoice.createdAt.toISOString() : undefined,
      updatedAt: invoice.updatedAt ? invoice.updatedAt.toISOString() : undefined,
      items: invoice.items ? JSON.stringify(invoice.items) : undefined,
      entityType: 'INVOICE',
    };

    if (invoice.id) {
      item.PK = `INVOICE#${invoice.id}`;
      item.SK = `INVOICE#${invoice.id}`;
    }

    if (invoice.invoiceNumber) {
      item.GSI1PK = `INVOICE_NUMBER#${invoice.invoiceNumber}`;
      item.GSI1SK = `INVOICE_NUMBER#${invoice.invoiceNumber}`;
    }

    if (invoice.status) {
      item.GSI2PK = `STATUS#${invoice.status}`;
      item.GSI2SK = invoice.createdAt ? invoice.createdAt.toISOString() : new Date().toISOString();
    }

    if (invoice.clientEmail) {
      item.GSI3PK = `CLIENT_EMAIL#${invoice.clientEmail}`;
      item.GSI3SK = invoice.createdAt ? invoice.createdAt.toISOString() : new Date().toISOString();
    }

    return item;
  }

  /**
   * Convert DynamoDB Item to Invoice format
   */
  private fromDynamoDBItem(item: InvoiceDynamoDBItem): Invoice {
    return {
      id: item.id,
      invoiceNumber: item.invoiceNumber,
      clientName: item.clientName,
      clientEmail: item.clientEmail,
      clientAddress: item.clientAddress,
      clientDetails: item.clientDetails,
      customerDetails: item.customerDetails,
      amount: item.amount,
      currency: item.currency,
      issueDate: new Date(item.issueDate),
      dueDate: new Date(item.dueDate),
      status: item.status,
      description: item.description,
      items: item.items ? JSON.parse(item.items) : null,
      notes: item.notes,
      taxRate: item.taxRate,
      taxAmount: item.taxAmount,
      discount: item.discount,
      discountAmount: item.discountAmount,
      shipping: item.shipping,
      subtotal: item.subtotal,
      total: item.total,
      amountPaid: item.amountPaid,
      balanceDue: item.balanceDue,
      createdAt: new Date(item.createdAt),
      updatedAt: new Date(item.updatedAt),
    };
  }

  /**
   * Create a new invoice
   */
  async create(data: Partial<Invoice>): Promise<Invoice> {
    const now = new Date();
    const id = uuidv4();

    const invoice: Invoice = {
      id,
      invoiceNumber: data.invoiceNumber!,
      clientName: data.clientName!,
      clientEmail: data.clientEmail!,
      clientAddress: data.clientAddress,
      clientDetails: data.clientDetails,
      customerDetails: data.customerDetails,
      amount: data.amount!,
      currency: data.currency || 'AUD',
      issueDate: data.issueDate || now,
      dueDate: data.dueDate!,
      status: data.status || 'draft',
      description: data.description,
      items: data.items,
      notes: data.notes,
      taxRate: data.taxRate,
      taxAmount: data.taxAmount,
      discount: data.discount,
      discountAmount: data.discountAmount,
      shipping: data.shipping,
      subtotal: data.subtotal!,
      total: data.total!,
      amountPaid: data.amountPaid || 0,
      balanceDue: data.balanceDue,
      createdAt: now,
      updatedAt: now,
    };

    const item = this.toDynamoDBItem(invoice);

    await ddbDocClient.send(
      new PutCommand({
        TableName: this.tableName,
        Item: item,
      })
    );

    return invoice;
  }

  /**
   * Get invoice by ID
   */
  async findById(id: string): Promise<Invoice | null> {
    const result = await ddbDocClient.send(
      new GetCommand({
        TableName: this.tableName,
        Key: {
          PK: `INVOICE#${id}`,
          SK: `INVOICE#${id}`,
        },
      })
    );

    if (!result.Item) {
      return null;
    }

    return this.fromDynamoDBItem(result.Item as InvoiceDynamoDBItem);
  }

  /**
   * Find invoice by invoice number
   */
  async findByInvoiceNumber(invoiceNumber: string): Promise<Invoice | null> {
    const result = await ddbDocClient.send(
      new QueryCommand({
        TableName: this.tableName,
        IndexName: 'GSI1',
        KeyConditionExpression: 'GSI1PK = :pk',
        ExpressionAttributeValues: {
          ':pk': `INVOICE_NUMBER#${invoiceNumber}`,
        },
        Limit: 1,
      })
    );

    if (!result.Items || result.Items.length === 0) {
      return null;
    }

    return this.fromDynamoDBItem(result.Items[0] as InvoiceDynamoDBItem);
  }

  /**
   * Get invoices by status with pagination
   */
  async findByStatus(
    status: string,
    limit: number = 10,
    lastEvaluatedKey?: any
  ): Promise<{ items: Invoice[]; lastEvaluatedKey?: any }> {
    const result = await ddbDocClient.send(
      new QueryCommand({
        TableName: this.tableName,
        IndexName: 'GSI2',
        KeyConditionExpression: 'GSI2PK = :pk',
        ExpressionAttributeValues: {
          ':pk': `STATUS#${status}`,
        },
        Limit: limit,
        ExclusiveStartKey: lastEvaluatedKey,
        ScanIndexForward: false, // Most recent first
      })
    );

    const items = (result.Items || []).map((item) =>
      this.fromDynamoDBItem(item as InvoiceDynamoDBItem)
    );

    return {
      items,
      lastEvaluatedKey: result.LastEvaluatedKey,
    };
  }

  /**
   * Get invoices by client email with pagination
   */
  async findByClientEmail(
    clientEmail: string,
    limit: number = 10,
    lastEvaluatedKey?: any
  ): Promise<{ items: Invoice[]; lastEvaluatedKey?: any }> {
    const result = await ddbDocClient.send(
      new QueryCommand({
        TableName: this.tableName,
        IndexName: 'GSI3',
        KeyConditionExpression: 'GSI3PK = :pk',
        ExpressionAttributeValues: {
          ':pk': `CLIENT_EMAIL#${clientEmail}`,
        },
        Limit: limit,
        ExclusiveStartKey: lastEvaluatedKey,
        ScanIndexForward: false, // Most recent first
      })
    );

    const items = (result.Items || []).map((item) =>
      this.fromDynamoDBItem(item as InvoiceDynamoDBItem)
    );

    return {
      items,
      lastEvaluatedKey: result.LastEvaluatedKey,
    };
  }

  /**
   * Scan all invoices with optional filtering
   */
  async findAll(
    limit: number = 10,
    lastEvaluatedKey?: any,
    filterExpression?: string,
    expressionAttributeValues?: any
  ): Promise<{ items: Invoice[]; lastEvaluatedKey?: any }> {
    const params: any = {
      TableName: this.tableName,
      FilterExpression: 'entityType = :entityType',
      ExpressionAttributeValues: {
        ':entityType': 'INVOICE',
        ...expressionAttributeValues,
      },
      Limit: limit,
      ExclusiveStartKey: lastEvaluatedKey,
    };

    if (filterExpression) {
      params.FilterExpression += ` AND ${filterExpression}`;
    }

    const result = await ddbDocClient.send(new ScanCommand(params));

    const items = (result.Items || []).map((item) =>
      this.fromDynamoDBItem(item as InvoiceDynamoDBItem)
    );

    return {
      items,
      lastEvaluatedKey: result.LastEvaluatedKey,
    };
  }

  /**
   * Update an invoice
   */
  async update(id: string, data: Partial<Invoice>): Promise<Invoice> {
    const now = new Date();
    const updateData = {
      ...data,
      updatedAt: now,
    };

    // Build update expression
    const updateExpressions: string[] = [];
    const expressionAttributeNames: any = {};
    const expressionAttributeValues: any = {};

    Object.keys(updateData).forEach((key, index) => {
      const value = (updateData as any)[key];
      if (value !== undefined) {
        const attrName = `#attr${index}`;
        const attrValue = `:val${index}`;
        updateExpressions.push(`${attrName} = ${attrValue}`);
        expressionAttributeNames[attrName] = key;

        // Convert dates to ISO strings
        if (value instanceof Date) {
          expressionAttributeValues[attrValue] = value.toISOString();
        } else if (key === 'items' && value) {
          expressionAttributeValues[attrValue] = JSON.stringify(value);
        } else {
          expressionAttributeValues[attrValue] = value;
        }
      }
    });

    // Update GSI keys if relevant fields changed
    if (data.status) {
      const statusAttrName = `#gsi2pk`;
      const statusAttrValue = `:gsi2pk`;
      updateExpressions.push(`${statusAttrName} = ${statusAttrValue}`);
      expressionAttributeNames[statusAttrName] = 'GSI2PK';
      expressionAttributeValues[statusAttrValue] = `STATUS#${data.status}`;
    }

    const result = await ddbDocClient.send(
      new UpdateCommand({
        TableName: this.tableName,
        Key: {
          PK: `INVOICE#${id}`,
          SK: `INVOICE#${id}`,
        },
        UpdateExpression: `SET ${updateExpressions.join(', ')}`,
        ExpressionAttributeNames: expressionAttributeNames,
        ExpressionAttributeValues: expressionAttributeValues,
        ReturnValues: 'ALL_NEW',
      })
    );

    return this.fromDynamoDBItem(result.Attributes as InvoiceDynamoDBItem);
  }

  /**
   * Delete an invoice
   */
  async delete(id: string): Promise<void> {
    await ddbDocClient.send(
      new DeleteCommand({
        TableName: this.tableName,
        Key: {
          PK: `INVOICE#${id}`,
          SK: `INVOICE#${id}`,
        },
      })
    );
  }

  /**
   * Count invoices (approximate)
   */
  async count(filterExpression?: string, expressionAttributeValues?: any): Promise<number> {
    const params: any = {
      TableName: this.tableName,
      Select: 'COUNT',
      FilterExpression: 'entityType = :entityType',
      ExpressionAttributeValues: {
        ':entityType': 'INVOICE',
        ...expressionAttributeValues,
      },
    };

    if (filterExpression) {
      params.FilterExpression += ` AND ${filterExpression}`;
    }

    const result = await ddbDocClient.send(new ScanCommand(params));
    return result.Count || 0;
  }

  /**
   * Check if invoice exists
   */
  async exists(id: string): Promise<boolean> {
    const invoice = await this.findById(id);
    return invoice !== null;
  }

  /**
   * Find invoices with invoice number starting with prefix
   */
  async findByInvoiceNumberPrefix(prefix: string): Promise<Invoice | null> {
    const result = await ddbDocClient.send(
      new QueryCommand({
        TableName: this.tableName,
        IndexName: 'GSI1',
        KeyConditionExpression: 'begins_with(GSI1PK, :prefix)',
        ExpressionAttributeValues: {
          ':prefix': `INVOICE_NUMBER#${prefix}`,
        },
        Limit: 1,
        ScanIndexForward: false, // Get the most recent one
      })
    );

    if (!result.Items || result.Items.length === 0) {
      return null;
    }

    return this.fromDynamoDBItem(result.Items[0] as InvoiceDynamoDBItem);
  }
}

export default new InvoiceRepository();
