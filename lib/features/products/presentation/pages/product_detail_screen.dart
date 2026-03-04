import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product_entity.dart';
import '../providers/product_providers.dart';
import '../../../../core/layout/app_layout.dart';

/// Product detail screen showing complete product information
class ProductDetailScreen extends ConsumerWidget {
  final ProductEntity product;

  const ProductDetailScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  Color _getStockBadgeColor(int quantity) {
    if (quantity > 50) return Colors.green;
    if (quantity >= 10) return Colors.orange;
    return Colors.red;
  }

  String _getStockLabel(int quantity) {
    if (quantity > 50) return 'In Stock';
    if (quantity >= 10) return 'Low Stock';
    return 'Critical';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    Future<void> _showEditDialog() async {
      final repo = ref.read(productRepositoryProvider);
      final nameCtl = TextEditingController(text: product.name);
      final skuCtl = TextEditingController(text: product.sku);
      final priceCtl = TextEditingController(text: product.price.toString());
      final qtyCtl = TextEditingController(text: product.quantity.toString());
      final formKey = GlobalKey<FormState>();

      await showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Edit Product'),
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
            TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final updated = product.copyWith(
                  name: nameCtl.text.trim(),
                  sku: skuCtl.text.trim(),
                  price: double.tryParse(priceCtl.text) ?? product.price,
                  quantity: int.tryParse(qtyCtl.text) ?? product.quantity,
                  updatedAt: DateTime.now(),
                );
                try {
                  await repo.updateProduct(updated);
                  if (mounted) Navigator.pop(c);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    }

    return AppLayout(
      title: 'Product Details',
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_rounded),
                    onPressed: _showEditDialog,
                    tooltip: 'Edit Product',
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_rounded, color: Colors.red),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: const Text('Delete Product'),
                          content: Text('Delete "${product.name}"? This action cannot be undone.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        try {
                          await ref.read(productRepositoryProvider).deleteProduct(product.id);
                          if (Navigator.canPop(context)) Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
                        }
                      }
                    },
                    tooltip: 'Delete Product',
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Hero image placeholder
              Container(
                width: double.infinity,
                height: 300,
                color: Colors.grey[300],
                child: Center(
                  child: Icon(
                    Icons.image_not_supported_rounded,
                    size: 64,
                    color: Colors.grey[600],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Name & SKU
              Text(
                product.name,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text('SKU: ${product.sku}', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[500])),

              const SizedBox(height: 24),

              // Price
              Text('Price', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor.withOpacity(0.12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Unit Price', style: Theme.of(context).textTheme.bodyLarge),
                    Text('₹${product.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: primaryColor, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Stock
              Text('Stock Information', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getStockBadgeColor(product.quantity).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getStockBadgeColor(product.quantity).withOpacity(0.12)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Current Stock', style: Theme.of(context).textTheme.bodyLarge),
                        Text('${product.quantity} units', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: _getStockBadgeColor(product.quantity), fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Stock Level', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[500])),
                        Text(_getStockLabel(product.quantity), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: _getStockBadgeColor(product.quantity), fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: (product.quantity / 100).clamp(0, 1), minHeight: 8, backgroundColor: Colors.grey[300], valueColor: AlwaysStoppedAnimation(_getStockBadgeColor(product.quantity)))),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tax & Category
              Text('Tax Information', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: isDark ? Colors.grey[850] : Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withOpacity(0.12))),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('GST Percentage', style: Theme.of(context).textTheme.bodyMedium), Text('${product.gstPercentage.toStringAsFixed(2)}%')]),
                  const SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('HSN Code', style: Theme.of(context).textTheme.bodyMedium), Text(product.hsn.isNotEmpty ? product.hsn : '-')]),
                  const SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Tax Amount', style: Theme.of(context).textTheme.bodyMedium), Text('₹${product.tax.toStringAsFixed(2)}')]),
                ]),
              ),

              const SizedBox(height: 24),

              Text('Category & Status', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: isDark ? Colors.grey[850] : Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withOpacity(0.12))),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Category', style: Theme.of(context).textTheme.bodyMedium), Text(product.category.isNotEmpty ? product.category : 'Uncategorized')]),
                  const SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Status', style: Theme.of(context).textTheme.bodyMedium), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: product.active ? Colors.green.withOpacity(0.08) : Colors.red.withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: product.active ? Colors.green.withOpacity(0.12) : Colors.red.withOpacity(0.12))), child: Text(product.active ? 'Active' : 'Inactive', style: TextStyle(color: product.active ? Colors.green : Colors.red, fontWeight: FontWeight.bold)))
                ]),
              ),

              const SizedBox(height: 24),

              Text('Description', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: isDark ? Colors.grey[850] : Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withOpacity(0.12))), child: Text(product.description.isNotEmpty ? product.description : 'No description provided', style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6))),

              const SizedBox(height: 24),

              Text('Timestamps', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: isDark ? Colors.grey[850] : Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withOpacity(0.12))), child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Created', style: Theme.of(context).textTheme.bodyMedium), Text(_formatDate(product.createdAt))]), const SizedBox(height: 12), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Last Updated', style: Theme.of(context).textTheme.bodyMedium), Text(_formatDate(product.updatedAt))])])),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}-${_monthName(dateTime.month)}-${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}

*** End Patch   ),
                        if (product.hsn != null && product.hsn!.isNotEmpty)
                          const SizedBox(height: 12),
                        _InfoRow(
                          label: 'Tax Amount',
                          value:
                              '₹${(product.tax ?? 0).toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Category section
                  _SectionHeader(title: 'Category & Status'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey[850]
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        _InfoRow(
                          label: 'Category',
                          value: product.category.isNotEmpty
                              ? product.category
                              : 'Uncategorized',
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Status',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: product.active
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: product.active
                                      ? Colors.green.withOpacity(0.3)
                                      : Colors.red.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                product.active ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  color: product.active
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Description section
                  _SectionHeader(title: 'Description'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey[850]
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      product.description.isNotEmpty
                          ? product.description
                          : 'No description provided',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.6,
                          ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Timestamps section
                  _SectionHeader(title: 'Timestamps'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey[850]
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        _InfoRow(
                          label: 'Created',
                          value: _formatDate(product.createdAt),
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          label: 'Last Updated',
                          value: _formatDate(product.updatedAt),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}-${_monthName(dateTime.month)}-${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}

/// Section header widget
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

/// Info row displaying label and value
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Flexible(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
