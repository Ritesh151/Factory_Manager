import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/services/firebase_service.dart';
import '../../../shared/widgets/section_header.dart';
import '../../products/models/product_model.dart';
import '../../products/services/product_service.dart';
import '../models/purchase_model.dart';
import '../services/purchase_service.dart';
import '../widgets/purchase_form.dart';

/// Purchase screen for supplier purchases
class PurchaseScreen extends ConsumerStatefulWidget {
  const PurchaseScreen({super.key});

  @override
  ConsumerState<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends ConsumerState<PurchaseScreen> {
  late final PurchaseService _purchaseService;
  late final ProductService _productService;

  @override
  void initState() {
    super.initState();
    final firebaseService = FirebaseService();
    _purchaseService = PurchaseService();
    _purchaseService.initialize(firebaseService);
    _productService = ProductService();
    _productService.initialize(firebaseService);
  }

  Future<void> _createPurchase() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => PurchaseForm(
        productService: _productService,
      ),
    );

    if (result != null && mounted) {
      try {
        await _purchaseService.createPurchase(
          supplierName: result['supplierName'],
          supplierContact: result['supplierContact'],
          items: (result['items'] as List<PurchaseItem>),
          purchaseDate: result['purchaseDate'],
          notes: result['notes'],
        );
        _showSnackBar('Purchase recorded successfully', isError: false);
      } catch (e) {
        _showSnackBar('Failed to record purchase: $e', isError: true);
      }
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
                const SectionHeader(title: 'Purchases'),
                FilledButton.icon(
                  onPressed: _createPurchase,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Purchase'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Purchases list
            Expanded(
              child: StreamBuilder<List<PurchaseModel>>(
                stream: _purchaseService.streamPurchases(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading purchases...'),
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
                        ],
                      ),
                    );
                  }

                  final purchases = snapshot.data ?? [];

                  if (purchases.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart_outlined, size: 80, color: theme.colorScheme.outline),
                          const SizedBox(height: 16),
                          Text(
                            'No purchases yet',
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first supplier purchase',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: _createPurchase,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Purchase'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: purchases.length,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, index) {
                      final purchase = purchases[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.tertiaryContainer,
                            child: Icon(Icons.shopping_bag, color: theme.colorScheme.onTertiaryContainer),
                          ),
                          title: Text(
                            purchase.supplierName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            DateFormat('dd/MM/yyyy').format(purchase.purchaseDate),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          trailing: Text(
                            '₹${purchase.totalAmount.toStringAsFixed(2)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.tertiary,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (purchase.supplierContact != null)
                                    Text('Contact: ${purchase.supplierContact}'),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Items:',
                                    style: theme.textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 8),
                                  ...purchase.items.map((item) => ListTile(
                                    dense: true,
                                    title: Text(item.productName),
                                    subtitle: Text('${item.quantity} × ₹${item.purchasePrice.toStringAsFixed(2)}'),
                                    trailing: Text('₹${item.total.toStringAsFixed(2)}'),
                                  )),
                                  if (purchase.notes != null) ...[
                                    const Divider(),
                                    Text('Notes: ${purchase.notes}'),
                                  ],
                                ],
                              ),
                            ),
                          ],
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
