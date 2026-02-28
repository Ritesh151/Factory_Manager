import 'core/bootstrap/firebase_bootstrap.dart';

/// Entry point for SmartERP application
/// 
/// Delegates all initialization to the bootstrap layer which handles:
/// - Firebase initialization with duplicate guards
/// - Error handling and recovery
/// - Service initialization
void main() {
  // All initialization logic moved to bootstrap()
  // This ensures clean separation and prevents duplicate initialization
  bootstrap();
}
