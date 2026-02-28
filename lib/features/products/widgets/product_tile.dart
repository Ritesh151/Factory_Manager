import 'package:flutter/material.dart';

import '../models/product_model.dart';

/// Product tile widget for desktop-friendly product list
class ProductTile extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductTile({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Product image or placeholder
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                image: product.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(product.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: product.imageUrl == null
                  ? Icon(Icons.image_outlined, color: colorScheme.outline)
                  : null,
            ),
            const SizedBox(width: 16),
            
            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (product.isLowStock)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Low Stock',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 12,
                    children: [
                      _buildInfoChip('HSN: ${product.hsnCode.isEmpty ? "-" : product.hsnCode}', colorScheme),
                      _buildInfoChip('GST: ${product.gstPercentage}%', colorScheme),
                      _buildInfoChip('Stock: ${product.stock}', 
                        colorScheme, 
                        product.isLowStock ? colorScheme.errorContainer : colorScheme.primaryContainer, 
                        product.isLowStock ? colorScheme.onErrorContainer : colorScheme.onPrimaryContainer),
                    ],
                  ),
                  if (product.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      product.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            
            // Price column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${product.finalPrice.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (product.discount > 0)
                  Text(
                    '₹${product.price.toStringAsFixed(2)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: colorScheme.outline,
                    ),
                  ),
                Text(
                  '${product.discount > 0 ? "${product.discount.toStringAsFixed(0)}% off" : "No discount"}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: product.discount > 0 ? colorScheme.tertiary : colorScheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            
            // Actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit Product',
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: colorScheme.error),
                  tooltip: 'Delete Product',
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, ColorScheme colorScheme, [Color? backgroundColor, Color? textColor]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: textColor ?? colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
