import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../../core/services/firebase_service.dart';

/// Service for managing Firebase Storage operations
/// Handles product image uploads with proper error handling
/// Uses Uint8List for cross-platform compatibility (web+desktop+mobile)
class StorageService {
  static final StorageService _instance = StorageService._internal();
  
  factory StorageService() => _instance;
  StorageService._internal();

  late final FirebaseStorage _storage;
  bool _initialized = false;

  /// Initialize Firebase Storage
  void initialize(FirebaseService firebaseService) {
    if (_initialized) return;
    
    _storage = FirebaseStorage.instance;
    _initialized = true;
    debugPrint('StorageService: Initialized successfully');
  }

  /// Upload product image to Firebase Storage using bytes
  /// Returns download URL on success
  Future<String?> uploadProductImage(String productId, Uint8List imageBytes, String fileName) async {
    try {
      if (!_initialized) {
        throw StateError('StorageService not initialized');
      }

      // Check file size (max 5MB)
      const maxFileSize = 5 * 1024 * 1024; // 5MB
      if (imageBytes.length > maxFileSize) {
        throw ArgumentError('Image file size must be less than 5MB');
      }

      // Validate file type
      final lowerFileName = fileName.toLowerCase();
      final validExtensions = ['.jpg', '.jpeg', '.png'];
      final hasValidExtension = validExtensions.any((ext) => lowerFileName.endsWith(ext));
      
      if (!hasValidExtension) {
        throw ArgumentError('Invalid image format. Supported formats: JPG, JPEG, PNG');
      }

      // Create unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExtension = lowerFileName.split('.').last;
      final storageFileName = 'products/$productId/$timestamp.$fileExtension';

      // Upload bytes
      final uploadTask = _storage
          .ref()
          .child(storageFileName)
          .putData(imageBytes, SettableMetadata(contentType: 'image/$fileExtension'));

      // Wait for upload completion
      final snapshot = await uploadTask;
      
      if (snapshot.state == TaskState.success) {
        final downloadUrl = await snapshot.ref.getDownloadURL();
        debugPrint('StorageService: Upload completed: $downloadUrl');
        return downloadUrl;
      } else {
        throw FirebaseException(
          plugin: 'firebase_storage',
          message: 'Upload task did not complete successfully',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('StorageService: Error uploading image: $e');
      debugPrint('StorageService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Delete old product image from Firebase Storage
  Future<void> deleteProductImage(String imageUrl) async {
    try {
      if (!_initialized) {
        throw StateError('StorageService not initialized');
      }

      if (imageUrl.isEmpty) return;

      // Only delete Firebase Storage URLs
      if (!imageUrl.startsWith('http')) return;

      // Extract file path from URL
      final ref = _storage.refFromURL(imageUrl);
      
      // Check if file exists and delete
      try {
        await ref.getDownloadURL();
        await ref.delete();
        debugPrint('StorageService: Deleted old image: $imageUrl');
      } catch (e) {
        debugPrint('StorageService: Error deleting old image (may not exist): $e');
      }
    } catch (e, stackTrace) {
      debugPrint('StorageService: Error deleting image: $e');
      debugPrint('StorageService: Stack trace: $stackTrace');
      // Don't rethrow for deletion failures
    }
  }

  /// Get download URL for existing image
  Future<String?> getImageUrl(String imagePath) async {
    try {
      if (!_initialized) {
        throw StateError('StorageService not initialized');
      }

      // Already a URL
      if (imagePath.startsWith('http')) {
        return imagePath;
      }

      return null;
    } catch (e) {
      debugPrint('StorageService: Error getting image URL: $e');
      return null;
    }
  }
}
