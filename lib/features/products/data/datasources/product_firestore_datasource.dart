import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

/// Firestore data source for product operations
/// All Firestore queries and streams are handled here
class ProductFirestoreDataSource {
  final FirebaseFirestore _firestore;

  /// Collection name in Firestore
  static const String collectionName = 'products';

  ProductFirestoreDataSource(this._firestore);

  /// Get real-time stream of all products
  /// Used for real-time list updates in the UI
  Stream<List<ProductModel>> getAllProductsStream() {
    return _firestore
        .collection(collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Get low stock products stream (quantity < 10)
  Stream<List<ProductModel>> getLowStockProductsStream() {
    return _firestore
        .collection(collectionName)
        .where('quantity', isLessThan: 10)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Get a single product by ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final doc = await _firestore
          .collection(collectionName)
          .doc(productId)
          .get();
      if (doc.exists) {
        return ProductModel.fromFirestore(doc);
      }
      return null;
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch product: ${e.message}');
    }
  }

  /// Get products with pagination
  Future<List<ProductModel>> getProductsPaginated({
    required int page,
    required int pageSize,
  }) async {
    try {
      final offset = page * pageSize;
      final snapshot = await _firestore
          .collection(collectionName)
          .orderBy('createdAt', descending: true)
          .limit(pageSize)
          .offset(offset)
          .get();
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch paginated products: ${e.message}');
    }
  }

  /// Create a new product
  /// Returns the created product with Firestore-generated ID
  Future<ProductModel> createProduct(ProductModel productModel) async {
    try {
      final docRef = await _firestore
          .collection(collectionName)
          .add(productModel.toMap());
      
      // Fetch the created document to return with ID
      final doc = await docRef.get();
      return ProductModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw Exception('Failed to create product: ${e.message}');
    }
  }

  /// Update an existing product
  Future<ProductModel> updateProduct(ProductModel productModel) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(productModel.id)
          .update(productModel.toMap());
      
      // Return updated document
      final doc = await _firestore
          .collection(collectionName)
          .doc(productModel.id)
          .get();
      return ProductModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw Exception('Failed to update product: ${e.message}');
    }
  }

  /// Delete a product
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(productId)
          .delete();
    } on FirebaseException catch (e) {
      throw Exception('Failed to delete product: ${e.message}');
    }
  }

  /// Search products by name or SKU (case-insensitive)
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final lowerQuery = query.toLowerCase();
      final snapshot = await _firestore
          .collection(collectionName)
          .get();
      
      // Client-side filtering (Firestore limitation)
      final filtered = snapshot.docs
          .where((doc) {
        final product = ProductModel.fromFirestore(doc);
        return product.name.toLowerCase().contains(lowerQuery) ||
            product.sku.toLowerCase().contains(lowerQuery);
      })
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
      
      return filtered;
    } on FirebaseException catch (e) {
      throw Exception('Failed to search products: ${e.message}');
    }
  }

  /// Get products by category
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection(collectionName)
          .where('category', isEqualTo: category)
          .get();
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch products by category: ${e.message}');
    }
  }

  /// Batch update product quantities
  /// Used when creating invoices to deduct stock
  Future<void> updateProductStocks(Map<String, int> stockUpdates) async {
    try {
      final batch = _firestore.batch();
      
      for (final entry in stockUpdates.entries) {
        final docRef = _firestore
            .collection(collectionName)
            .doc(entry.key);
        
        batch.update(docRef, {
          'quantity': FieldValue.increment(-entry.value),
          'updatedAt': Timestamp.now(),
        });
      }
      
      await batch.commit();
    } on FirebaseException catch (e) {
      throw Exception('Failed to update stock: ${e.message}');
    }
  }

  /// Get all available categories
  Future<List<String>> getCategories() async {
    try {
      final snapshot = await _firestore
          .collection(collectionName)
          .get();
      
      final categories = <String>{};
      for (final doc in snapshot.docs) {
        final product = ProductModel.fromFirestore(doc);
        if (product.category.isNotEmpty) {
          categories.add(product.category);
        }
      }
      
      return categories.toList();
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch categories: ${e.message}');
    }
  }
}
