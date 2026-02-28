import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../core/services/firebase_service.dart';
import '../../products/models/product_model.dart';

/// Repository for managing Product data in Firestore
/// Provides clean architecture with proper error handling
class ProductRepository {
  static final ProductRepository _instance = ProductRepository._internal();
  
  factory ProductRepository() => _instance;
  ProductRepository._internal();

  late final FirebaseService _firebaseService;
  bool _initialized = false;

  /// Initialize repository with FirebaseService
  void initialize(FirebaseService firebaseService) {
    if (_initialized) return;
    
    _firebaseService = firebaseService;
    _initialized = true;
  }

  /// Get Firestore collection reference
  CollectionReference<Map<String, dynamic>> get _productsCollection {
    return _firebaseService.firestore.collection('products');
  }

  /// Stream all products ordered by creation date (newest first)
  Stream<List<ProductModel>> streamAllProducts() {
    try {
      return _productsCollection
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
              .toList());
    } catch (e) {
      debugPrint('ProductRepository: Error streaming products: $e');
      return Stream.error(e);
    }
  }

  /// Get product by ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final doc = await _productsCollection.doc(productId).get();
      if (!doc.exists) return null;
      
      return ProductModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      debugPrint('ProductRepository: Error getting product by ID: $e');
      return null;
    }
  }

  /// Check if product name already exists
  Future<bool> productExists(String productName) async {
    try {
      final snapshot = await _productsCollection
          .where('name', isEqualTo: productName.trim())
          .limit(1)
          .get();
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('ProductRepository: Error checking product existence: $e');
      return false;
    }
  }

  /// Add new product with duplicate prevention
  Future<String> addProduct(ProductModel product) async {
    try {
      // Check for duplicate product name
      if (await productExists(product.name)) {
        throw ArgumentError('Product with name "${product.name}" already exists');
      }

      // Add createdAt timestamp if not set
      final productWithTimestamp = product.createdAt.isBefore(DateTime(2000))
          ? product.copyWith(createdAt: DateTime.now())
          : product;

      final docRef = await _productsCollection.add(productWithTimestamp.toMap());
      
      debugPrint('ProductRepository: Added product "${product.name}" with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('ProductRepository: Error adding product: $e');
      rethrow;
    }
  }

  /// Update existing product
  Future<void> updateProduct(ProductModel product) async {
    try {
      final productWithTimestamp = product.copyWith(updatedAt: DateTime.now());
      await _productsCollection.doc(product.id).update(productWithTimestamp.toMap());
      
      debugPrint('ProductRepository: Updated product "${product.name}"');
    } catch (e) {
      debugPrint('ProductRepository: Error updating product: $e');
      rethrow;
    }
  }

  /// Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      await _productsCollection.doc(productId).delete();
      debugPrint('ProductRepository: Deleted product with ID: $productId');
    } catch (e) {
      debugPrint('ProductRepository: Error deleting product: $e');
      rethrow;
    }
  }

  /// Get low stock products
  Stream<List<ProductModel>> streamLowStockProducts() {
    try {
      return _productsCollection
          .where('stock', isLessThan: 10)
          .orderBy('stock')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
              .toList());
    } catch (e) {
      debugPrint('ProductRepository: Error streaming low stock products: $e');
      return Stream.error(e);
    }
  }

  /// Search products by name
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      if (query.trim().isEmpty) {
        final snapshot = await _productsCollection
            .orderBy('createdAt', descending: true)
            .limit(20)
            .get();
        
        return snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
            .toList();
      }

      final snapshot = await _productsCollection
          .where('name', isGreaterThanOrEqualTo: query)
          .orderBy('name')
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('ProductRepository: Error searching products: $e');
      return [];
    }
  }

  /// Update product stock
  Future<void> updateStock(String productId, int newStock) async {
    try {
      await _productsCollection.doc(productId).update({
        'stock': newStock,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      
      debugPrint('ProductRepository: Updated stock for product ID: $productId to $newStock');
    } catch (e) {
      debugPrint('ProductRepository: Error updating stock: $e');
      rethrow;
    }
  }

  /// Get product by name
  Future<ProductModel?> getProductByName(String productName) async {
    try {
      final snapshot = await _productsCollection
          .where('name', isEqualTo: productName.trim())
          .limit(1)
          .get();
      
      if (snapshot.docs.isEmpty) return null;
      
      return ProductModel.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
    } catch (e) {
      debugPrint('ProductRepository: Error getting product by name: $e');
      return null;
    }
  }
}
