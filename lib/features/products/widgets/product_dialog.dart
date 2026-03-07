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
      final productData = {
        'name': _nameController.text.trim(),
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'discount': double.tryParse(_discountController.text) ?? 0.0,
        'gstPercentage': double.tryParse(_gstController.text) ?? 18.0,
        'hsnCode': _hsnController.text.trim(),
        'stock': int.tryParse(_stockController.text) ?? 0,
        'imageUrl': _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
        'description': _descriptionController.text.trim(),
      };

      if (isEditing) {
        // Update existing product
        await widget.productService.updateProduct(
          id: widget.product!.id,
          name: productData['name'] as String,
          price: productData['price'] as double,
          discount: productData['discount'] as double?,
          gstPercentage: productData['gstPercentage'] as double?,
          hsnCode: productData['hsnCode'] as String?,
          stock: productData['stock'] as int?,
          imageUrl: productData['imageUrl'] as String?,
          description: productData['description'] as String?,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product updated successfully')),
          );
        }
      } else {
        // Create new product
        await widget.productService.createProduct(
          name: productData['name'] as String,
          price: productData['price'] as double,
          discount: productData['discount'] as double,
          gstPercentage: productData['gstPercentage'] as double,
          hsnCode: productData['hsnCode'] as String,
          stock: productData['stock'] as int,
          imageUrl: productData['imageUrl'] as String?,
          description: productData['description'] as String,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added successfully')),
          );
        }
      }
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving product: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    // Calculate responsive dialog width
    double dialogWidth;
    if (width > 1400) {
      dialogWidth = 650;
    } else if (width > 900) {
      dialogWidth = 550;
    } else {
      dialogWidth = width * 0.9;
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: SizedBox(
        width: dialogWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Icon(
                    isEditing ? Icons.edit : Icons.add,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEditing ? 'Edit Product' : 'Add Product',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            
            // Form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildForm(),
              ),
            ),
            
            // Actions
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(24),
              child: _buildActions(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Name (full width)
          _buildTextFormField(
            controller: _nameController,
            labelText: 'Product Name *',
            hintText: 'Enter product name',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Product name is required';
              }
              return null;
            },
            autofocus: true,
          ),
          const SizedBox(height: 20),

          // Price and Discount (row)
          Row(
            children: [
              Expanded(
                child: _buildTextFormField(
                  controller: _priceController,
                  labelText: 'Price (₹) *',
                  hintText: '0.00',
                  prefixText: '₹ ',
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
                child: _buildTextFormField(
                  controller: _discountController,
                  labelText: 'Discount %',
                  hintText: '0',
                  suffixText: '%',
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
          const SizedBox(height: 20),

          // GST and HSN Code (row)
          Row(
            children: [
              Expanded(
                child: _buildTextFormField(
                  controller: _gstController,
                  labelText: 'GST %',
                  hintText: '18',
                  suffixText: '%',
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
                child: _buildTextFormField(
                  controller: _hsnController,
                  labelText: 'HSN Code',
                  hintText: 'Enter HSN',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stock Quantity (full width)
          _buildTextFormField(
            controller: _stockController,
            labelText: 'Stock Quantity',
            hintText: '0',
            keyboardType: TextInputType.number,
            validator: (value) {
              final stock = int.tryParse(value ?? '0') ?? 0;
              if (stock < 0) return 'Cannot be negative';
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Image URL (full width)
          _buildTextFormField(
            controller: _imageUrlController,
            labelText: 'Image URL',
            hintText: 'https://...',
            prefixIcon: const Icon(Icons.image),
          ),
          const SizedBox(height: 20),

          // Description (full width, min 3 lines)
          _buildTextFormField(
            controller: _descriptionController,
            labelText: 'Description',
            hintText: 'Product details...',
            maxLines: 3,
            alignLabelWithHint: true,
          ),

          // Price History (for editing)
          if (isEditing && widget.product!.priceHistory.length > 1) ...[
            const SizedBox(height: 24),
            Text(
              'Price History',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: BorderRadius.circular(12),
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
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    String? prefixText,
    String? suffixText,
    Widget? prefixIcon,
    TextInputType? keyboardType,
    int? maxLines,
    bool alignLabelWithHint = false,
    String? Function(String?)? validator,
    bool autofocus = false,
  }) {
    final theme = Theme.of(context);
    
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixText: prefixText,
        suffixText: suffixText,
        prefixIcon: prefixIcon,
        alignLabelWithHint: alignLabelWithHint,
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      autofocus: autofocus,
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _isLoading ? null : _save,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
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
