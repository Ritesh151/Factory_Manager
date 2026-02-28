import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'firebase_options.dart';

/// Main application widget with proper Firebase initialization
/// Ensures single Firebase instance and prevents duplicate app errors
class SmartErpApp extends ConsumerWidget {
  const SmartErpApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'SmartERP',
      theme: AppTheme.light,
      routerConfig: createAppRouter(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Bootstrap function for proper app initialization
/// Handles Firebase initialization with duplicate prevention
Future<void> bootstrap() async {
  // Ensure Flutter binding is initialized first
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase only if no apps exist
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('Firebase initialized successfully');
    } else {
      debugPrint('Firebase already initialized, skipping...');
    }
    
    // Configure Firestore settings for offline persistence
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    
    // Run app with proper error handling
    runApp(
      const ProviderScope(
        child: SmartErpApp(),
      ),
    );
  } catch (e, stackTrace) {
    debugPrint('Fatal error during initialization: $e');
    debugPrint('Stack trace: $stackTrace');
    
    // Show error screen on initialization failure
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Failed to initialize SmartERP',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Please check your internet connection and try again.',
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Retry initialization
                    bootstrap();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  bootstrap();
}
