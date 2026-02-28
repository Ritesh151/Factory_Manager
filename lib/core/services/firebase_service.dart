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
  
  /// Returns true if Firebase is currently being initialized
  bool get isInitializing => _initializing;
  
  /// Get Firestore instance with caching
  FirebaseFirestore get firestore {
    if (!_initialized) {
      debugPrint('FirebaseService: Not initialized, attempting to initialize...');
      _initializeSync();
    }
    
    if (_firestoreInstance != null) {
      return _firestoreInstance!;
    }
    
    try {
      _firestoreInstance = FirebaseFirestore.instance;
      return _firestoreInstance!;
    } catch (e) {
      debugPrint('FirebaseService: Error accessing Firestore: $e');
      throw StateError('Firestore not available. Running in offline mode.');
    }
  }
  
  /// Synchronous initialization for immediate access
  void _initializeSync() {
    if (_initializing || _initialized) return;
    
    if (Firebase.apps.isNotEmpty) {
      debugPrint('FirebaseService: Firebase.apps not empty, marking as initialized');
      _initialized = true;
      
      // Configure Firestore settings
      _configureFirestoreSettings();
    }
  }
  
  /// Configure Firestore settings
  void _configureFirestoreSettings() {
    try {
      final firestore = FirebaseFirestore.instance;
      firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      _firestoreInstance = firestore;
    } catch (e) {
      debugPrint('FirebaseService: Failed to configure Firestore settings: $e');
    }
  }
  
  /// Initialize Firebase safely with proper error handling
  /// Can be called multiple times - only initializes once
  Future<void> initialize() async {
    if (_initialized) {
      debugPrint('FirebaseService: Already initialized, skipping...');
      return;
    }
    
    if (_initializing) {
      debugPrint('FirebaseService: Already initializing, waiting...');
      // Wait for initialization to complete
      while (_initializing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return;
    }
    
    _initializing = true;
    
    try {
      debugPrint('FirebaseService: Initializing Firebase...');
      
      // Check if Firebase is already initialized
      if (Firebase.apps.isNotEmpty) {
        debugPrint('FirebaseService: Firebase.apps not empty, marking as initialized');
        _initialized = true;
        _configureFirestoreSettings();
        return;
      }
      
      // Initialize Firebase with timeout
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Firebase initialization timed out');
        },
      );
      
      // Configure Firestore settings for offline persistence
      _configureFirestoreSettings();
      
      _initialized = true;
      debugPrint('FirebaseService: Firebase initialized successfully with offline persistence');
    } catch (e) {
      debugPrint('FirebaseService: Failed to initialize Firebase: $e');
      debugPrint('FirebaseService: This is expected on Linux desktop - continuing in offline mode');
      
      // Don't rethrow - allow app to continue in offline mode
      // Mark as initialized to prevent repeated attempts
      _initialized = true;
    } finally {
      _initializing = false;
    }
  }
  
  /// Reset the service (useful for testing)
  void reset() {
    _initialized = false;
    _initializing = false;
    _firestoreInstance = null;
  }
}

/// Timeout exception for Firebase operations
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  
  @override
  String toString() => 'TimeoutException: $message';
}
