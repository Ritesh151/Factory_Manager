import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/firebase_service.dart';
import '../../../shared/widgets/section_header.dart';
import '../../products/services/product_service.dart';
import '../models/sales_model.dart';
import '../services/sales_service.dart';
import '../widgets/invoice_form.dart';
import '../widgets/invoice_preview.dart';

/// Sales screen with GST invoice creation
class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});

  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> {
  late final SalesService _salesService;
  late final ProductService _productService;

  @override
  void initState() {
    super.initState();
    final firebaseService = FirebaseService();
    _salesService = SalesService();
    _salesService.initialize(firebaseService);
    _productService = ProductService();
    _productService.initialize(firebaseService);
  }

  Future<void> _createInvoice() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => InvoiceForm(
        productService: _productService,
      ),
    );

    if (result != null && mounted) {
      try {
        await _salesService.createSale(
          customerName: result['customerName'],
          customerPhone: result['customerPhone'],
          customerGstin: result['customerGstin'],
          items: (result['items'] as List<InvoiceItem>),
          extraCharges: result['extraCharges'] ?? 0.0,
        );
        _showSnackBar('Invoice created successfully', isError: false);
      } catch (e) {
        _showSnackBar('Failed to create invoice: $e', isError: true);
      }
    }
  }

  Future<void> _viewInvoice(SalesModel sale) async {
    await showDialog(
      context: context,
      builder: (context) => InvoicePreview(sale: sale),
    );
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SectionHeader(title: 'Sales / GST Invoices'),
                FilledButton.icon(
                  onPressed: _createInvoice,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Invoice'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Invoices list
            Expanded(
              child: StreamBuilder<List<SalesModel>>(
                stream: _salesService.streamSales(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading invoices...'),
                        ],
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
                          const SizedBox(height: 16),
                          Text('Error: ${snapshot.error}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => setState(() {}),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final sales = snapshot.data ?? [];

                  if (sales.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 80, color: theme.colorScheme.outline),
                          const SizedBox(height: 16),
                          Text(
                            'No invoices yet',
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create your first GST invoice',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: _createInvoice,
                            icon: const Icon(Icons.add),
                            label: const Text('Create Invoice'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: sales.length,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, index) {
                      final sale = sales[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Text(
                              sale.invoiceNumber.split('/').first,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          title: Text(
                            'Invoice #${sale.invoiceNumber}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(sale.customerName),
                              Text(
                                '${sale.totalQuantity} items • GST: ₹${sale.totalGst.toStringAsFixed(2)}',
                                style: theme.textTheme.bodySmall,
                              ),
                              Text(
                                '${sale.createdAt.day}/${sale.createdAt.month}/${sale.createdAt.year}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '₹${sale.finalAmount.toStringAsFixed(2)}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              if (sale.isLocked)
                                Icon(Icons.lock, size: 16, color: theme.colorScheme.outline),
                            ],
                          ),
                          onTap: () => _viewInvoice(sale),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
