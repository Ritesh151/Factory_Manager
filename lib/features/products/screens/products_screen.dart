import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/firebase_service.dart';
import '../../../shared/widgets/section_header.dart';
import '../../products/models/product_model.dart';
import '../../products/services/product_service.dart';
import '../widgets/product_dialog.dart';
import '../widgets/product_tile.dart';

/// Enhanced Products screen with permanent Firestore storage
class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  late final ProductService _productService;

  @override
  void initState() {
    super.initState();
    final firebaseService = FirebaseService();
    _productService = ProductService();
    _productService.initialize(firebaseService);
  }

  Future<void> _addProduct() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ProductDialog(
        productService: _productService,
      ),
    );

    if (result != null && mounted) {
      try {
        await _productService.createProduct(
          name: result['name'],
          price: result['price'],
          discount: result['discount'],
          gstPercentage: result['gstPercentage'],
          hsnCode: result['hsnCode'],
          stock: result['stock'],
          imageUrl: result['imageUrl'],
          description: result['description'],
        );
        _showSnackBar('Product added successfully', isError: false);
      } catch (e) {
        _showSnackBar('Failed to add product: $e', isError: true);
      }
    }
  }

  Future<void> _editProduct(ProductModel product) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ProductDialog(
        productService: _productService,
        product: product,
      ),
    );

    if (result != null && mounted) {
      try {
        await _productService.updateProduct(
          id: product.id,
          name: result['name'],
          price: result['price'],
          discount: result['discount'],
          gstPercentage: result['gstPercentage'],
          hsnCode: result['hsnCode'],
          stock: result['stock'],
          imageUrl: result['imageUrl'],
          description: result['description'],
        );
        _showSnackBar('Product updated successfully', isError: false);
      } catch (e) {
        _showSnackBar('Failed to update product: $e', isError: true);
      }
    }
  }

  Future<void> _deleteProduct(ProductModel product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _productService.deleteProduct(product.id);
        _showSnackBar('Product deleted successfully', isError: false);
      } catch (e) {
        _showSnackBar('Failed to delete product: $e', isError: true);
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
                const SectionHeader(title: 'Products'),
                FilledButton.icon(
                  onPressed: _addProduct,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Product'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Auto-loading products from Firestore
            Expanded(
              child: StreamBuilder<List<ProductModel>>(
                stream: _productService.streamProducts(),
                builder: (context, snapshot) {
                  // Loading state
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading products from Firestore...'),
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
                          Text('Error loading products: ${snapshot.error}'),
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

                  final products = snapshot.data ?? [];

                  // Empty state
                  if (products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 80, color: theme.colorScheme.outline),
                          const SizedBox(height: 16),
                          Text(
                            'No products found',
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first product to get started',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: _addProduct,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Product'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Products list
                  return Column(
                    children: [
                      // Low stock banner
                      StreamBuilder<List<ProductModel>>(
                        stream: _productService.streamLowStockProducts(),
                        builder: (context, lowStockSnapshot) {
                          final lowStockProducts = lowStockSnapshot.data ?? [];
                          if (lowStockProducts.isNotEmpty) {
                            return Container(
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
                                    child: Text(
                                      '${lowStockProducts.length} product(s) running low on stock',
                                      style: TextStyle(color: theme.colorScheme.onErrorContainer),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      
                      // Product grid/list
                      Expanded(
                        child: ListView.builder(
                          itemCount: products.length,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return ProductTile(
                              product: product,
                              onEdit: () => _editProduct(product),
                              onDelete: () => _deleteProduct(product),
                            );
                          },
                        ),
                      ),
                    ],
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
