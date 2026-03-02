import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/product_firestore_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';

/// Firestore instance provider
final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);

/// Product datasource provider
final productFirestoreDataSourceProvider = Provider((ref) {
  final firestore = ref.watch(firestoreProvider);
  return ProductFirestoreDataSource(firestore);
});

/// Product repository provider (dependency injection)
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final dataSource = ref.watch(productFirestoreDataSourceProvider);
  return ProductRepositoryImpl(dataSource);
});

/// Real-time stream of all products
/// This provider automatically updates UI when Firestore changes
final allProductsStreamProvider = StreamProvider<List<ProductEntity>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getAllProductsStream();
});

/// Real-time stream of low stock products
final lowStockProductsStreamProvider = StreamProvider<List<ProductEntity>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getLowStockProductsStream();
});

/// Get products by category (requires category parameter)
final productsByCategoryProvider = FutureProvider.family<
    List<ProductEntity>,
    String>((ref, category) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProductsByCategory(category);
});

/// Get product by ID (requires ID parameter)
final productByIdProvider = FutureProvider.family<ProductEntity, String>((ref, id) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProductById(id);
});

/// Search products (requires query parameter)
final searchProductsProvider = FutureProvider.family<List<ProductEntity>, String>((ref, query) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.searchProducts(query);
});

/// Create or update product state notifier
final productEditSetProvider = StateProvider<ProductEntity?>((ref) => null);

/// Product loading state
final productLoadingProvider = StateProvider<bool>((ref) => false);

/// Product error state
final productErrorProvider = StateProvider<String?>((ref) => null);
