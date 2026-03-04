import 'package:flutter/material.dart';
import '../../../../core/layout/app_layout.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/theme/app_colors.dart';

class InvoicePreviewScreen extends StatelessWidget {
  final String invoiceNumber;
  const InvoicePreviewScreen({super.key, required this.invoiceNumber});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Invoice Preview',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Invoice Preview'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: AppColors.surfaceGlass, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Acme Corporation', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                              const SizedBox(height: 4),
                              Text('123 Business Road, City', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Invoice #$invoiceNumber', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                              const SizedBox(height: 6),
                              const StatusBadge(label: 'Pending', color: AppColors.warning)
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Colors.white12),
                      const SizedBox(height: 12),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Bill To', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white70)),
                              const SizedBox(height: 8),
                              Text('Client Name\nClient Address', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
                              const SizedBox(height: 16),
                              _buildInvoiceTable(context),
                              const SizedBox(height: 16),
                              Text('Notes', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white70)),
                              const SizedBox(height: 8),
                              Text('Thank you for your business.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.print), label: const Text('Export PDF')),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.check_circle), label: const Text('Mark as Paid')),
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInvoiceTable(BuildContext context) {
    return Table(
      columnWidths: const {0: FlexColumnWidth(4), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1)},
      children: [
        TableRow(children: [
          Text('Description', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70)),
          Text('Qty', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70)),
          Text('Total', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70)),
        ]),
        const TableRow(children: [
          SizedBox(height: 8), SizedBox(), SizedBox(),
        ]),
        TableRow(children: [Text('Product A', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)), Text('2', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)), Text('\$200', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white))]),
        TableRow(children: [Text('Product B', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)), Text('1', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)), Text('\$150', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white))]),
        const TableRow(children: [SizedBox(height: 8), SizedBox(), SizedBox()]),
        TableRow(children: [Text('Subtotal', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)), SizedBox(), Text('\$350', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white))]),
        TableRow(children: [Text('Tax', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)), SizedBox(), Text('\$35', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white))]),
        TableRow(children: [Text('Total', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)), SizedBox(), Text('\$385', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white))]),
      ],
    );
  }
}
