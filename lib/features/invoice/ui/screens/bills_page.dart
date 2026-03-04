import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/modern_theme.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/utils/gst_utils.dart';
import '../../providers/gst_invoice_provider.dart';
import '../../models/invoice_model.dart';
import '../../../../core/services/pdf_service.dart';
import 'package:printing/printing.dart';

class BillsPage extends ConsumerWidget {
  const BillsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(allInvoicesProvider);

    return Padding(
      padding: const EdgeInsets.all(ModernTheme.lg),
      child: Column(
        children: [
          _buildHeader(context, invoicesAsync.value?.length ?? 0),
          const SizedBox(height: ModernTheme.lg),
          Expanded(
            child: invoicesAsync.when(
              data: (invoices) => invoices.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.receipt_long_outlined,
                      title: 'No Invoices Yet',
                      subtitle: 'Create your first GST invoice to see it here.',
                      buttonLabel: 'Create Invoice',
                    )
                  : _buildInvoiceTable(context, invoices),
              loading: () => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(strokeWidth: 2, color: ModernTheme.primary),
                    SizedBox(height: 16),
                    Text('Connecting to database...', style: ModernTheme.bodySmall),
                  ],
                ),
              ),
              error: (e, _) => Center(
                child: Container(
                  padding: const EdgeInsets.all(ModernTheme.xl),
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: ModernTheme.surface,
                    borderRadius: BorderRadius.circular(ModernTheme.radiusLarge),
                    border: Border.all(color: ModernTheme.border),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off_rounded, size: 48, color: ModernTheme.secondary),
                      const SizedBox(height: 16),
                      Text('Database Connection Issue', style: ModernTheme.headingSmall),
                      const SizedBox(height: 8),
                      const Text(
                        'We are having trouble connecting to the live database. You can still create invoices in offline mode.',
                        textAlign: TextAlign.center,
                        style: ModernTheme.bodySmall,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                            onPressed: () => ref.refresh(allInvoicesProvider),
                            style: ModernTheme.outlinedButtonStyle,
                            child: const Text('Retry Connection'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () => context.go('/create-invoice'),
                            style: ModernTheme.elevatedButtonStyle,
                            child: const Text('Create Offline'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bills & Invoices', style: ModernTheme.headingMedium),
            Text('Total Bills: $count', style: ModernTheme.bodyMedium.copyWith(color: ModernTheme.textMuted)),
          ],
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => context.go('/create-invoice'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New Invoice'),
              style: ModernTheme.elevatedButtonStyle,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInvoiceTable(BuildContext context, List<InvoiceModel> invoices) {
    return Container(
      decoration: BoxDecoration(
        color: ModernTheme.surface,
        borderRadius: BorderRadius.circular(ModernTheme.radiusLarge),
        border: Border.all(color: ModernTheme.border),
        boxShadow: ModernTheme.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ModernTheme.radiusLarge),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(ModernTheme.background),
            columns: const [
              DataColumn(label: Text('Invoice No', style: ModernTheme.labelSmall)),
              DataColumn(label: Text('Date', style: ModernTheme.labelSmall)),
              DataColumn(label: Text('Customer', style: ModernTheme.labelSmall)),
              DataColumn(label: Text('Type', style: ModernTheme.labelSmall)),
              DataColumn(label: Text('Amount', style: ModernTheme.labelSmall)),
              DataColumn(label: Text('Actions', style: ModernTheme.labelSmall)),
            ],
            rows: invoices.map((InvoiceModel invoice) {
              final isIntra = GSTUtils.isIntrastate(invoice.customerState);
              return DataRow(cells: [
                DataCell(Text(invoice.invoiceNo, style: ModernTheme.labelMedium)),
                DataCell(Text(invoice.date.toString().substring(0, 10), style: ModernTheme.bodySmall)),
                DataCell(Text(invoice.customerName, style: ModernTheme.bodyMedium)),
                DataCell(Text(isIntra ? 'Intrastate' : 'Interstate', style: ModernTheme.bodySmall)),
                DataCell(Text(GSTUtils.formatCurrency(invoice.grandTotal), style: ModernTheme.labelMedium.copyWith(color: ModernTheme.primary))),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 18, color: ModernTheme.primary),
                    onPressed: () async {
                      final pdfData = await PDFService.generateGSTInvoice(invoice);
                      await Printing.layoutPdf(onLayout: (format) => pdfData);
                    },
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}
