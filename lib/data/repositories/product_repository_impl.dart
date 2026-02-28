import '../../core/constants/firebase_constants.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/remote/firestore_product_source.dart';
import '../mappers/product_mapper.dart';
import '../models/product_dto.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._source);
  final FirestoreProductSource _source;

  @override
  Stream<List<Product>> watchAll(String userId) {
    return _source.watchAll(userId).map((docs) {
      return docs
          .map((d) => productFromDto(d.id, ProductDto.fromMap(d.data(), d.id)))
          .where((p) => p.isActive)
          .toList();
    });
  }

  @override
  Future<List<Product>> getAll(String userId) async {
    final docs = await _source.getAll(userId);
    return docs
        .map((d) => productFromDto(d.id, ProductDto.fromMap(d.data()!, d.id)))
        .where((p) => p.isActive)
        .toList();
  }

  @override
  Future<Product?> getById(String userId, String productId) async {
    final doc = await _source.getById(userId, productId);
    if (doc == null || !doc.exists || doc.data() == null) return null;
    return productFromDto(doc.id, ProductDto.fromMap(doc.data()!, doc.id));
  }

  @override
  Future<Product> create(String userId, Product product) async {
    final dto = productToDto(product);
    final id = await _source.create(userId, dto);
    return product.copyWith(id: id);
  }

  @override
  Future<Product> update(String userId, Product product) async {
    final dto = productToDto(product);
    await _source.update(userId, product.id, dto);
    return product.copyWith(updatedAt: DateTime.now());
  }

  @override
  Future<void> delete(String userId, String productId) async {
    await _source.delete(userId, productId);
  }

  @override
  Future<List<Product>> getLowStock(String userId, {int threshold = 10}) async {
    final all = await getAll(userId);
    return all.where((p) => p.stock <= threshold).toList();
  }

  @override
  Future<List<Product>> search(String userId, String query) async {
    final all = await getAll(userId);
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.hsnCode.contains(q))
        .toList();
  }

  @override
  Future<void> updateStock(
    String userId,
    String productId,
    int newStock, {
    String? reason,
  }) async {
    if (newStock < 0) throw ArgumentError('Stock cannot be negative');
    await _source.updateStock(userId, productId, newStock);
  }

  @override
  Future<void> batchUpdateStock(
    String userId,
    List<StockUpdate> updates,
  ) async {
    for (final u in updates) {
      if (u.newStock < 0) throw ArgumentError('Stock cannot be negative');
    }
    await _source.batchUpdateStock(
      userId,
      updates.map((u) => MapEntry(u.productId, u.newStock)).toList(),
    );
  }
}
