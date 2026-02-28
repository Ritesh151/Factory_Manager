import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/firebase_service.dart';
import '../../../shared/widgets/section_header.dart';
import '../../products/repositories/product_repository.dart';
import '../models/sales_model.dart';
import '../repositories/sales_repository.dart';
import '../widgets/invoice_form_fixed.dart';
import '../widgets/invoice_preview.dart';

/// Enhanced Sales screen with repository pattern and proper dropdown handling
class SalesScreenFixed extends ConsumerStatefulWidget {
  const SalesScreenFixed({super.key});

  @override
  ConsumerState<SalesScreenFixed> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreenFixed> {
  late final SalesRepository _salesRepository;
  late final ProductRepository _productRepository;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeRepositories();
  }

  Future<void> _initializeRepositories() async {
    try {
      final firebaseService = FirebaseService();
      await firebaseService.initialize();
      
      _salesRepository = SalesRepository();
      _salesRepository.initialize(firebaseService);
      
      _productRepository = ProductRepository();
      _productRepository.initialize(firebaseService);
      
      setState(() {
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      debugPrint('SalesScreen: Repository initialization failed: $e');
    }
  }

  Future<void> _createInvoice() async {
    if (_errorMessage != null) {
      _showSnackBar('Cannot create invoices in offline mode', isError: true);
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => InvoiceForm(
        salesRepository: _salesRepository,
        productRepository: _productRepository,
      ),
    );

    if (result != null && mounted) {
      _showSnackBar('Invoice created successfully', isError: false);
    }
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
                const SectionHeader(title: 'Sales'),
                FilledButton.icon(
                  onPressed: _errorMessage == null ? _createInvoice : null,
                  icon: const Icon(Icons.add),
                  label: const Text('New Invoice'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Firebase status banner
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Offline Mode',
                            style: TextStyle(
                              color: theme.colorScheme.onErrorContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Firebase not available. Running in offline mode.',
                            style: TextStyle(
                              color: theme.colorScheme.onErrorContainer,
                              fontSize: 12,
                            ),
                          ),
                          if (_errorMessage != null)
                            Text(
                              'Error: $_errorMessage',
                              style: TextStyle(
                                color: theme.colorScheme.onErrorContainer,
                                fontSize: 10,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _initializeRepositories,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ],
                ),
              ),
            
            // Sales content
            Expanded(
              child: _errorMessage != null
                  ? _buildOfflinePlaceholder(theme)
                  : _buildSalesList(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesList(ThemeData theme) {
    return StreamBuilder<List<SalesModel>>(
      stream: _salesRepository.streamAllSales(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading sales from Firestore...'),
              ],
            ),
          );
        }

        // Error state
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text('Error loading sales: ${snapshot.error}'),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => setState(() {}),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final sales = snapshot.data ?? [];

        // Empty state
        if (sales.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 80, color: theme.colorScheme.outline),
                const SizedBox(height: 16),
                Text(
                  'No sales found',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your first invoice to get started',
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

        // Sales list
        return Expanded(
          child: ListView.builder(
            itemCount: sales.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final sale = sales[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Invoice #${sale.invoiceNumber}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              sale.customerName,
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${sale.totalAmount.toStringAsFixed(2)}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatDate(sale.createdAt),
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(sale.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              sale.status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.visibility),
                    onPressed: () => _showInvoicePreview(sale),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildOfflinePlaceholder(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, size: 80, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            'Sales Offline',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Firebase is not available on this device.\nSales features are disabled in offline mode.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _initializeRepositories,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry Connection'),
          ),
        ],
      ),
    );
  }

  void _showInvoicePreview(SalesModel sale) {
    showDialog(
      context: context,
      builder: (context) => InvoicePreview(sale: sale),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
