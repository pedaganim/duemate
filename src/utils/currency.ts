/**
 * Currency symbol mapping for supported currencies
 */
export const CURRENCY_SYMBOLS: Record<string, string> = {
  AUD: 'A$',
  USD: '$',
  EUR: '€',
  GBP: '£',
  JPY: '¥',
  CAD: 'C$',
  CHF: 'CHF',
  CNY: '¥',
  SEK: 'kr',
  NZD: 'NZ$',
  MXN: 'MX$',
  SGD: 'S$',
  HKD: 'HK$',
  NOK: 'kr',
  KRW: '₩',
  TRY: '₺',
  RUB: '₽',
  INR: '₹',
  BRL: 'R$',
  ZAR: 'R',
};

/**
 * Get currency symbol for a given currency code
 * @param currencyCode - ISO currency code (e.g., 'USD', 'EUR')
 * @returns Currency symbol or the currency code if not found
 */
export function getCurrencySymbol(currencyCode: string): string {
  return CURRENCY_SYMBOLS[currencyCode.toUpperCase()] || currencyCode;
}

/**
 * Format amount with currency symbol
 * @param amount - Numeric amount
 * @param currencyCode - ISO currency code
 * @returns Formatted string with currency symbol and amount
 */
export function formatCurrency(amount: number, currencyCode: string): string {
  const symbol = getCurrencySymbol(currencyCode);
  return `${symbol}${amount.toFixed(2)}`;
}
