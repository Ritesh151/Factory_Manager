import '../entities/product.dart';

abstract class ProductRepository {
  Stream<List<Product>> watchAll(String userId);
  Future<List<Product>> getAll(String userId);
  Future<Product?> getById(String userId, String productId);
  Future<Product> create(String userId, Product product);
  Future<Product> update(String userId, Product product);
  Future<void> delete(String userId, String productId);
  Future<List<Product>> getLowStock(String userId, {int threshold = 10});
  Future<List<Product>> search(String userId, String query);
  Future<void> updateStock(
    String userId,
    String productId,
    int newStock, {
    String? reason,
  });
  Future<void> batchUpdateStock(
    String userId,
    List<StockUpdate> updates,
  );
}

class StockUpdate {
  const StockUpdate({
    required this.productId,
    required this.newStock,
    this.reason,
  });
  final String productId;
  final int newStock;
  final String? reason;
}
