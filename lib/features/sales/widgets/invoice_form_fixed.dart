import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../products/models/product_model.dart';
import '../../products/repositories/product_repository.dart';
import '../models/sales_model.dart';
import '../repositories/sales_repository.dart';

/// Production-ready InvoiceForm with comprehensive dropdown error prevention
class InvoiceForm extends ConsumerStatefulWidget {
  final SalesRepository salesRepository;
  final ProductRepository productRepository;

  const InvoiceForm({
    super.key,
    required this.salesRepository,
    required this.productRepository,
  });

  @override
  ConsumerState<InvoiceForm> createState() => _InvoiceFormState();
}

class _InvoiceFormState extends ConsumerState<InvoiceForm> {
  final _formKey = GlobalKey<FormState>();
  final _customerController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  ProductModel? _selectedProduct;
  List<ProductModel> _availableProducts = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _customerController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveInvoice() async {
    if (!_formKey.currentState!.validate() || _selectedProduct == null) return;

    setState(() => _isLoading = true);

    try {
      final quantity = int.tryParse(_quantityController.text) ?? 0;
      final price = _selectedProduct!.finalPrice;
      final subtotal = price * quantity;
      final discount = subtotal * (_selectedProduct!.discount / 100);
      final afterDiscount = subtotal - discount;
      final cgst = afterDiscount * (_selectedProduct!.gstPercentage / 200);
      final sgst = afterDiscount * (_selectedProduct!.gstPercentage / 200);
      final totalAmount = afterDiscount + cgst + sgst;

      final invoiceNumber = _generateInvoiceNumber();

      final sale = SalesModel(
        id: '',
        invoiceNumber: invoiceNumber,
        customerName: _customerController.text.trim(),
        customerPhone: null,
        customerGstin: null,
        items: [
          InvoiceItem(
            productId: _selectedProduct!.id,
            productName: _selectedProduct!.name,
            hsnCode: _selectedProduct!.hsnCode,
            price: price,
            quantity: quantity,
            gstPercentage: _selectedProduct!.gstPercentage,
            discount: _selectedProduct!.discount,
          ),
        ],
        subtotal: subtotal,
        totalCgst: cgst,
        totalSgst: sgst,
        extraCharges: 0.0,
        roundOff: 0.0,
        finalAmount: totalAmount,
        createdAt: DateTime.now(),
        isLocked: true,
        status: 'pending',
      );

      await widget.salesRepository.createSale(sale);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invoice #${sale.invoiceNumber} created successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating invoice: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _generateInvoiceNumber() {
    final now = DateTime.now();
    return 'INV${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.millisecondsSinceEpoch.toString().substring(6)}';
  }

  /// Deduplicate products list to prevent dropdown errors
  List<ProductModel> _deduplicateProducts(List<ProductModel> products) {
    final Map<String, ProductModel> uniqueProducts = {};
    
    for (final product in products) {
      // Use productId as key to ensure uniqueness
      if (!uniqueProducts.containsKey(product.id)) {
        uniqueProducts[product.id] = product;
      }
    }
    
    return uniqueProducts.values.toList();
  }

  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Create GST Invoice'),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _customerController,
                decoration: const InputDecoration(
                  labelText: 'Customer Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Customer name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Product selection with comprehensive error prevention
              StreamBuilder<List<ProductModel>>(
                stream: widget.productRepository.streamAllProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LinearProgressIndicator();
                  }

                  if (snapshot.hasError) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.colorScheme.error),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: theme.colorScheme.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Error loading products: ${snapshot.error}',
                              style: TextStyle(color: theme.colorScheme.onErrorContainer),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final products = snapshot.data ?? [];
                  
                  // Filter products with stock > 0 and deduplicate
                  final filteredProducts = _deduplicateProducts(
                    products.where((p) => p.stock > 0).toList()
                  );
                  
                  // Update available products list
                  _availableProducts = filteredProducts;
                  
                  // Validate selected product exists
                  if (_selectedProduct != null && !filteredProducts.any((p) => p.id == _selectedProduct!.id)) {
                    setState(() {
                      _selectedProduct = null;
                    });
                  }

                  return DropdownButtonFormField<ProductModel>(
                    initialValue: _selectedProduct,
                    decoration: const InputDecoration(
                      labelText: 'Select Product *',
                      border: OutlineInputBorder(),
                    ),
                    // Ensure unique dropdown items
                    items: filteredProducts.map((product) {
                      return DropdownMenuItem<ProductModel>(
                        key: ValueKey(product.id), // Ensure unique keys
                        value: product,
                        child: Text(
                          '${product.name} (₹${product.finalPrice.toStringAsFixed(2)}) - Stock: ${product.stock}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedProduct = value;
                        if (value != null) {
                          _quantityController.text = '1'; // Default quantity
                        }
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a product';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Quantity is required';
                  }
                  final quantity = int.tryParse(value);
                  if (quantity == null || quantity <= 0) {
                    return 'Enter a valid quantity';
                  }
                  if (_selectedProduct != null && quantity > _selectedProduct!.stock) {
                    return 'Insufficient stock available';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              if (_selectedProduct != null) ...[
                const SizedBox(height: 16),
                Builder(builder: (context) {
                  final qty = int.tryParse(_quantityController.text) ?? 0;
                  final unitPrice = _selectedProduct!.finalPrice;
                  final subtotal = unitPrice * qty;
                  final discountAmt = subtotal * (_selectedProduct!.discount / 100);
                  final afterDiscount = subtotal - discountAmt;
                  final cgstAmt = afterDiscount * (_selectedProduct!.gstPercentage / 200);
                  final sgstAmt = afterDiscount * (_selectedProduct!.gstPercentage / 200);
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.colorScheme.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GST Invoice Calculation',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildPriceRow('Unit Price', '₹${unitPrice.toStringAsFixed(2)}'),
                        _buildPriceRow('Quantity', '$qty'),
                        _buildPriceRow('Subtotal', '₹${subtotal.toStringAsFixed(2)}'),
                        _buildPriceRow('Discount', '-₹${discountAmt.toStringAsFixed(2)}'),
                        _buildPriceRow('CGST (${_selectedProduct!.gstPercentage / 2}%)', '₹${cgstAmt.toStringAsFixed(2)}'),
                        _buildPriceRow('SGST (${_selectedProduct!.gstPercentage / 2}%)', '₹${sgstAmt.toStringAsFixed(2)}'),
                        const Divider(),
                        _buildPriceRow(
                          'Total Amount',
                          '₹${_calculateTotal().toStringAsFixed(2)}',
                          isBold: true,
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _saveInvoice,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create Invoice'),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? theme.colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTotal() {
    if (_selectedProduct == null) return 0.0;
    
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final price = _selectedProduct!.finalPrice;
    final subtotal = price * quantity;
    final discount = subtotal * (_selectedProduct!.discount / 100);
    final afterDiscount = subtotal - discount;
    final cgst = afterDiscount * (_selectedProduct!.gstPercentage / 200);
    final sgst = afterDiscount * (_selectedProduct!.gstPercentage / 200);
    
    return afterDiscount + cgst + sgst;
  }
}
