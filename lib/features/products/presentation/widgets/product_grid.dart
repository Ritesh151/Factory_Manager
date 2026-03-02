import 'package:flutter/material.dart';
import '../../domain/entities/product_entity.dart';
import 'product_card.dart';

/// Responsive grid widget for displaying products
class ProductGrid extends StatelessWidget {
  final List<ProductEntity> products;
  final Function(ProductEntity) onProductTap;
  final Function(ProductEntity) onEdit;
  final Function(ProductEntity) onDelete;
  final ScrollController? scrollController;

  const ProductGrid({
    Key? key,
    required this.products,
    required this.onProductTap,
    required this.onEdit,
    required this.onDelete,
    this.scrollController,
  }) : super(key: key);

  int _getGridCrossAxisCount(double width) {
    if (width < 600) return 1; // Small width: 1 column
    if (width < 900) return 2; // Medium width: 2 columns
    if (width < 1440) return 3; // Large width: 3 columns
    return 4; // Extra large: 4 columns
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount =
            _getGridCrossAxisCount(constraints.maxWidth);

        return GridView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              product: product,
              onTap: () => onProductTap(product),
              onEdit: () => onEdit(product),
              onDelete: () => onDelete(product),
            );
          },
        );
      },
    );
  }
}
