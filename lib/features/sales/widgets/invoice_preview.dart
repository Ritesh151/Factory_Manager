import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/sales_model.dart';

/// Preview and print dialog for GST invoice
class InvoicePreview extends StatelessWidget {
  final SalesModel sale;

  const InvoicePreview({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 800,
          maxHeight: size.height * 0.9,
        ),
        child: Scaffold(
          appBar: AppBar(
            title: Text('Invoice #${sale.invoiceNumber}'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.copy),
                tooltip: 'Copy invoice data',
                onPressed: () => _copyInvoiceData(context),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TAX INVOICE',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Invoice #: ${sale.invoiceNumber}',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Date: ${sale.createdAt.day}/${sale.createdAt.month}/${sale.createdAt.year}',
                            style: theme.textTheme.bodyMedium,
                          ),
                          if (sale.isLocked)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.green),
                              ),
                              child: const Text(
                                'LOCKED',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  
                  // Company and Customer details
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Company details (static)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'From:',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            Text(
                              'SmartERP Solutions',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text('GSTIN: 22AAAAA0000A1Z5'),
                            const Text('PAN: AAACA0000A'),
                          ],
                        ),
                      ),
                      // Customer details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bill To:',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            Text(
                              sale.customerName,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (sale.customerPhone != null)
                              Text('Phone: ${sale.customerPhone}'),
                            if (sale.customerGstin != null)
                              Text('GSTIN: ${sale.customerGstin}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  
                  // Items table
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outline),
                    ),
                    child: Column(
                      children: [
                        // Table header
                        Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              Expanded(flex: 1, child: Text('#', style: theme.textTheme.labelSmall)),
                              Expanded(flex: 4, child: Text('Description', style: theme.textTheme.labelSmall)),
                              Expanded(flex: 2, child: Text('HSN', style: theme.textTheme.labelSmall)),
                              Expanded(flex: 1, child: Text('Qty', style: theme.textTheme.labelSmall)),
                              Expanded(flex: 2, child: Text('Rate', style: theme.textTheme.labelSmall)),
                              Expanded(flex: 2, child: Text('Amount', style: theme.textTheme.labelSmall)),
                            ],
                          ),
                        ),
                        // Table rows
                        ...sale.items.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return Container(
                            decoration: BoxDecoration(
                              border: index < sale.items.length - 1 
                                  ? Border(bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)))
                                  : null,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                Expanded(flex: 1, child: Text('${index + 1}', style: theme.textTheme.bodySmall)),
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.productName, style: theme.textTheme.bodySmall),
                                      Text(
                                        'GST ${item.gstPercentage}%',
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: theme.colorScheme.outline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(flex: 2, child: Text(item.hsnCode.isEmpty ? '-' : item.hsnCode, style: theme.textTheme.bodySmall)),
                                Expanded(flex: 1, child: Text('${item.quantity}', style: theme.textTheme.bodySmall)),
                                Expanded(flex: 2, child: Text('₹${item.price.toStringAsFixed(2)}', style: theme.textTheme.bodySmall)),
                                Expanded(flex: 2, child: Text('₹${item.amount.toStringAsFixed(2)}', style: theme.textTheme.bodySmall)),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Totals
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildSummaryRow('Subtotal:', sale.subtotal, theme),
                          _buildSummaryRow('CGST:', sale.totalCgst, theme),
                          _buildSummaryRow('SGST:', sale.totalSgst, theme),
                          if (sale.extraCharges > 0)
                            _buildSummaryRow('Extra Charges:', sale.extraCharges, theme),
                          if (sale.roundOff != 0)
                            _buildSummaryRow('Round Off:', sale.roundOff, theme),
                          const Divider(),
                          _buildSummaryRow('Total:', sale.finalAmount, theme, isBold: true),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Amount in words
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Amount in Words: ${sale.amountInWords}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Footer
                  Center(
                    child: Text(
                      'Thank you for your business!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(top: BorderSide(color: theme.colorScheme.outline)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _copyInvoiceData(context),
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy'),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.check),
                  label: const Text('Done'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, ThemeData theme, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            label,
            style: isBold ? theme.textTheme.titleSmall : theme.textTheme.bodyMedium,
          ),
          const SizedBox(width: 24),
          SizedBox(
            width: 120,
            child: Text(
              '₹${value.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: isBold 
                  ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                  : theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _copyInvoiceData(BuildContext context) {
    final data = '''
Invoice #: ${sale.invoiceNumber}
Date: ${sale.createdAt.day}/${sale.createdAt.month}/${sale.createdAt.year}
Customer: ${sale.customerName}
Total: ₹${sale.finalAmount.toStringAsFixed(2)}
'''.trim();
    
    Clipboard.setData(ClipboardData(text: data));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invoice data copied to clipboard')),
    );
  }
}
