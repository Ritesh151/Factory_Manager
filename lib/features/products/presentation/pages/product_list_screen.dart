import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/layout/app_layout.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/data_grid.dart';
import '../../domain/entities/product_entity.dart';
import '../providers/product_providers.dart';
import '../widgets/product_grid.dart';
import 'product_detail_screen.dart';

/// Product list screen with real-time updates, search, and filter
/// Automatically updates when Firestore data changes
class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  late TextEditingController _searchController;
  String _filterType = 'All';
  String _sortType = 'Name';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filtered and sorted products
  List<ProductEntity> _processProducts(List<ProductEntity> products) {
    var result = products;

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      result = result
          .where((p) => p.name
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()) ||
          p.sku.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    }

    // Apply stock filter
    if (_filterType == 'Low Stock') {
      result = result.where((p) => p.quantity < 10).toList();
    } else if (_filterType == 'Out of Stock') {
      result = result.where((p) => p.quantity == 0).toList();
    }

    // Apply sorting
    switch (_sortType) {
      case 'Price: Low to High':
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Stock':
        result.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case 'Name':
      default:
        result.sort((a, b) => a.name.compareTo(b.name));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final productsAsyncValue = ref.watch(allProductsStreamProvider);
    final body = productsAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => _buildErrorState(context, error),
      data: (products) => _buildProductsView(context, products),
    );

    return AppLayout(
      title: 'Products',
      child: Stack(
        children: [
          Positioned.fill(child: body),
          Positioned(
            right: 24,
            bottom: 24,
            child: FloatingActionButton(
              onPressed: () => _showAddEditDialog(context),
              tooltip: 'Add Product',
              child: const Icon(Icons.add_rounded),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading products',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => ref.refresh(allProductsStreamProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsView(
    BuildContext context,
    List<ProductEntity> products,
  ) {
    final processedProducts = _processProducts(products);
    final isEmpty = processedProducts.isEmpty && _searchController.text.isEmpty;

    return Column(
      children: [
        // Search and filter bar
        _buildSearchFilterBar(context, products.length),
        // Products grid or empty state
        Expanded(
          child: isEmpty
              ? _buildEmptyState(context)
              : processedProducts.isEmpty
                  ? _buildNoResultsState(context)
                  : ProductGrid(
                      products: processedProducts,
                      onProductTap: (product) => _navigateToDetail(product),
                      onEdit: (product) => _editProduct(product),
                      onDelete: (product) => _deleteProduct(product),
                    ),
        ),
      ],
    );
  }

  Widget _buildSearchFilterBar(BuildContext context, int totalProducts) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search field
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search by name or SKU...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
            ),
          ),
          const SizedBox(height: 12),
          // Filter and sort dropdowns
          Row(
            children: [
              // Filter dropdown
              Expanded(
                child: _buildDropdown(
                  value: _filterType,
                  items: const ['All', 'Low Stock', 'Out of Stock'],
                  onChanged: (value) => setState(() => _filterType = value!),
                  label: 'Filter',
                ),
              ),
              const SizedBox(width: 12),
              // Sort dropdown
              Expanded(
                child: _buildDropdown(
                  value: _sortType,
                  items: const [
                    'Name',
                    'Price: Low to High',
                    'Price: High to Low',
                    'Stock',
                  ],
                  onChanged: (value) => setState(() => _sortType = value!),
                  label: 'Sort',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Results counter
          Text(
            'Showing ${_processProducts(ref.watch(allProductsStreamProvider).maybeWhen(
              data: (d) => d,
              orElse: () => [],
            )).length} of $totalProducts products',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required String label,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No Products',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Create your first product to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddEditDialog(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Product'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No Results Found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Try adjusting your search or filter criteria',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {
              _searchController.clear();
              setState(() => _filterType = 'All');
            },
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(ProductEntity product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }

  void _editProduct(ProductEntity product) {
    _showAddEditDialog(context, existing: product);
  }

  void _deleteProduct(ProductEntity product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performDelete(product);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performDelete(ProductEntity product) async {
    final repo = ref.read(productRepositoryProvider);
    try {
      await repo.deleteProduct(product.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product deleted')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    }
  }

  Future<void> _showAddEditDialog(BuildContext context, {ProductEntity? existing}) async {
    final repo = ref.read(productRepositoryProvider);
    final nameCtl = TextEditingController(text: existing?.name ?? '');
    final skuCtl = TextEditingController(text: existing?.sku ?? '');
    final priceCtl = TextEditingController(text: existing != null ? existing.price.toString() : '0');
    final qtyCtl = TextEditingController(text: existing != null ? existing.quantity.toString() : '0');

    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'Add Product' : 'Edit Product'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(controller: nameCtl, decoration: const InputDecoration(labelText: 'Name'), validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
                TextFormField(controller: skuCtl, decoration: const InputDecoration(labelText: 'SKU')),
                TextFormField(controller: priceCtl, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.numberWithOptions(decimal: true)),
                TextFormField(controller: qtyCtl, decoration: const InputDecoration(labelText: 'Quantity'), keyboardType: TextInputType.number),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final name = nameCtl.text.trim();
              final sku = skuCtl.text.trim();
              final price = double.tryParse(priceCtl.text) ?? 0.0;
              final qty = int.tryParse(qtyCtl.text) ?? 0;

              try {
                if (existing == null) {
                  final newProduct = ProductEntity(
                    id: '',
                    name: name,
                    description: '',
                    price: price,
                    quantity: qty,
                    sku: sku,
                    category: '',
                    gstPercentage: 0.0,
                    tax: 0.0,
                    hsn: '',
                    active: true,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  await repo.createProduct(newProduct);
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product added')));
                } else {
                  final updated = existing.copyWith(name: name, sku: sku, price: price, quantity: qty, updatedAt: DateTime.now());
                  await repo.updateProduct(updated);
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product updated')));
                }
                Navigator.pop(context);
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Operation failed: $e')));
              }
            },
            child: Text(existing == null ? 'Create' : 'Save'),
          ),
        ],
      ),
    );
  }
}

/// Individual product card widget
class _ProductCard extends StatelessWidget {
  final ProductEntity product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final isLowStock = product.quantity < 10;

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'SKU: ${product.sku}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLowStock)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Low Stock',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stock',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${product.quantity} units',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GST',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${product.gstPercentage.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              product.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[700],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
