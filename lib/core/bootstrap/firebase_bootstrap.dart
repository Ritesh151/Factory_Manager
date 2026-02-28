import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/firebase_service.dart';
import '../../app.dart';

/// Bootstrap function that initializes all services before running the app
/// 
/// Handles:
/// - Firebase initialization with safe guards
/// - Error handling and recovery
/// - Platform-specific initialization
/// - Provider scope setup
Future<void> bootstrap() async {
  // Check if running on Linux desktop
  final isLinuxDesktop = !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;
  
  // Setup error handling zones - everything inside the zone
  await runZonedGuarded(
    () async {
      // Ensure Flutter binding is initialized INSIDE the zone
      WidgetsFlutterBinding.ensureInitialized();
      
      try {
        // Initialize Firebase Service (skips on Linux)
        await _initializeFirebase(isLinuxDesktop);
        
        // Run the app with ProviderScope
        runApp(
          const ProviderScope(
            child: SmartErpApp(),
          ),
        );
      } catch (e, stackTrace) {
        _handleFatalError(e, stackTrace);
      }
    },
    (error, stack) {
      // Handle uncaught async errors
      debugPrint('Uncaught error: $error');
      debugPrint(stack.toString());
    },
  );
}

/// Initialize Firebase with comprehensive error handling
Future<void> _initializeFirebase(bool isLinuxDesktop) async {
  // Linux desktop: Skip Firebase initialization (not supported)
  if (isLinuxDesktop) {
    debugPrint('Bootstrap: Linux desktop detected - skipping Firebase initialization');
    return;
  }
  
  final firebaseService = FirebaseService();
  
  try {
    await firebaseService.initialize();
  } catch (e) {
    // If Firebase fails, we can still run in offline mode
    debugPrint('WARNING: Firebase initialization failed: $e');
    debugPrint('App will run in offline mode');
    // Don't rethrow - allow app to continue in offline mode
  }
}

/// Handle fatal initialization errors by showing error screen
void _handleFatalError(Object error, StackTrace stackTrace) {
  debugPrint('FATAL ERROR during bootstrap: $error');
  debugPrint(stackTrace.toString());
  
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(
                'Failed to initialize app',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
