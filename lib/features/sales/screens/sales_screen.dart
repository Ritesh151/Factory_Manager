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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1200;
          final isTablet = constraints.maxWidth >= 800;
          
          return SingleChildScrollView(
            padding: EdgeInsets.all(
              isDesktop ? 32.0 : isTablet ? 24.0 : 16.0,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 1200 : double.infinity,
              ),
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
                  SizedBox(height: isDesktop ? 32.0 : 24.0),
                  
                  // Invoices list
                  Expanded(
                    child: StreamBuilder<List<SalesModel>>(
                      stream: _salesService.streamSales(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                const SizedBox(height: 16),
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

                        // Responsive grid for invoices
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
                            
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: _getChildAspectRatio(constraints.maxWidth),
                              ),
                              itemCount: sales.length,
                              itemBuilder: (context, index) {
                                final sale = sales[index];
                                return Card(
                                  elevation: 2,
                                  child: InkWell(
                                    onTap: () => _viewInvoice(sale),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Invoice number and status
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Invoice #${sale.invoiceNumber}',
                                                  style: theme.textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (sale.isLocked)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green.withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.lock, size: 14, color: Colors.green),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'Locked',
                                                        style: theme.textTheme.labelSmall?.copyWith(
                                                          color: Colors.green,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          
                                          // Customer info
                                          Text(
                                            sale.customerName,
                                            style: theme.textTheme.bodyMedium,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                          const SizedBox(height: 8),
                                          
                                          // Items and GST info
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${sale.totalQuantity} items',
                                                      style: theme.textTheme.bodySmall?.copyWith(
                                                        color: theme.colorScheme.outline,
                                                      ),
                                                    ),
                                                    Text(
                                                      'GST: ₹${sale.totalGst.toStringAsFixed(2)}',
                                                      style: theme.textTheme.bodySmall?.copyWith(
                                                        color: theme.colorScheme.outline,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                '${sale.createdAt.day}/${sale.createdAt.month}/${sale.createdAt.year}',
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color: theme.colorScheme.outline,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          
                                          // Amount
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Total Amount',
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color: theme.colorScheme.outline,
                                                ),
                                              ),
                                              Text(
                                                '₹${sale.finalAmount.toStringAsFixed(2)}',
                                                style: theme.textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: theme.colorScheme.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
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
        },
      ),
    );
  }

  int _getCrossAxisCount(double width) {
    if (width >= 1200) return 3;
    if (width >= 800) return 2;
    return 1;
  }

  double _getChildAspectRatio(double width) {
    if (width >= 1200) return 1.4;
    if (width >= 800) return 1.3;
    return 1.2;
  }
}
