import 'package:flutter/material.dart';

import '../../products/models/product_model.dart';
import '../../products/services/product_service.dart';
import '../models/sales_model.dart';

/// Form for creating GST invoice
class InvoiceForm extends StatefulWidget {
  final ProductService productService;

  const InvoiceForm({super.key, required this.productService});

  @override
  State<InvoiceForm> createState() => _InvoiceFormState();
}

class _InvoiceFormState extends State<InvoiceForm> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerGstinController = TextEditingController();
  final _extraChargesController = TextEditingController(text: '0');

  final List<InvoiceItem> _items = [];
  ProductModel? _selectedProduct;
  final _quantityController = TextEditingController(text: '1');

  double get _subtotal => _items.fold(0.0, (sum, item) => sum + item.amount);
  double get _totalCgst => _items.fold(0.0, (sum, item) => sum + item.cgst);
  double get _totalSgst => _items.fold(0.0, (sum, item) => sum + item.sgst);
  double get _extraCharges => double.tryParse(_extraChargesController.text) ?? 0.0;
  double get _rawTotal => _subtotal + _totalCgst + _totalSgst + _extraCharges;
  double get _roundOff => _rawTotal.roundToDouble() - _rawTotal;
  double get _finalAmount => _rawTotal.roundToDouble();

  Future<void> _addItem() async {
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a product')),
      );
      return;
    }

    final quantity = int.tryParse(_quantityController.text) ?? 1;
    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantity must be at least 1')),
      );
      return;
    }

    if (quantity > _selectedProduct!.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Only ${_selectedProduct!.stock} items in stock')),
      );
      return;
    }

    setState(() {
      _items.add(InvoiceItem(
        productId: _selectedProduct!.id,
        productName: _selectedProduct!.name,
        hsnCode: _selectedProduct!.hsnCode,
        price: _selectedProduct!.price,
        quantity: quantity,
        gstPercentage: _selectedProduct!.gstPercentage,
        discount: _selectedProduct!.discount,
      ));
      _selectedProduct = null;
      _quantityController.text = '1';
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
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
      'customerName': _customerNameController.text.trim(),
      'customerPhone': _customerPhoneController.text.trim().isEmpty 
          ? null 
          : _customerPhoneController.text.trim(),
      'customerGstin': _customerGstinController.text.trim().isEmpty 
          ? null 
          : _customerGstinController.text.trim(),
      'items': _items,
      'extraCharges': _extraCharges,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return AlertDialog(
      title: const Text('Create GST Invoice'),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: 700,
          maxWidth: size.width * 0.8,
          maxHeight: size.height * 0.85,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer details
                Text('Customer Details', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _customerNameController,
                        decoration: const InputDecoration(
                          labelText: 'Customer Name *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _customerPhoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _customerGstinController,
                  decoration: const InputDecoration(
                    labelText: 'Customer GSTIN',
                    hintText: '22AAAAA0000A1Z5',
                    border: OutlineInputBorder(),
                  ),
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
                      flex: 3,
                      child: _buildProductDropdown(),
                    ),
                    const SizedBox(width: 16),
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
                    const SizedBox(width: 16),
                    FilledButton.icon(
                      onPressed: _addItem,
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Items table
                if (_items.isNotEmpty) ...[
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outline),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
                          ),
                          child: Row(
                            children: [
                              Expanded(flex: 3, child: Text('Product', style: theme.textTheme.labelSmall)),
                              Expanded(child: Text('HSN', style: theme.textTheme.labelSmall)),
                              Expanded(child: Text('Qty', style: theme.textTheme.labelSmall)),
                              Expanded(child: Text('Rate', style: theme.textTheme.labelSmall)),
                              Expanded(child: Text('Amount', style: theme.textTheme.labelSmall)),
                              const SizedBox(width: 40),
                            ],
                          ),
                        ),
                        // Items
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
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.productName, style: theme.textTheme.bodySmall),
                                      Text(
                                        'GST: ${item.gstPercentage}% | Disc: ${item.discount}%',
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: theme.colorScheme.outline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(child: Text(item.hsnCode.isEmpty ? '-' : item.hsnCode, style: theme.textTheme.bodySmall)),
                                Expanded(child: Text('${item.quantity}', style: theme.textTheme.bodySmall)),
                                Expanded(child: Text('₹${item.price.toStringAsFixed(2)}', style: theme.textTheme.bodySmall)),
                                Expanded(child: Text('₹${item.amount.toStringAsFixed(2)}', style: theme.textTheme.bodySmall)),
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
                  const SizedBox(height: 24),
                ],
                
                // Totals
                if (_items.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildTotalRow('Subtotal:', _subtotal, theme),
                          _buildTotalRow('CGST:', _totalCgst, theme),
                          _buildTotalRow('SGST:', _totalSgst, theme),
                          Row(
                            children: [
                              const Text('Extra Charges:'),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 100,
                                child: TextFormField(
                                  controller: _extraChargesController,
                                  decoration: const InputDecoration(
                                    prefixText: '₹ ',
                                    isDense: true,
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  onChanged: (_) { },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildTotalRow('Round Off:', _roundOff, theme),
                          const Divider(),
                          _buildTotalRow('Total:', _finalAmount, theme, isBold: true),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Amount in words: Rupees ${_finalAmount.toInt()} only',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.outline,
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Create Invoice'),
        ),
      ],
    );
  }

  Widget _buildTotalRow(String label, double value, ThemeData theme, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(label),
          const SizedBox(width: 16),
          SizedBox(
            width: 120,
            child: Text(
              '₹${value.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: isBold 
                  ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDropdown() {
    return StreamBuilder<List<ProductModel>>(
      stream: widget.productService.streamProducts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LinearProgressIndicator();
        }

        final products = snapshot.data!.where((p) => p.stock > 0).toList();

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
              child: Text(
                '${product.name} (₹${product.finalPrice.toStringAsFixed(2)}) - Stock: ${product.stock}',
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedProduct = value),
        );
      },
    );
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerGstinController.dispose();
    _extraChargesController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}
