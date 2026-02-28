# SmartERP Environment & Development Setup

**Version:** 1.0  
**Date:** February 2026  
**Status:** Production  
**Platforms:** Android, iOS (limited), Web (optional)

---

## 1. Prerequisites

### 1.1 System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **Operating System** | Windows 10, macOS 11, Linux Ubuntu 20.04 | Windows 11, macOS 14, Ubuntu 22.04 |
| **Processor** | Intel i5 / AMD Ryzen 5 | Intel i7 / AMD Ryzen 7 |
| **Memory (RAM)** | 8 GB | 16 GB |
| **Storage** | 50 GB free SSD | 100 GB free SSD |
| **Internet** | 5 Mbps | 20+ Mbps |

### 1.2 Required Accounts

| Account | Purpose | Free Tier |
|---------|---------|-----------|
| **Google Account** | Firebase access, Play Console | Yes |
| **GitHub Account** | Source control, CI/CD | Yes |
| **Firebase Account** | Backend services | Yes (Spark Plan) |

---

## 2. Flutter Development Environment

### 2.1 Flutter SDK Installation

#### Step 1: Download Flutter

```bash
# macOS
brew install flutter

# Or download manually
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:$HOME/development/flutter/bin"

# Windows (PowerShell as Admin)
# Download from: https://docs.flutter.dev/get-started/install/windows
# Extract to C:\flutter
# Add to PATH: C:\flutter\bin

# Linux
sudo snap install flutter --classic
# Or download and extract to /usr/local/flutter
```

#### Step 2: Verify Installation

```bash
flutter doctor
flutter --version  # Should show 3.22.0 or higher
```

#### Step 3: Accept Licenses

```bash
flutter doctor --android-licenses
# Accept all licenses (y)
```

### 2.2 IDE Setup

#### VS Code (Recommended)

```bash
# Install extensions:
# 1. Dart
# 2. Flutter
# 3. Flutter Riverpod Snippets
# 4. Awesome Flutter Snippets
# 5. Dart Data Class Generator

# Settings (settings.json)
{
  "dart.flutterSdkPath": "/path/to/flutter",
  "dart.enableSdkFormatter": true,
  "dart.lineLength": 80,
  "editor.formatOnSave": true,
  "editor.rulers": [80],
  "files.exclude": {
    "**/.dart_tool": true,
    "**/.packages": true,
    "**/build": true
  }
}
```

#### Android Studio (Alternative)

```bash
# Install Flutter Plugin
# Install Dart Plugin
# Configure Flutter SDK path in settings
```

### 2.3 Android Setup

#### Install Android Studio

1. Download from: https://developer.android.com/studio
2. Install Android SDK Command Line Tools
3. Install Android SDK Build-Tools (latest)
4. Install Android SDK Platform-Tools
5. Install Android SDK Platform (API 34)
6. Create Android Emulator (Pixel 4, API 34)

#### Environment Variables

```bash
# macOS/Linux (add to ~/.zshrc or ~/.bashrc)
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin

# Windows (System Environment Variables)
ANDROID_HOME=C:\Users\<username>\AppData\Local\Android\Sdk
Add to PATH: %ANDROID_HOME%\platform-tools
```

#### Verify Android Setup

```bash
flutter doctor -v
# Should show:
# [✓] Flutter (Channel stable, 3.22.0)
# [✓] Android toolchain
# [✓] Android Studio
# [✓] Connected device
```

### 2.4 iOS Setup (macOS only)

```bash
# Install Xcode from App Store
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch

# Install CocoaPods
sudo gem install cocoapods
pod setup

# Install iOS Simulator
open -a Simulator
```

---

## 3. Firebase Setup

### 3.1 Create Firebase Project

1. Go to https://console.firebase.google.com
2. Click "Create Project"
3. Enter project name: `smarterp-factory`
4. Disable Google Analytics (for free tier)
5. Create project

### 3.2 Register App

#### Android

```bash
# In Firebase Console:
# 1. Click Android icon (</>)
# 2. Package name: com.smarterp.factory
# 3. App nickname: SmartERP
# 4. Download google-services.json
# 5. Move to: android/app/google-services.json

# Add to android/build.gradle:
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}

# Add to android/app/build.gradle:
apply plugin: 'com.google.gms.google-services'
```

#### iOS (Optional)

```bash
# In Firebase Console:
# 1. Click iOS icon
# 2. Bundle ID: com.smarterp.factory
# 3. Download GoogleService-Info.plist
# 4. Move to: ios/Runner/GoogleService-Info.plist

# Run in ios directory:
pod install
```

### 3.3 Enable Firebase Services

| Service | Enable | Configuration |
|---------|--------|---------------|
| **Authentication** | Email/Password | Enable in Console |
| **Firestore** | Create database | Start in production mode |
| **Storage** | Default bucket | Default rules |
| **App Check** | Optional | For production hardening |

### 3.4 Firebase CLI (Optional)

```bash
# Install Firebase CLI
curl -sL https://firebase.tools | bash

# Login
firebase login

# Initialize in project (for rules deployment)
cd smarterp/
firebase init
# Select: Firestore, Storage, Emulators
```

---

## 4. Project Setup

### 4.1 Clone Repository

```bash
git clone https://github.com/yourorg/smarterp.git
cd smarterp
```

### 4.2 Install Dependencies

```bash
flutter pub get
```

### 4.3 Core Dependencies (pubspec.yaml)

```yaml
name: smart_erp
description: SmartERP Factory Management System
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.4.0 <4.0.0'
  flutter: '>=3.22.0'

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  
  # Navigation
  go_router: ^14.0.0
  
  # Firebase
  firebase_core: ^2.30.0
  firebase_auth: ^4.19.0
  cloud_firestore: ^4.17.0
  firebase_storage: ^11.7.0
  
  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.1.3
  
  # PDF Generation
  pdf: ^3.10.7
  printing: ^5.12.0
  
  # Charts
  fl_chart: ^0.68.0
  
  # Utilities
  intl: ^0.19.0
  equatable: ^2.0.5
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0
  
  # Network
  connectivity_plus: ^6.0.0
  
  # Security
  flutter_secure_storage: ^9.2.0
  
  # UI
  shimmer: ^3.0.0
  flutter_slidable: ^3.1.0
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  
  # Code Generation
  build_runner: ^2.4.9
  freezed: ^2.5.2
  json_serializable: ^6.8.0
  riverpod_generator: ^2.4.0
  
  # Testing
  mockito: ^5.4.4
  mocktail: ^1.0.3
  
flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/fonts/
    
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
```

### 4.4 Environment Configuration

#### .env File (Add to .gitignore)

```bash
# .env
FIREBASE_API_KEY=your_api_key
FIREBASE_APP_ID=your_app_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
FIREBASE_STORAGE_BUCKET=your_project.appspot.com
FIREBASE_MEASUREMENT_ID=G-XXXXXXXXXX

# App Configuration
APP_NAME=SmartERP
APP_VERSION=1.0.0
ENABLE_ANALYTICS=false
ENABLE_CRASHLYTICS=false
```

#### Environment Class

```dart
// lib/core/constants/environment.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get firebaseApiKey =>
      dotenv.env['FIREBASE_API_KEY'] ?? '';
  
  static String get firebaseProjectId =>
      dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  
  static bool get isDevelopment => 
      const bool.fromEnvironment('dart.vm.product') == false;
  
  static bool get isProduction =>
      const bool.fromEnvironment('dart.vm.product') == true;
}
```

---

## 5. Debug vs Release Configuration

### 5.1 Debug Configuration

```dart
// lib/main.dart - Debug entry point

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_erp/app.dart';
import 'package:smart_erp/core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment
  await dotenv.load(fileName: '.env');
  
  // Initialize logging
  Logger.enableDebugLogging();
  
  // Initialize Firebase with debug settings
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Enable Firestore offline persistence
  await FirebaseFirestore.instance.enablePersistence(
    const PersistenceSettings(synchronizeTabs: true),
  );
  
  // Run app with ProviderScope
  runApp(
    ProviderScope(
      observers: [LoggerProviderObserver()],
      child: const SmartErpApp(),
    ),
  );
}
```

### 5.2 Release Configuration

```dart
// lib/main_production.dart - Release entry point

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_erp/app.dart';
import 'package:smart_erp/core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Disable debug logging in production
  Logger.disableDebugLogging();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Run app
  runApp(
    const ProviderScope(
      child: SmartErpApp(),
    ),
  );
}
```

### 5.3 Android Build Configurations

```gradle
// android/app/build.gradle

android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.smarterp.factory"
        minSdkVersion 24
        targetSdkVersion 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }
    
    buildTypes {
        debug {
            signingConfig signingConfigs.debug
            minifyEnabled false
            shrinkResources false
            debuggable true
        }
        
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
    
    flavorDimensions "environment"
    
    productFlavors {
        development {
            dimension "environment"
            applicationIdSuffix ".dev"
            resValue "string", "app_name", "SmartERP Dev"
        }
        
        production {
            dimension "environment"
            resValue "string", "app_name", "SmartERP"
        }
    }
}
```

### 5.4 iOS Build Configurations (macOS only)

```bash
# Build commands

# Debug
flutter run --debug

# Profile
flutter run --profile

# Release
flutter run --release

# With flavors
flutter run --flavor development --target lib/main.dart
flutter run --flavor production --target lib/main_production.dart
```

---

## 6. Free-Tier Safeguards

### 6.1 Firebase Quota Monitoring

```dart
// lib/core/utils/quota_monitor.dart

class QuotaMonitor {
  static int _dailyReads = 0;
  static int _dailyWrites = 0;
  static final DateTime _startOfDay = DateTime.now();
  
  // Free tier limits
  static const int _maxDailyReads = 40000; // 80% of 50K
  static const int _maxDailyWrites = 16000; // 80% of 20K
  
  static void trackRead(int count = 1) {
    _dailyReads += count;
    _checkThresholds();
  }
  
  static void trackWrite(int count = 1) {
    _dailyWrites += count;
    _checkThresholds();
  }
  
  static void _checkThresholds() {
    if (_dailyReads > _maxDailyReads) {
      Logger.warning('Firebase read quota approaching limit');
    }
    if (_dailyWrites > _maxDailyWrites) {
      Logger.warning('Firebase write quota approaching limit');
    }
  }
  
  static Map<String, int> get currentUsage => {
    'reads': _dailyReads,
    'writes': _dailyWrites,
  };
  
  static void resetIfNewDay() {
    final now = DateTime.now();
    if (now.day != _startOfDay.day) {
      _dailyReads = 0;
      _dailyWrites = 0;
    }
  }
}
```

### 6.2 Cost-Optimized Firebase Rules

```javascript
// firestore.rules - Optimized for free tier

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Limit query size to reduce read costs
    function queryLimitNotExceeded() {
      return request.query.limit <= 100;
    }
    
    // User data with optimized access
    match /users/{userId}/{document=**} {
      allow read: if request.auth != null 
        && request.auth.uid == userId
        && queryLimitNotExceeded();
        
      allow write: if request.auth != null 
        && request.auth.uid == userId;
    }
  }
}
```

### 6.3 Build Warnings

```dart
// lib/core/constants/quota_limits.dart

class QuotaLimits {
  static const int dailyReadLimit = 50000;
  static const int dailyWriteLimit = 20000;
  static const int storageLimitMB = 1024;
  
  static void validateAtBuild() {
    assert(() {
      // Warning in debug mode
      print('⚠️  FREE TIER LIMITS:');
      print('   - Daily reads: $dailyReadLimit');
      print('   - Daily writes: $dailyWriteLimit');
      print('   - Storage: ${storageLimitMB}MB');
      print('   Monitor at: https://console.firebase.google.com');
      return true;
    }());
  }
}
```

### 6.4 Cost Monitoring Dashboard

```dart
// lib/presentation/screens/admin/quota_dashboard.dart

class QuotaDashboard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usage = QuotaMonitor.currentUsage;
    
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Usage')),
      body: ListView(
        children: [
          _buildUsageCard(
            'Daily Reads',
            usage['reads']!,
            QuotaLimits.dailyReadLimit,
            Colors.blue,
          ),
          _buildUsageCard(
            'Daily Writes',
            usage['writes']!,
            QuotaLimits.dailyWriteLimit,
            Colors.green,
          ),
        ],
      ),
    );
  }
  
  Widget _buildUsageCard(String title, int used, int limit, Color color) {
    final percentage = (used / limit * 100).toStringAsFixed(1);
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: used / limit,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(color),
            ),
            const SizedBox(height: 8),
            Text('$used / $limit ($percentage%)'),
          ],
        ),
      ),
    );
  }
}
```

---

## 7. Development Workflow

### 7.1 Branch Strategy

```
main                    # Production releases
  ├── develop           # Integration branch
  │     ├── feature/PROD-001-product-list
  │     ├── feature/INV-002-invoice-creation
  │     └── feature/DASH-001-dashboard-charts
  ├── hotfix/1.0.1      # Emergency fixes
  └── release/1.0.0     # Release preparation
```

### 7.2 Commit Convention

```bash
# Format: <type>(<scope>): <subject>

feat(product): add product list screen
fix(invoice): correct GST calculation bug
doc(api): update repository contracts
test(auth): add login flow widget tests
refactor(core): simplify navigation logic
perf(cache): optimize product list caching
```

### 7.3 Development Commands

```bash
# Run in debug mode
flutter run

# Run with hot reload
flutter run --hot

# Run tests
flutter test

# Run with coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Analyze code
flutter analyze

# Format code
dart format .

# Build APK (debug)
flutter build apk --debug

# Build APK (release)
flutter build apk --release

# Build App Bundle for Play Store
flutter build appbundle --release

# Clean build
flutter clean
flutter pub get
```

### 7.4 Code Generation

```bash
# Run all generators
flutter pub run build_runner build

# Watch for changes (auto-generate)
flutter pub run build_runner watch

# Delete conflicting outputs
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 8. Troubleshooting

### 8.1 Common Issues

#### Firebase Connection Issues

```bash
# Clear Firebase cache
flutter clean
rm -rf ios/Pods ios/Podfile.lock
rm -rf android/.gradle

# Reinstall dependencies
flutter pub get
cd ios && pod install && cd ..

# Check Firebase configuration
flutter doctor
```

#### Build Failures

```bash
# Gradle issues (Android)
cd android
./gradlew clean
./gradlew build

# CocoaPods issues (iOS)
cd ios
pod deintegrate
pod install --repo-update
```

#### Dependency Conflicts

```bash
# Update dependencies
flutter pub outdated
flutter pub upgrade

# Resolve conflicts manually in pubspec.yaml
# Then:
flutter pub get
```

### 8.2 Debug Tools

| Tool | Command | Purpose |
|------|---------|---------|
| Flutter Inspector | `flutter run` + IDE | Widget tree inspection |
| DevTools | `flutter pub global activate devtools` | Performance profiling |
| Network Inspector | Built into DevTools | API call monitoring |
| Performance Overlay | `flutter run --profile` | FPS monitoring |

---

## 9. CI/CD Pipeline

### 9.1 GitHub Actions Workflow

```yaml
# .github/workflows/ci.yml

name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.0'
          channel: 'stable'
      
      - name: Get dependencies
        run: flutter pub get
      
      - name: Analyze
        run: flutter analyze
      
      - name: Format check
        run: dart format --set-exit-if-changed .
      
      - name: Run tests
        run: flutter test
      
      - name: Build APK
        run: flutter build apk --debug
```

---

**End of Document**
