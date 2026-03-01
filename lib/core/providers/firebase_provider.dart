import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase_service.dart';

/// Firebase service provider - singleton instance managed by Riverpod
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  final service = FirebaseService();
  service.initialize();
  return service;
});

/// Cache TTL configuration in minutes
const int defaultCacheTtlMinutes = 5;

/// Custom exception for cache-related errors
class CacheException implements Exception {
  final String message;
  CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}
