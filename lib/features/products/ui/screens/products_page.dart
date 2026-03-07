import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/modern_theme.dart';
import '../../providers/product_providers.dart';
import '../../widgets/product_dialog.dart';
import '../../services/product_service.dart';

class ModernProductsPage extends ConsumerStatefulWidget {
  const ModernProductsPage({super.key});

  @override
  ConsumerState<ModernProductsPage> createState() => _ModernProductsPageState();
}

class _ModernProductsPageState extends ConsumerState<ModernProductsPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsStreamProvider);
    
    return Padding(
      padding: const EdgeInsets.all(ModernTheme.lg),
      child: Column(
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: ModernTheme.md),
                  decoration: BoxDecoration(
                    color: ModernTheme.surface,
                    borderRadius: BorderRadius.circular(ModernTheme.radiusMedium),
                    border: Border.all(color: ModernTheme.border),
                    boxShadow: ModernTheme.cardShadow,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, size: 18, color: ModernTheme.textMuted),
                      const SizedBox(width: ModernTheme.sm),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search products...',
                            hintStyle: TextStyle(color: ModernTheme.textMuted, fontSize: 14),
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value.toLowerCase();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: ModernTheme.md),
              SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddProductDialog(),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Product'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ModernTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: ModernTheme.lg),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ModernTheme.radiusMedium),
                    ),
                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: ModernTheme.lg),

          // ── Content Area ─────────────────────────────────────────────────
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading products',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              data: (products) {
                final filteredProducts = products.where((product) {
                  return product.name.toLowerCase().contains(_searchQuery) ||
                         (product.description?.toLowerCase().contains(_searchQuery) ?? false);
                }).toList();

                if (filteredProducts.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: ModernTheme.textMuted),
                        SizedBox(height: 16),
                        Text(
                          'No Products Yet',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: ModernTheme.textMuted),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Start by adding your first product to the catalogue.',
                          style: TextStyle(color: ModernTheme.textMuted),
                        ),
                      ],
                    ),
                  );
                }

                return _buildProductsList(filteredProducts);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(List<dynamic> products) {
    return Container(
      decoration: BoxDecoration(
        color: ModernTheme.surface,
        borderRadius: BorderRadius.circular(ModernTheme.radiusLarge),
        border: Border.all(color: ModernTheme.border),
        boxShadow: ModernTheme.cardShadow,
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(ModernTheme.md),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return _buildProductCard(product);
        },
      ),
    );
  }

  Widget _buildProductCard(dynamic product) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    
    return Container(
      margin: const EdgeInsets.only(bottom: ModernTheme.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ModernTheme.radiusMedium),
        border: Border.all(color: ModernTheme.border),
        boxShadow: ModernTheme.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(ModernTheme.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Product Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: ModernTheme.surface,
                    borderRadius: BorderRadius.circular(ModernTheme.radiusSmall),
                    border: Border.all(color: ModernTheme.border),
                  ),
                  child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(ModernTheme.radiusSmall),
                          child: Image.network(
                            product.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.image, color: ModernTheme.textMuted);
                            },
                          ),
                        )
                      : const Icon(Icons.inventory, color: ModernTheme.textMuted),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name ?? 'Unnamed Product',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (product.description != null && product.description!.isNotEmpty)
                        Text(
                          product.description!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: ModernTheme.textMuted,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                // Stock Status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStockColor(product.stock ?? 0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Stock: ${product.stock ?? 0}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Details Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currencyFormat.format(product.price ?? 0.0),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: ModernTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'GST: ${product.gstPercentage ?? 18}%',
                        style: const TextStyle(
                          fontSize: 12,
                          color: ModernTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (product.discount != null && product.discount! > 0)
                      Text(
                        '${product.discount}% off',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      'HSN: ${product.hsnCode ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: ModernTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Actions Row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _viewProductDetails(product),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _editProduct(product),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _deleteProduct(product),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStockColor(int stock) {
    if (stock == 0) return Colors.red;
    if (stock < 10) return Colors.orange;
    return Colors.green;
  }

  void _showAddProductDialog() {
    final productService = ref.read(productServiceProvider);
    showDialog(
      context: context,
      builder: (context) => ProductDialog(
        productService: productService,
      ),
    );
  }

  void _viewProductDetails(dynamic product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing product: ${product.name ?? 'Unnamed'}')),
    );
  }

  void _editProduct(dynamic product) {
    final productService = ref.read(productServiceProvider);
    showDialog(
      context: context,
      builder: (context) => ProductDialog(
        product: product,
        productService: productService,
      ),
    );
  }

  void _deleteProduct(dynamic product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete product ${product.name ?? 'this product'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref.read(productServiceProvider).deleteProduct(product.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Product deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting product: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
