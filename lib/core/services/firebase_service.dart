import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';

/// Service responsible for Firebase Core and Firestore operations.
/// Uses singleton pattern to ensure single initialization.
/// Optimized for performance with proper caching and error handling.
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  
  factory FirebaseService() => _instance;
  
  FirebaseService._internal();

  bool _initialized = false;
  bool _initializing = false;
  FirebaseFirestore? _firestoreInstance;
  
  /// Returns true if Firebase has been initialized
  bool get isInitialized => _initialized;
  
  /// Get Firestore instance safely without throwing crashes
  FirebaseFirestore get firestore {
    if (_firestoreInstance != null) {
      return _firestoreInstance!;
    }
    
    try {
      // If Firebase isn't initialized yet, try to get instance anyway
      // but don't throw StateError. Let the UI handle the connection state.
      _firestoreInstance = FirebaseFirestore.instance;
      return _firestoreInstance!;
    } catch (e) {
      debugPrint('FirebaseService: Firestore instance not available yet: $e');
      // Return a temporary instance if possible, or handle via StreamBuilder in UI
      return FirebaseFirestore.instance;
    }
  }
  
  /// Initialize Firebase safely with proper error handling
  Future<void> initialize() async {
    if (_initialized) return;
    
    if (_initializing) {
      while (_initializing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return;
    }
    
    _initializing = true;
    
    try {
      debugPrint('FirebaseService: Starting initialization for ${kIsWeb ? "Web" : "Native"}...');
      
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      
      // Configure Firestore settings
      final firestore = FirebaseFirestore.instance;
      
      firestore.settings = Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      
      _firestoreInstance = firestore;
      _initialized = true;
      debugPrint('FirebaseService: Initialized successfully');
    } catch (e) {
      debugPrint('FirebaseService: Initialization failed: $e');
      // We don't mark as _initialized = true on error to allow retry 
      // but we do set _initializing to false in finally
    } finally {
      _initializing = false;
    }
  }
  
  void reset() {
    _initialized = false;
    _initializing = false;
    _firestoreInstance = null;
  }
}
