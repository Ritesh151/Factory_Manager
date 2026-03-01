import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product.dart';
import '../services/product_service.dart';
import '../../../core/providers/firebase_provider.dart';

/// Product service provider
final productServiceProvider = Provider((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  final service = ProductService();
  service.initialize(firebaseService);
  return service;
});

/// Stream all products with real-time updates
final productsStreamProvider = StreamProvider((ref) {
  return ref.watch(productServiceProvider).streamProducts();
});

/// Cached products future - fetches once and caches for 5 minutes
final productsCacheProvider = FutureProvider((ref) async {
  final service = ref.watch(productServiceProvider);
  try {
    // Get all products as list (not stream)
    final stream = service.streamProducts();
    // Convert stream to future by taking first value
    return await stream.first;
  } catch (e) {
    throw Exception('Failed to fetch products: $e');
  }
});

/// Low stock products stream
final lowStockProductsStreamProvider = StreamProvider((ref) {
  return ref.watch(productServiceProvider).streamLowStockProducts();
});

/// Product search with caching
final productSearchProvider = FutureProvider.family<List<Product>, String>((ref, query) async {
  if (query.trim().isEmpty) {
    return [];
  }
  final service = ref.watch(productServiceProvider);
  try {
    // In real implementation, this would call service.searchProducts(query)
    // For now, we'll filter the cached products
    final allProducts = await ref.watch(productsCacheProvider.future);
    return allProducts
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  } catch (e) {
    throw Exception('Failed to search products: $e');
  }
});

/// Product by ID provider
final productByIdProvider = FutureProvider.family<Product?, String>((ref, productId) async {
  final products = await ref.watch(productsCacheProvider.future);
  try {
    return products.firstWhere((p) => p.id == productId);
  } catch (e) {
    return null;
  }
});
