import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

/// Service responsible for Firebase Core and Firestore operations.
/// Uses singleton pattern to ensure single initialization.
/// No Firebase Authentication - app runs without login.
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  
  factory FirebaseService() => _instance;
  
  FirebaseService._internal();

  bool _initialized = false;
  
  /// Returns true if Firebase has been initialized
  bool get isInitialized => _initialized;
  
  /// Get Firestore instance
  FirebaseFirestore get firestore {
    if (!_initialized && Firebase.apps.isEmpty) {
      throw StateError('FirebaseService not initialized. Call initialize() first.');
    }
    return FirebaseFirestore.instance;
  }
  
  /// Initialize Firebase safely
  /// Can be called multiple times - only initializes once
  Future<void> initialize() async {
    if (_initialized) {
      debugPrint('FirebaseService: Already initialized, skipping...');
      return;
    }
    
    // Check if Firebase is already initialized
    if (Firebase.apps.isNotEmpty) {
      debugPrint('FirebaseService: Firebase.apps not empty, marking as initialized');
      _initialized = true;
      
      // Configure Firestore settings even if already initialized
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      
      return;
    }
    
    try {
      debugPrint('FirebaseService: Initializing Firebase...');
      
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      // Configure Firestore settings for offline persistence
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      
      _initialized = true;
      debugPrint('FirebaseService: Firebase initialized successfully with offline persistence');
    } catch (e, stackTrace) {
      debugPrint('FirebaseService: Failed to initialize Firebase: $e');
      debugPrint(stackTrace.toString());
      rethrow;
    }
  }
}
