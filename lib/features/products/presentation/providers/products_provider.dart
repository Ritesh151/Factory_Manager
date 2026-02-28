import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/firebase_service.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';

/// Product service provider
final productServiceProvider = Provider<ProductService>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  final service = ProductService();
  service.initialize(firebaseService);
  return service;
});

/// Stream of all products from Firestore
final productsStreamProvider = StreamProvider<List<ProductModel>>((ref) {
  final productService = ref.watch(productServiceProvider);
  return productService.streamProducts();
});
