import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/firebase_service.dart';

/// Firebase service provider - singleton instance
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

/// Mock authenticated state - always returns true (no auth required)
final isAuthenticatedProvider = Provider<bool>((ref) {
  return true;
});
