import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_firestore_datasource.dart';
import '../models/product_model.dart';

/// Product repository implementation
/// Implements the abstract ProductRepository using Firestore datasource
class ProductRepositoryImpl implements ProductRepository {
  final ProductFirestoreDataSource _firestoreDataSource;

  ProductRepositoryImpl(this._firestoreDataSource);

  @override
  Stream<List<ProductEntity>> getAllProductsStream() {
    return _firestoreDataSource
        .getAllProductsStream()
        .map((models) => models.map((model) => model.toEntity()).toList());
  }

  @override
  Stream<List<ProductEntity>> getLowStockProductsStream() {
    return _firestoreDataSource
        .getLowStockProductsStream()
        .map((models) => models.map((model) => model.toEntity()).toList());
  }

  @override
  Future<ProductEntity> getProductById(String productId) async {
    try {
      final model = await _firestoreDataSource.getProductById(productId);
      if (model == null) {
        throw Exception('Product not found');
      }
      return model.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ProductEntity>> getProductsPaginated({
    required int page,
    required int pageSize,
  }) async {
    try {
      final models = await _firestoreDataSource.getProductsPaginated(
        page: page,
        pageSize: pageSize,
      );
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ProductEntity> createProduct(ProductEntity product) async {
    try {
      final model = ProductModel.fromEntity(product);
      final createdModel = await _firestoreDataSource.createProduct(model);
      return createdModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ProductEntity> updateProduct(ProductEntity product) async {
    try {
      final model = ProductModel.fromEntity(product);
      final updatedModel = await _firestoreDataSource.updateProduct(model);
      return updatedModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestoreDataSource.deleteProduct(productId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ProductEntity>> searchProducts(String query) async {
    try {
      final models = await _firestoreDataSource.searchProducts(query);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(String category) async {
    try {
      final models = await _firestoreDataSource.getProductsByCategory(category);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateProductStocks(Map<String, int> stockUpdates) async {
    try {
      await _firestoreDataSource.updateProductStocks(stockUpdates);
    } catch (e) {
      rethrow;
    }
  }
}
