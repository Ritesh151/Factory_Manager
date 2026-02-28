import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../core/services/firebase_service.dart';
import '../models/product_model.dart';

/// Service responsible for all Product-related Firestore operations
/// Uses singleton pattern and integrates with FirebaseService
class ProductService {
  static final ProductService _instance = ProductService._internal();
  
  factory ProductService() => _instance;
  
  ProductService._internal();

  FirebaseFirestore? _firestore;

  /// Initialize with FirebaseService
  void initialize(FirebaseService firebaseService) {
    _firestore = firebaseService.firestore;
  }

  /// Get products collection reference
  CollectionReference<Map<String, dynamic>> get _productsCollection {
    if (_firestore == null) {
      throw StateError('ProductService not initialized. Call initialize() first.');
    }
    return _firestore!.collection('products');
  }

  /// Stream of all products - realtime updates
  Stream<List<ProductModel>> streamProducts() {
    try {
      return _productsCollection
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return ProductModel.fromMap(doc.data(), doc.id);
        }).toList();
      }).handleError((error) {
        debugPrint('ProductService: Error streaming products: $error');
        throw error;
      });
    } catch (e) {
      debugPrint('ProductService: Failed to create products stream: $e');
      return Stream.error(e);
    }
  }

  /// Stream of low stock products (stock < 10)
  Stream<List<ProductModel>> streamLowStockProducts() {
    try {
      return _productsCollection
          .where('stock', isLessThan: 10)
          .orderBy('stock')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return ProductModel.fromMap(doc.data(), doc.id);
        }).toList();
      });
    } catch (e) {
      debugPrint('ProductService: Failed to create low stock stream: $e');
      return Stream.error(e);
    }
  }

  /// Create a new product with price history and duplicate prevention
  Future<ProductModel> createProduct({
    required String name,
    required double price,
    double discount = 0.0,
    double gstPercentage = 18.0,
    String hsnCode = '',
    int stock = 0,
    String? imageUrl,
    String description = '',
  }) async {
    try {
      // Check for duplicate product name
      final existingProduct = await _getProductByName(name.trim());
      if (existingProduct != null) {
        throw ArgumentError('Product with name "$name" already exists');
      }

      // Validate inputs
      if (name.trim().isEmpty) {
        throw ArgumentError('Product name is required');
      }
      if (price <= 0) {
        throw ArgumentError('Price must be greater than 0');
      }

      final now = DateTime.now();
      final product = ProductModel(
        id: '',
        name: name.trim(),
        price: price,
        discount: discount,
        gstPercentage: gstPercentage,
        hsnCode: hsnCode.trim(),
        stock: stock,
        imageUrl: imageUrl?.trim() ?? '',
        description: description.trim(),
        createdAt: now,
        updatedAt: now,
        priceHistory: [PriceHistoryEntry(price: price, date: now)],
      );

      final docRef = await _productsCollection.add(product.toMap());
      
      debugPrint('ProductService: Created product "${product.name}" with ID: ${docRef.id}');
      
      return product.copyWith(id: docRef.id);
    } catch (e) {
      debugPrint('ProductService: Failed to create product: $e');
      rethrow;
    }
  }

  /// Get product by name to check for duplicates
  Future<ProductModel?> _getProductByName(String name) async {
    try {
      final snapshot = await _productsCollection
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      
      return ProductModel.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
    } catch (e) {
      debugPrint('ProductService: Error checking product by name: $e');
      return null;
    }
  }

  /// Update an existing product with price history tracking
  Future<void> updateProduct({
    required String id,
    String? name,
    double? price,
    double? discount,
    double? gstPercentage,
    String? hsnCode,
    int? stock,
    String? imageUrl,
    String? description,
  }) async {
    try {
      if (id.isEmpty) {
        throw ArgumentError('Product ID cannot be empty');
      }

      final updates = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      // Get current product for price history comparison
      final currentDoc = await _productsCollection.doc(id).get();
      if (!currentDoc.exists) {
        throw ArgumentError('Product not found');
      }

      final currentProduct = ProductModel.fromMap(currentDoc.data()!, id);
      final priceHistory = List<PriceHistoryEntry>.from(currentProduct.priceHistory);

      if (name != null && name.trim().isNotEmpty) {
        updates['name'] = name.trim();
      }
      if (price != null) {
        if (price < 0) throw ArgumentError('Price cannot be negative');
        updates['price'] = price;
        // Add to price history if price changed
        if (price != currentProduct.price) {
          priceHistory.add(PriceHistoryEntry(price: price, date: DateTime.now()));
          updates['priceHistory'] = priceHistory.map((e) => e.toMap()).toList();
        }
      }
      if (discount != null) {
        if (discount < 0 || discount > 100) throw ArgumentError('Discount must be between 0 and 100');
        updates['discount'] = discount;
      }
      if (gstPercentage != null) {
        if (gstPercentage < 0) throw ArgumentError('GST percentage cannot be negative');
        updates['gstPercentage'] = gstPercentage;
      }
      if (hsnCode != null) updates['hsnCode'] = hsnCode.trim();
      if (stock != null) {
        if (stock < 0) throw ArgumentError('Stock cannot be negative');
        updates['stock'] = stock;
      }
      if (imageUrl != null) updates['imageUrl'] = imageUrl;
      if (description != null) updates['description'] = description.trim();

      await _productsCollection.doc(id).update(updates);
      
      debugPrint('ProductService: Updated product with ID: $id');
    } catch (e) {
      debugPrint('ProductService: Failed to update product: $e');
      rethrow;
    }
  }

  /// Update stock quantity (for purchases/sales)
  Future<void> updateStock(String id, int quantityChange) async {
    try {
      if (id.isEmpty) throw ArgumentError('Product ID cannot be empty');

      await _firestore!.runTransaction((transaction) async {
        final docRef = _productsCollection.doc(id);
        final doc = await transaction.get(docRef);

        if (!doc.exists) throw ArgumentError('Product not found');

        final currentStock = (doc.data()?['stock'] as num?)?.toInt() ?? 0;
        final newStock = currentStock + quantityChange;

        if (newStock < 0) throw ArgumentError('Insufficient stock');

        transaction.update(docRef, {
          'stock': newStock,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      });

      debugPrint('ProductService: Updated stock for product $id by $quantityChange');
    } catch (e) {
      debugPrint('ProductService: Failed to update stock: $e');
      rethrow;
    }
  }

  /// Delete a product
  Future<void> deleteProduct(String id) async {
    try {
      if (id.isEmpty) throw ArgumentError('Product ID cannot be empty');

      await _productsCollection.doc(id).delete();
      
      debugPrint('ProductService: Deleted product with ID: $id');
    } catch (e) {
      debugPrint('ProductService: Failed to delete product: $e');
      rethrow;
    }
  }

  /// Get a single product by ID
  Future<ProductModel?> getProductById(String id) async {
    try {
      if (id.isEmpty) return null;

      final doc = await _productsCollection.doc(id).get();
      
      if (!doc.exists || doc.data() == null) return null;

      return ProductModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      debugPrint('ProductService: Failed to get product: $e');
      return null;
    }
  }

  /// Search products by name
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      final snapshot = await _productsCollection
          .orderBy('name')
          .startAt([query.trim()])
          .endAt(['${query.trim()}\uf8ff'])
          .limit(20)
          .get();

      return snapshot.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      debugPrint('ProductService: Failed to search products: $e');
      return [];
    }
  }
}
