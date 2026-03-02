import 'package:flutter/material.dart';
import '../../domain/entities/product_entity.dart';

/// Modern interactive product card with hover effects
class ProductCard extends StatefulWidget {
  final ProductEntity product;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onEnter(PointerEvent details) {
    setState(() => _isHovering = true);
    _hoverController.forward();
  }

  void _onExit(PointerEvent details) {
    setState(() => _isHovering = false);
    _hoverController.reverse();
  }

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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final surfaceColor = isDark
        ? Colors.grey[900]!.withOpacity(0.6)
        : Colors.white.withOpacity(0.8);

    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          final scale = 1.0 + (_hoverController.value * 0.02);
          final elevation = 4.0 + (_hoverController.value * 12.0);
          final shadowColor = primaryColor.withOpacity(0.3 * _hoverController.value);

          return Transform.scale(
            scale: scale,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: elevation,
                      offset: Offset(0, elevation / 2),
                    ),
                  ],
                  border: Border.all(
                    color: _isHovering ? primaryColor : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: null,
                    child: Container(
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Name & Price
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.product.name,
                                        style:
                                            Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        widget.product.sku,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: Colors.grey[500],
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Price - Prominent Display
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '₹${widget.product.price.toStringAsFixed(0)}',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Badges: HSN, GST, Stock
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                // HSN Badge
                                if (widget.product.hsn != null &&
                                    widget.product.hsn!.isNotEmpty)
                                  _BadgeWidget(
                                    label: 'HSN: ${widget.product.hsn}',
                                    backgroundColor:
                                        Colors.blue.withOpacity(0.15),
                                    textColor: Colors.blue,
                                  ),
                                // GST Badge
                                _BadgeWidget(
                                  label:
                                      'GST ${widget.product.gstPercentage.toStringAsFixed(0)}%',
                                  backgroundColor:
                                      Colors.purple.withOpacity(0.15),
                                  textColor: Colors.purple,
                                ),
                                // Stock Badge with color coding
                                _BadgeWidget(
                                  label: _getStockLabel(widget.product.quantity),
                                  backgroundColor: _getStockBadgeColor(
                                      widget.product.quantity)
                                    .withOpacity(0.15),
                                  textColor: _getStockBadgeColor(
                                      widget.product.quantity),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Description
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              widget.product.description.isNotEmpty
                                  ? widget.product.description
                                  : 'No description',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    height: 1.4,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Spacer(),
                          // Stock quantity display
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'In Stock',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: Colors.grey[500],
                                          ),
                                    ),
                                    Text(
                                      '${widget.product.quantity} units',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                                // Stock indicator bar
                                Flexible(
                                  child: Container(
                                    height: 4,
                                    margin: const EdgeInsets.only(left: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      color: Colors.grey[300],
                                    ),
                                    child: FractionallySizedBox(
                                      widthFactor: (widget.product.quantity /
                                              100)
                                          .clamp(0, 1),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(2),
                                          color: _getStockBadgeColor(
                                              widget.product.quantity),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Action Buttons
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // View Details (takes more space)
                                Expanded(
                                  flex: 3,
                                  child: _ActionButton(
                                    label: 'View Details',
                                    icon: Icons.arrow_forward_rounded,
                                    onTap: widget.onTap,
                                    isPrimary: true,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Edit
                                Expanded(
                                  child: _ActionButton(
                                    label: 'Edit',
                                    icon: Icons.edit_rounded,
                                    onTap: widget.onEdit,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Delete
                                Expanded(
                                  child: _ActionButton(
                                    label: 'Delete',
                                    icon: Icons.delete_rounded,
                                    onTap: widget.onDelete,
                                    isDestructive: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Hover Overlay
                          if (_isHovering)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: ScaleTransition(
                                    scale: Tween(begin: 0.8, end: 1.0)
                                        .animate(_hoverController),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.touch_app_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'View Product',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Badge widget for displaying information
class _BadgeWidget extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _BadgeWidget({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: textColor.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Action button widget
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isDestructive;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: 36,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: isPrimary
                  ? primaryColor
                  : isDestructive
                      ? Colors.red.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: isPrimary
                  ? null
                  : Border.all(
                      color: isDestructive ? Colors.red : Colors.grey,
                      width: 0.5,
                    ),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 16,
                color: isPrimary
                    ? Colors.white
                    : isDestructive
                        ? Colors.red
                        : Colors.grey[700],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
