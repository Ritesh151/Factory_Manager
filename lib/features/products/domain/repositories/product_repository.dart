import '../entities/product_entity.dart';

/// Abstract repository for product operations
/// Implementations handle Firestore interactions
abstract class ProductRepository {
  /// Get a stream of all products from Firestore
  /// Real-time updates via StreamProvider
  Stream<List<ProductEntity>> getAllProductsStream();

  /// Get a single product by ID
  Future<ProductEntity> getProductById(String productId);

  /// Get products paginated (for large datasets)
  Future<List<ProductEntity>> getProductsPaginated({
    required int page,
    required int pageSize,
  });

  /// Create a new product in Firestore
  /// Generates automatic ID via Firestore
  Future<ProductEntity> createProduct(ProductEntity product);

  /// Update an existing product in Firestore
  Future<ProductEntity> updateProduct(ProductEntity product);

  /// Delete a product from Firestore
  Future<void> deleteProduct(String productId);

  /// Search products by name or SKU
  Future<List<ProductEntity>> searchProducts(String query);

  /// Get products by category
  Future<List<ProductEntity>> getProductsByCategory(String category);

  /// Batch update product quantities (for invoicing)
  Future<void> updateProductStocks(Map<String, int> stockUpdates);

  /// Get low stock alerts (quantity < 10)
  Stream<List<ProductEntity>> getLowStockProductsStream();
}
