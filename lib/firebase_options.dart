import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    } 
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD4khHbGTlfsYgtX7sRKzhd2GpBt80BHqc',
    appId: '1:598420514811:web:968870654fdf2d9c830d5e',
    messagingSenderId: '598420514811',
    projectId: 'smarterp-1510',
    authDomain: 'smarterp-1510.firebaseapp.com',
    storageBucket: 'smarterp-1510.firebasestorage.app',
    measurementId: 'G-1QN5EB2ST8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCEPl3nvbD50VUWKtx3AzsQ4ZcSLFztHTM',
    appId: '1:598420514811:android:3e67c6d5132d1057830d5e',
    messagingSenderId: '598420514811',
    projectId: 'smarterp-1510',
    storageBucket: 'smarterp-1510.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAQETKBMmIsr_u-MY52fCOgXOknKefRhU4',
    appId: '1:598420514811:ios:9bf7efaa7b730380830d5e',
    messagingSenderId: '598420514811',
    projectId: 'smarterp-1510',
    storageBucket: 'smarterp-1510.firebasestorage.app',
    iosBundleId: 'com.example.try1',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD4khHbGTlfsYgtX7sRKzhd2GpBt80BHqc',
    appId: '1:598420514811:ios:968870654fdf2d9c830d5e',
    messagingSenderId: '598420514811',
    projectId: 'smarterp-1510',
    storageBucket: 'smarterp-1510.firebasestorage.app',
    iosBundleId: 'com.smarterp.factory',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD4khHbGTlfsYgtX7sRKzhd2GpBt80BHqc',
    appId: '1:598420514811:web:2279527a37f2530f830d5e',
    messagingSenderId: '598420514811',
    projectId: 'smarterp-1510',
    authDomain: 'smarterp-1510.firebaseapp.com',
    storageBucket: 'smarterp-1510.firebasestorage.app',
    measurementId: 'G-K75TBP9R9D',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyD4khHbGTlfsYgtX7sRKzhd2GpBt80BHqc',
    appId: '1:598420514811:web:968870654fdf2d9c830d5e',
    messagingSenderId: '598420514811',
    projectId: 'smarterp-1510',
    authDomain: 'smarterp-1510.firebaseapp.com',
    storageBucket: 'smarterp-1510.firebasestorage.app',
    measurementId: 'G-1QN5EB2ST8',
  );

}