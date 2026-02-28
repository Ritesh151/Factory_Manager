import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../products/models/product_model.dart';
import '../../products/services/product_service.dart';
import '../models/purchase_model.dart';

/// Form for recording a purchase
class PurchaseForm extends StatefulWidget {
  final ProductService productService;

  const PurchaseForm({super.key, required this.productService});

  @override
  State<PurchaseForm> createState() => _PurchaseFormState();
}

class _PurchaseFormState extends State<PurchaseForm> {
  final _formKey = GlobalKey<FormState>();
  final _supplierNameController = TextEditingController();
  final _supplierContactController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _purchaseDate = DateTime.now();
  final List<PurchaseItem> _items = [];
  
  ProductModel? _selectedProduct;
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController();

  double get _totalAmount => _items.fold(0.0, (sum, item) => sum + item.total);

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _purchaseDate = picked);
    }
  }

  void _addItem() {
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a product')),
      );
      return;
    }

    final quantity = int.tryParse(_quantityController.text) ?? 1;
    final price = double.tryParse(_priceController.text) ?? 0.0;

    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantity must be at least 1')),
      );
      return;
    }

    if (price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter purchase price')),
      );
      return;
    }

    setState(() {
      _items.add(PurchaseItem(
        productId: _selectedProduct!.id,
        productName: _selectedProduct!.name,
        purchasePrice: price,
        quantity: quantity,
      ));
      _selectedProduct = null;
      _quantityController.text = '1';
      _priceController.clear();
    });
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one item')),
      );
      return;
    }

    Navigator.of(context).pop({
      'supplierName': _supplierNameController.text.trim(),
      'supplierContact': _supplierContactController.text.trim().isEmpty 
          ? null 
          : _supplierContactController.text.trim(),
      'items': _items,
      'purchaseDate': _purchaseDate,
      'notes': _notesController.text.trim().isEmpty 
          ? null 
          : _notesController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Add Purchase'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 600, maxWidth: 700),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Supplier details
                Text('Supplier Details', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _supplierNameController,
                  decoration: const InputDecoration(
                    labelText: 'Supplier Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _supplierContactController,
                        decoration: const InputDecoration(
                          labelText: 'Contact',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _selectDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Purchase Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(DateFormat('dd/MM/yyyy').format(_purchaseDate)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                Divider(color: theme.colorScheme.outline),
                const SizedBox(height: 16),
                
                // Add items
                Text('Add Items', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildProductDropdown(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Qty',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price',
                          prefixText: '₹ ',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _addItem,
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Items list
                if (_items.isNotEmpty) ...[
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outline),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
                          ),
                          child: Row(
                            children: [
                              Expanded(flex: 3, child: Text('Product', style: theme.textTheme.labelSmall)),
                              Expanded(child: Text('Qty', style: theme.textTheme.labelSmall)),
                              Expanded(child: Text('Price', style: theme.textTheme.labelSmall)),
                              Expanded(child: Text('Total', style: theme.textTheme.labelSmall)),
                              const SizedBox(width: 40),
                            ],
                          ),
                        ),
                        ..._items.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              border: index < _items.length - 1 
                                  ? Border(bottom: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)))
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Expanded(flex: 3, child: Text(item.productName, style: theme.textTheme.bodySmall)),
                                Expanded(child: Text('${item.quantity}', style: theme.textTheme.bodySmall)),
                                Expanded(child: Text('₹${item.purchasePrice.toStringAsFixed(2)}', style: theme.textTheme.bodySmall)),
                                Expanded(child: Text('₹${item.total.toStringAsFixed(2)}', style: theme.textTheme.bodySmall)),
                                SizedBox(
                                  width: 40,
                                  child: IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 18),
                                    onPressed: () => _removeItem(index),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Total: ₹${_totalAmount.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
                
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Save Purchase'),
        ),
      ],
    );
  }

  Widget _buildProductDropdown() {
    return StreamBuilder<List<ProductModel>>(
      stream: widget.productService.streamProducts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LinearProgressIndicator();
        }

        final products = snapshot.data!;

        // Validate selected product exists in available products
        if (_selectedProduct != null && !products.any((p) => p.id == _selectedProduct!.id)) {
          _selectedProduct = null;
        }

        return DropdownButtonFormField<ProductModel>(
          initialValue: _selectedProduct,
          decoration: const InputDecoration(
            labelText: 'Select Product',
            border: OutlineInputBorder(),
          ),
          items: products.map((product) {
            return DropdownMenuItem(
              value: product,
              child: Text(product.name, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedProduct = value;
              if (value != null) {
                _priceController.text = value.price.toString();
              }
            });
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _supplierNameController.dispose();
    _supplierContactController.dispose();
    _notesController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
