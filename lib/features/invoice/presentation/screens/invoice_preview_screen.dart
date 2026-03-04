import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../entities/invoice_entity.dart';
import '../providers/invoice_provider.dart';

/// Professional Invoice Preview & Export Screen
class InvoicePreviewScreen extends ConsumerWidget {
  final InvoiceEntity invoice;

  const InvoicePreviewScreen({
    super.key,
    required this.invoice,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExporting = ref.watch(invoiceGenerationProvider).isExporting;

    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice ${invoice.invoiceNumber}'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: isExporting ? null : () => _downloadPdf(context, ref),
              icon: isExporting
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(
                          Colors.white,
                        ),
                      ),
                    )
                  : const Icon(Icons.file_download_rounded),
              label: Text(isExporting ? 'Exporting...' : 'Download PDF'),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowSoft,
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with logo and invoice info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.secondary
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.business,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        invoice.companyName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'INVOICE',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        invoice.invoiceNumber,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const Divider(height: 40),

              // Company and Customer Info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoLabel('FROM'),
                        const SizedBox(height: 12),
                        _InfoValue(invoice.companyName),
                        _InfoValue(invoice.companyAddress),
                        _InfoValue('Phone: ${invoice.companyPhone}'),
                        _InfoValue('Email: ${invoice.companyEmail}'),
                        _InfoValue('GST: ${invoice.companyGst}'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoLabel('BILL TO'),
                        const SizedBox(height: 12),
                        _InfoValue(invoice.customerVendorName),
                        _InfoValue(invoice.customerVendorAddress),
                        _InfoValue('GST: ${invoice.customerVendorGst}'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _InfoLabel('INVOICE DETAILS'),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text('Invoice Date: '),
                            Text(
                              DateFormat('dd MMM yyyy')
                                  .format(invoice.invoiceDate),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text('Bill No: '),
                            Text(
                              invoice.billNo,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Items Table
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderLight),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    // Table Header
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _TableHeader('Description'),
                          ),
                          Expanded(
                            flex: 1,
                            child: _TableHeader('Qty', alignment: TextAlign.center),
                          ),
                          Expanded(
                            flex: 1,
                            child: _TableHeader('Unit Price', alignment: TextAlign.right),
                          ),
                          Expanded(
                            flex: 1,
                            child: _TableHeader('Amount', alignment: TextAlign.right),
                          ),
                        ],
                      ),
                    ),
                    // Table Content
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  invoice.productName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                if (invoice.productDescription.isNotEmpty)
                                  Text(
                                    invoice.productDescription,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMedium,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              invoice.quantity.toStringAsFixed(0),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.textDark),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              '₹${invoice.unitPrice.toStringAsFixed(2)}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(color: AppColors.textDark),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              '₹${invoice.subtotal.toStringAsFixed(2)}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Summary Section
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 2,
                    child: const SizedBox(),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderLight),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _SummaryRow(
                            'Subtotal',
                            '₹${invoice.subtotal.toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: 8),
                          _SummaryRow(
                            'GST (${invoice.gstRate}%)',
                            '₹${invoice.gstAmount.toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: 8),
                          _SummaryRow(
                            'Transport',
                            '₹${invoice.transportCharges.toStringAsFixed(2)}',
                          ),
                          const Divider(height: 16),
                          _SummaryRow(
                            'Grand Total',
                            '₹${invoice.grandTotal.toStringAsFixed(2)}',
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
                const SizedBox(height: 32),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoLabel('NOTES'),
                    const SizedBox(height: 8),
                    Text(
                      invoice.notes!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 40),

              // Footer
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.borderLight),
                  ),
                ),
                paddingTop: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Method',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMedium,
                          ),
                        ),
                        Text(
                          invoice.paymentMethod,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Thank you for your business!',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMedium,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Generated on ${DateFormat('dd MMM yyyy hh:mm a').format(invoice.createdAt)}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadPdf(BuildContext context, WidgetRef ref) async {
    // In production, implement actual PDF download
    // This would use packages like `dart:io` for file handling
    // and `pdf` package for PDF generation
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF export feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _InfoLabel extends StatelessWidget {
  final String text;

  const _InfoLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textMedium,
        letterSpacing: 1,
      ),
    );
  }
}

class _InfoValue extends StatelessWidget {
  final String text;

  const _InfoValue(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textDark,
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String text;
  final TextAlign alignment;

  const _TableHeader(
    this.text, {
    this.alignment = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: alignment,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _SummaryRow(
    this.label,
    this.value, {
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 14 : 12,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
            color: isBold ? AppColors.primary : AppColors.textMedium,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 14 : 12,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: isBold ? AppColors.primary : AppColors.textDark,
          ),
        ),
      ],
    );
  }
}

extension on Padding {
  Padding get paddingTop => this;
}
