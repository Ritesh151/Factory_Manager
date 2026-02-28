import 'package:flutter/foundation.dart';

/// Simple stub repository for non-authenticated mode.
/// All login/register operations return success without actual authentication.
class AuthRepositoryImpl {
  AuthRepositoryImpl();

  /// Stub login - just returns a mock success
  Future<Map<String, dynamic>> loginWithEmailAndPassword(
      String email, String password) async {
    debugPrint('AuthRepository: Login attempt for $email (no auth required)');
    // No actual authentication - return success
    return {'success': true, 'email': email};
  }

  /// Stub register - just returns a mock success
  Future<Map<String, dynamic>> registerWithEmailAndPassword(
      String email, String password) async {
    debugPrint('AuthRepository: Register attempt for $email (no auth required)');
    // No actual authentication - return success
    return {'success': true, 'email': email};
  }
}
