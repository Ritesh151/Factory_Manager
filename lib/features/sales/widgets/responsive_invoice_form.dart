import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../products/models/product_model.dart';
import '../../products/repositories/product_repository.dart';
import '../models/sales_model.dart';
import '../repositories/sales_repository.dart';

/// Responsive Invoice Form with enterprise-grade UI and proper layout structure
class ResponsiveInvoiceForm extends ConsumerStatefulWidget {
  final SalesRepository salesRepository;
  final ProductRepository productRepository;

  const ResponsiveInvoiceForm({
    super.key,
    required this.salesRepository,
    required this.productRepository,
  });

  @override
  ConsumerState<ResponsiveInvoiceForm> createState() => _ResponsiveInvoiceFormState();
}

class _ResponsiveInvoiceFormState extends ConsumerState<ResponsiveInvoiceForm> {
  final _formKey = GlobalKey<FormState>();
  final _customerController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  final _dateController = TextEditingController();

  ProductModel? _selectedProduct;
  final List<InvoiceItem> _invoiceItems = [];
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _dateController.text = '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';
  }

  @override
  void dispose() {
    _customerController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _saveInvoice() async {
    if (!_formKey.currentState!.validate() || _invoiceItems.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      double subtotal = 0;
      double totalCgst = 0;
      double totalSgst = 0;

      for (final item in _invoiceItems) {
        subtotal += item.price * item.quantity;
        final afterDiscount = (item.price * item.quantity) * (1 - item.discount / 100);
        totalCgst += afterDiscount * (item.gstPercentage / 200);
        totalSgst += afterDiscount * (item.gstPercentage / 200);
      }

      final totalAmount = subtotal + totalCgst + totalSgst;

      final invoiceNumber = _generateInvoiceNumber();

      final sale = SalesModel(
        id: '',
        invoiceNumber: invoiceNumber,
        customerName: _customerController.text.trim(),
        customerPhone: null,
        customerGstin: null,
        items: _invoiceItems,
        subtotal: subtotal,
        totalCgst: totalCgst,
        totalSgst: totalSgst,
        extraCharges: 0.0,
        roundOff: 0.0,
        finalAmount: totalAmount,
        createdAt: _selectedDate,
        isLocked: true,
        status: 'pending',
      );

      await widget.salesRepository.createSale(sale);
      
      if (mounted) {
        Navigator.of(context).pop({'success': true});
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

  List<ProductModel> _deduplicateProducts(List<ProductModel> products) {
    final Map<String, ProductModel> uniqueProducts = {};
    
    for (final product in products) {
      if (!uniqueProducts.containsKey(product.id)) {
        uniqueProducts[product.id] = product;
      }
    }
    
    return uniqueProducts.values.toList();
  }

  void _addProduct() {
    if (_selectedProduct == null) return;
    
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    if (quantity <= 0 || quantity > _selectedProduct!.stock) return;

    final invoiceItem = InvoiceItem(
      productId: _selectedProduct!.id,
      productName: _selectedProduct!.name,
      hsnCode: _selectedProduct!.hsnCode,
      price: _selectedProduct!.finalPrice,
      quantity: quantity,
      gstPercentage: _selectedProduct!.gstPercentage,
      discount: _selectedProduct!.discount,
    );

    setState(() {
      _invoiceItems.add(invoiceItem);
      _selectedProduct = null;
      _quantityController.clear();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _invoiceItems.removeAt(index);
    });
  }

  double _calculateSubtotal() {
    return _invoiceItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  double _calculateTotalGST() {
    return _invoiceItems.fold(0, (sum, item) {
      final afterDiscount = (item.price * item.quantity) * (1 - item.discount / 100);
      return sum + afterDiscount * (item.gstPercentage / 100);
    });
  }

  double _calculateGrandTotal() {
    return _calculateSubtotal() + _calculateTotalGST();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double dialogWidth;
        if (constraints.maxWidth > 1500) {
          dialogWidth = 900;
        } else if (constraints.maxWidth > 1100) {
          dialogWidth = 800;
        } else if (constraints.maxWidth > 800) {
          dialogWidth = 700;
        } else {
          dialogWidth = constraints.maxWidth * 0.95;
        }

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: dialogWidth,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                _buildHeader(),
                
                // Form Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SECTION 1: Customer Details
                          _buildSectionTitle('Customer Details'),
                          const SizedBox(height: 16),
                          _buildCustomerAndDateRow(),
                          const SizedBox(height: 24),

                          // SECTION 2: Product Selection
                          _buildSectionTitle('Product Selection'),
                          const SizedBox(height: 16),
                          _buildProductSelectionRow(),
                          const SizedBox(height: 24),

                          // SECTION 3: Added Products Table
                          if (_invoiceItems.isNotEmpty) ...[
                            _buildSectionTitle('Added Products'),
                            const SizedBox(height: 16),
                            _buildProductsTable(),
                            const SizedBox(height: 24),
                          ],

                          // SECTION 4: Summary Panel
                          if (_invoiceItems.isNotEmpty) ...[
                            _buildSectionTitle('Invoice Summary'),
                            const SizedBox(height: 16),
                            _buildSummaryPanel(),
                            const SizedBox(height: 24),
                          ],

                          // SECTION 5: Notes
                          TextFormField(
                            controller: _notesController,
                            decoration: InputDecoration(
                              labelText: 'Notes',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // SECTION 6: Action Buttons
                _buildActionButtons(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Create GST Invoice',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildCustomerAndDateRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Mobile layout - Column
          return Column(
            children: [
              TextFormField(
                controller: _customerController,
                decoration: InputDecoration(
                  labelText: 'Customer Name *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Customer name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(16),
                child: IgnorePointer(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Invoice Date *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Date is required';
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ],
          );
        } else {
          // Desktop/Tablet layout - Row
          return Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _customerController,
                  decoration: InputDecoration(
                    labelText: 'Customer Name *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Customer name is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(16),
                  child: IgnorePointer(
                    child: TextFormField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        labelText: 'Invoice Date *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Date is required';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildProductSelectionRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Mobile layout - Column
          return Column(
            children: [
              StreamBuilder<List<ProductModel>>(
                stream: widget.productRepository.streamAllProducts(),
                builder: (context, snapshot) {
                  return _buildProductDropdown(snapshot, isExpanded: true);
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Quantity *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        contentPadding: const EdgeInsets.all(16),
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
                          return 'Insufficient stock';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _selectedProduct != null ? _addProduct : null,
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
          // Desktop/Tablet layout - Row
          return Row(
            children: [
              Expanded(
                flex: 3,
                child: StreamBuilder<List<ProductModel>>(
                  stream: widget.productRepository.streamAllProducts(),
                  builder: (context, snapshot) {
                    return _buildProductDropdown(snapshot);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Quantity *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    contentPadding: const EdgeInsets.all(16),
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
                      return 'Insufficient stock';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _selectedProduct != null ? _addProduct : null,
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildProductDropdown(AsyncSnapshot<List<ProductModel>> snapshot, {bool isExpanded = false}) {
    final theme = Theme.of(context);

    if (snapshot.connectionState == ConnectionState.waiting) {
      return const LinearProgressIndicator();
    }

    if (snapshot.hasError) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
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
    final filteredProducts = _deduplicateProducts(
      products.where((p) => p.stock > 0).toList()
    );
    
    if (_selectedProduct != null && !filteredProducts.any((p) => p.id == _selectedProduct!.id)) {
      setState(() {
        _selectedProduct = null;
      });
    }

    return DropdownButtonFormField<ProductModel>(
      initialValue: _selectedProduct,
      decoration: InputDecoration(
        labelText: 'Select Product *',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      items: filteredProducts.map((product) {
        return DropdownMenuItem<ProductModel>(
          key: ValueKey(product.id),
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
            _quantityController.text = '1';
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
  }

  Widget _buildProductsTable() {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          headingRowColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest),
          columns: const [
            DataColumn(
              label: Text('Product', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text('Price', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text('GST', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text('Discount', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
          rows: _invoiceItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final itemTotal = item.price * item.quantity;
            final afterDiscount = itemTotal * (1 - item.discount / 100);
            final totalWithGST = afterDiscount * (1 + item.gstPercentage / 100);

            return DataRow(
              cells: [
                DataCell(Text(item.productName)),
                DataCell(Text('₹${item.price.toStringAsFixed(2)}')),
                DataCell(Text('${item.quantity}')),
                DataCell(Text('${item.gstPercentage}%')),
                DataCell(Text('${item.discount}%')),
                DataCell(
                  Text(
                    '₹${totalWithGST.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeItem(index),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.errorContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSummaryPanel() {
    final theme = Theme.of(context);
    final subtotal = _calculateSubtotal();
    final totalGST = _calculateTotalGST();
    final grandTotal = _calculateGrandTotal();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Invoice Summary',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Subtotal', '₹${subtotal.toStringAsFixed(2)}'),
            _buildSummaryRow('Total GST', '₹${totalGST.toStringAsFixed(2)}'),
            const Divider(),
            _buildSummaryRow(
              'Grand Total',
              '₹${grandTotal.toStringAsFixed(2)}',
              isGrandTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isGrandTotal = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isGrandTotal ? 22 : 16,
              color: isGrandTotal ? theme.colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
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
          FilledButton(
            onPressed: (_isLoading || _invoiceItems.isEmpty) ? null : _saveInvoice,
            style: FilledButton.styleFrom(
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
                : const Text('Create Invoice'),
          ),
        ],
      ),
    );
  }
}
