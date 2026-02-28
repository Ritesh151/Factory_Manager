import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../products/models/product_model.dart';
import '../../products/repositories/product_repository.dart';

/// Enhanced ProductDialog with local image upload functionality
/// Supports camera capture, gallery selection, and file browsing
class ProductDialogWithImage extends ConsumerStatefulWidget {
  final ProductRepository productRepository;
  final ProductModel? product;

  const ProductDialogWithImage({
    super.key,
    required this.productRepository,
    this.product,
  });

  @override
  ConsumerState<ProductDialogWithImage> createState() => _ProductDialogWithImageState();
}

class _ProductDialogWithImageState extends ConsumerState<ProductDialogWithImage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _gstController = TextEditingController();
  final _hsnController = TextEditingController();
  final _stockController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _descriptionController = TextEditingController();

  XFile? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _populateFields(widget.product!);
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

  void _populateFields(ProductModel product) {
    _nameController.text = product.name;
    _priceController.text = product.price.toString();
    _discountController.text = product.discount.toString();
    _gstController.text = product.gstPercentage.toString();
    _hsnController.text = product.hsnCode;
    _stockController.text = product.stock.toString();
    _imageUrlController.text = product.imageUrl ?? '';
    _descriptionController.text = product.description;
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      
      // Show selection dialog
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile;
          _imageUrlController.text = pickedFile.name;
        });
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e', isError: true);
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Check for duplicate product name
      final existingProduct = await widget.productRepository.getProductByName(_nameController.text.trim());
      if (existingProduct != null && widget.product?.id != existingProduct.id) {
        _showSnackBar('Product with this name already exists', isError: true);
        setState(() => _isLoading = false);
        return;
      }

      // Create product with image path
      final product = ProductModel(
        id: widget.product?.id ?? '',
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text),
        discount: double.parse(_discountController.text),
        gstPercentage: double.parse(_gstController.text),
        hsnCode: _hsnController.text.trim(),
        stock: int.parse(_stockController.text),
        imageUrl: _imageUrlController.text.trim(),
        description: _descriptionController.text.trim(),
        createdAt: widget.product?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        priceHistory: widget.product?.priceHistory ?? [
          PriceHistoryEntry(
            price: double.parse(_priceController.text),
            date: DateTime.now(),
          ),
        ],
      );

      if (widget.product == null) {
        await widget.productRepository.addProduct(product);
        _showSnackBar('Product added successfully', isError: false);
      } else {
        await widget.productRepository.updateProduct(product);
        _showSnackBar('Product updated successfully', isError: false);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showSnackBar('Error saving product: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _imageUrlController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return AlertDialog(
      title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: size.width * 0.8,
          maxHeight: size.height * 0.8,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Product Image Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Product Image',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Image Preview
                      if (_selectedImage != null)
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.colorScheme.outline),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Stack(
                            children: [
                              // Show image name since we can't use Image.file on web
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.image, size: 48, color: Colors.green),
                                    const SizedBox(height: 4),
                                    Text(
                                      _selectedImage!.name,
                                      style: theme.textTheme.bodySmall,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Remove image button
                              Positioned(
                                top: 8,
                                right: 8,
                                child: FloatingActionButton.small(
                                  onPressed: _removeImage,
                                  backgroundColor: Colors.red.withValues(alpha: 0.8),
                                  child: const Icon(Icons.close, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        // No image selected
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            border: Border.all(color: theme.colorScheme.outline),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate, 
                                   size: 48, 
                                   color: theme.colorScheme.outline),
                              const SizedBox(height: 8),
                              Text(
                                'No image selected',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 12),
                      
                      // Image Selection Buttons
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _pickImage,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Choose Image'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Product Details Form
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Product name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price *',
                    border: OutlineInputBorder(),
                    prefixText: '₹',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Price is required';
                    }
                    final price = double.tryParse(value);
                    if (price == null || price <= 0) {
                      return 'Enter a valid price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _discountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Discount (%)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Discount is required';
                    }
                    final discount = double.tryParse(value);
                    if (discount == null || discount < 0 || discount > 100) {
                      return 'Enter a valid discount (0-100)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _gstController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'GST Percentage *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'GST percentage is required';
                    }
                    final gst = double.tryParse(value);
                    if (gst == null || gst < 0 || gst > 100) {
                      return 'Enter a valid GST percentage (0-100)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _hsnController,
                  decoration: const InputDecoration(
                    labelText: 'HSN Code',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stock Quantity *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Stock quantity is required';
                    }
                    final stock = int.tryParse(value);
                    if (stock == null || stock < 0) {
                      return 'Enter a valid stock quantity';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
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
          onPressed: _isLoading ? null : _saveProduct,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.product == null ? 'Add Product' : 'Update Product'),
        ),
      ],
    );
  }
}
