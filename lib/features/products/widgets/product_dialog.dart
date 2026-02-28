import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/product_service.dart';

/// Dialog for adding or editing a product with complete fields
class ProductDialog extends StatefulWidget {
  final ProductModel? product;
  final ProductService productService;

  const ProductDialog({super.key, this.product, required this.productService});

  @override
  State<ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _gstController = TextEditingController();
  final _hsnController = TextEditingController();
  final _stockController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final p = widget.product!;
      _nameController.text = p.name;
      _priceController.text = p.price.toString();
      _discountController.text = p.discount.toString();
      _gstController.text = p.gstPercentage.toString();
      _hsnController.text = p.hsnCode;
      _stockController.text = p.stock.toString();
      _imageUrlController.text = p.imageUrl ?? '';
      _descriptionController.text = p.description;
    } else {
      _discountController.text = '0';
      _gstController.text = '18';
      _stockController.text = '0';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _gstController.dispose();
    _hsnController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      Navigator.of(context).pop({
        'name': _nameController.text.trim(),
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'discount': double.tryParse(_discountController.text) ?? 0.0,
        'gstPercentage': double.tryParse(_gstController.text) ?? 18.0,
        'hsnCode': _hsnController.text.trim(),
        'stock': int.tryParse(_stockController.text) ?? 0,
        'imageUrl': _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
        'description': _descriptionController.text.trim(),
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    // Calculate responsive width
    final dialogWidth = size.width > 600
        ? size.width * 0.5
        : size.width * 0.9;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Product' : 'Add Product'),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: 280,
          maxWidth: dialogWidth,
          maxHeight: size.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name *',
                    hintText: 'Enter product name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Product name is required';
                    }
                    return null;
                  },
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price (₹) *',
                          hintText: '0.00',
                          border: OutlineInputBorder(),
                          prefixText: '₹ ',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          final price = double.tryParse(value);
                          if (price == null) return 'Invalid number';
                          if (price < 0) return 'Cannot be negative';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _discountController,
                        decoration: const InputDecoration(
                          labelText: 'Discount %',
                          hintText: '0',
                          border: OutlineInputBorder(),
                          suffixText: '%',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          final discount = double.tryParse(value ?? '0') ?? 0;
                          if (discount < 0 || discount > 100) return '0-100 only';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _gstController,
                        decoration: const InputDecoration(
                          labelText: 'GST %',
                          hintText: '18',
                          border: OutlineInputBorder(),
                          suffixText: '%',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          final gst = double.tryParse(value ?? '0') ?? 0;
                          if (gst < 0) return 'Cannot be negative';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _hsnController,
                        decoration: const InputDecoration(
                          labelText: 'HSN Code',
                          hintText: 'Enter HSN',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _stockController,
                  decoration: const InputDecoration(
                    labelText: 'Stock Quantity',
                    hintText: '0',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final stock = int.tryParse(value ?? '0') ?? 0;
                    if (stock < 0) return 'Cannot be negative';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Image URL',
                    hintText: 'https://...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.image),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Product details...',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                ),
                if (isEditing && widget.product!.priceHistory.length > 1) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Price History',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outline),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.product!.priceHistory.length,
                      itemBuilder: (context, index) {
                        final entry = widget.product!.priceHistory[index];
                        return ListTile(
                          dense: true,
                          title: Text('₹${entry.price.toStringAsFixed(2)}'),
                          subtitle: Text(
                            '${entry.date.day}/${entry.date.month}/${entry.date.year}',
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}
