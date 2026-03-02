# SmartERP - Desktop ERP Management System

<div align="center">

![Status](https://img.shields.io/badge/Status-Active%20Development-brightgreen)
![Flutter](https://img.shields.io/badge/Flutter-3.4%2B-blue?logo=flutter)
![License](https://img.shields.io/badge/License-Private-red)
![Platform](https://img.shields.io/badge/Platform-Windows%20Desktop-0071C5?logo=windows)

*A lightweight, cloud-connected Enterprise Resource Planning (ERP) system built with Flutter and Firebase*

[Features](#key-features) • [Quick Start](#getting-started) • [Architecture](#architecture) • [Project Structure](#project-structure) • [Contributing](#contributing)

</div>

---

## 📋 Table of Contents

- [Overview](#overview)
- [Why SmartERP?](#why-smarterp)
- [Key Features](#key-features)
- [What It Does](#what-it-does)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Setup & Installation](#setup--installation)
- [Development](#development)
- [Firebase Configuration](#firebase-configuration-setup)
- [Contributing](#contributing)
- [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

**SmartERP** is a modern, lightweight Enterprise Resource Planning (ERP) system designed for small to medium-sized businesses. Built with Flutter for Windows Desktop and backed by Firebase, SmartERP combines the power of cloud computing with the flexibility of local-first architecture.

This is a **single-user, client-heavy ERP application** that leverages Firebase Spark tier for cost-effective backend operations, with intelligent offline capabilities and real-time cloud synchronization.

### Key Highlights
- 🖥️ **Windows Desktop Focused** - Optimized for fast, responsive desktop experience
- ☁️ **Cloud-Connected** - Firebase backend for reliable data storage
- 📱 **Modern UI** - Material Design 3 with smooth animations
- 🔄 **Offline Support** - Works seamlessly online and offline
- 🔐 **Secure Authentication** - Firebase Auth integration
- ⚡ **Performance Optimized** - Lightweight footprint with Firebase Spark tier

---

## 💡 Why SmartERP?

### Problems It Solves

1. **Complex Manual Processes**
   - Eliminate spreadsheet chaos and manual data entry
   - Streamline repetitive business operations
   - Reduce human errors in critical business processes

2. **Expensive Enterprise Solutions**
   - Traditional ERP systems are costly and over-engineered
   - SmartERP is lightweight and affordable
   - Firebase Spark tier provides cost-effective cloud storage

3. **Disconnected Business Operations**
   - Single source of truth for all business data
   - Real-time reporting and analytics
   - Better decision-making with accurate data

4. **Accessibility Issues**
   - Accessible desktop application without complex server setup
   - No IT infrastructure burden
   - Easy to deploy and maintain

### How SmartERP Makes Life Easier

✅ **Saves Time** - Automate invoicing, expense tracking, and payroll
✅ **Reduces Costs** - Eliminate expensive third-party tools and spreadsheet maintenance
✅ **Improves Accuracy** - Centralized data with automatic validations and calculations
✅ **Enhances Visibility** - Real-time dashboards and comprehensive reports
✅ **Increases Efficiency** - Integrated workflows reduce context switching
✅ **Ensures Scalability** - Cloud-backed architecture grows with your business
✅ **Simple to Use** - Intuitive interface requires minimal training
✅ **Works Offline** - Continue working even without internet connectivity

---

## 🚀 Key Features

### Core Modules

#### 👤 **Authentication**
- Secure user authentication with Firebase Auth
- Role-based access control (RBAC)
- Session management and security features

#### 📊 **Dashboard**
- Executive overview with key metrics
- Real-time data visualization
- Quick access to critical business information

#### 💰 **Expense Management**
- Track and categorize business expenses
- Receipt attachment and documentation
- Expense approval workflows
- Financial insights and analysis

#### 📄 **Invoice Management**
- Create and manage sales invoices
- Customizable invoice templates
- Payment tracking and reminders
- Invoice PDF generation and export

#### 💼 **Sales Management**
- Sales order creation and tracking
- Customer management
- Sales analytics and forecasts
- Commission calculations

#### 🛍️ **Product Management**
- Inventory tracking and management
- Product categorization
- Stock level monitoring
- Supplier information management

#### 📦 **Purchase Management**
- Purchase order creation and tracking
- Vendor management
- Purchase analytics
- Receipt and delivery documentation

#### 💵 **Payroll Management**
- Employee salary management
- Payroll processing
- Deductions and allowances tracking
- Payroll slip generation

#### 📈 **Reports & Analytics**
- Comprehensive business reports
- Chart visualizations (Sales, Expenses, Inventory)
- Data export to PDF and CSV
- Custom report generation

#### ⚙️ **Settings**
- System configuration
- User preferences
- Data export/import
- System maintenance tools

---

## 🛠️ What It Does

### Daily Operations

```
Morning → Dashboard check → Review overnight changes
↓
Employee → Expense tracking → Approval workflow
↓
Sales Team → Create invoices → Track payments
↓
Procurement → Manage purchase orders → Track deliveries
↓
Finance → Run payroll → Generate reports
↓
EOD → System backup → Data sync to cloud
```

### Core Processes

1. **Data Entry & Management** - Create and update business transactions
2. **Workflow Automation** - Automate approvals and routing
3. **Real-time Sync** - Automatic cloud synchronization
4. **Offline Operation** - Continue working without internet
5. **Report Generation** - Create PDF/CSV reports on demand
6. **Data Backup** - Automatic Firebase cloud backup

---

## 🏗️ Project Structure

```
try1/
├── lib/
│   ├── main.dart                 # Application entry point
│   ├── app.dart                  # Main app widget configuration
│   ├── firebase_options.dart     # Firebase configuration
│   │
│   ├── core/                     # Core application layer
│   │   ├── bootstrap/            # Bootstrap & initialization
│   │   ├── constants/            # App-wide constants
│   │   ├── error/                # Error handling
│   │   ├── providers/            # Global Riverpod providers
│   │   ├── router/               # Route configuration
│   │   ├── services/             # Core services
│   │   ├── theme/                # Theme & styling
│   │   └── utils/                # Utility functions
│   │
│   ├── data/                     # Data layer
│   │   ├── datasources/          # Remote & local data sources
│   │   ├── models/               # Data models with JSON serialization
│   │   └── repositories/         # Data repository implementations
│   │
│   ├── domain/                   # Domain layer (Business logic)
│   │   ├── entities/             # Business entities
│   │   ├── repositories/         # Abstract repository interfaces
│   │   └── usecases/             # Business use cases
│   │
│   ├── features/                 # Feature modules
│   │   ├── auth/                 # Authentication feature
│   │   │   ├── presentation/
│   │   │   ├── data/
│   │   │   └── domain/
│   │   ├── dashboard/            # Dashboard feature
│   │   ├── expense/              # Expense management
│   │   ├── invoice/              # Invoice management
│   │   ├── payroll/              # Payroll management
│   │   ├── products/             # Product management
│   │   ├── purchase/             # Purchase management
│   │   ├── reports/              # Reports & analytics
│   │   ├── sales/                # Sales management
│   │   └── settings/             # Application settings
│   │
│   ├── shared/                   # Shared resources
│   │   ├── providers/            # Shared state providers
│   │   └── widgets/              # Reusable widgets
│   │
│   └── widgets/                  # Common UI components
│
├── assets/                       # Static assets
│   ├── fonts/
│   ├── icons/
│   └── images/
│
├── android/                      # Android native code (future)
├── ios/                          # iOS native code (future)
├── windows/                      # Windows desktop configuration
├── web/                          # Web support (future)
│
├── test/                         # Test files
│   └── widget_test.dart
│
├── pubspec.yaml                  # Flutter dependencies
├── firebase.json                 # Firebase configuration
├── firestore.rules               # Firestore security rules
├── firestore.indexes.json        # Firestore composite indexes
├── analysis_options.yaml         # Dart lint rules
└── README.md                     # This file

```

### Architecture Pattern: Clean Architecture + MVVM

```
Presentation (UI) ← States Services (Riverpod)
        ↓
State Management (Riverpod)
        ↓
Domain (Business Logic) ← Use Cases
        ↓
Data (Repositories) ← Models & Data Sources
        ↓
Firebase / Local Storage
```

---

## 🔧 Tech Stack

### Frontend Framework
- **Flutter 3.4+** - Cross-platform UI framework
- **Material Design 3** - Modern UI components

### State Management
- **Flutter Riverpod 2.5+** - Reactive state management
- **Riverpod Generator** - Code generation for providers

### Navigation
- **GoRouter 14.6+** - Advanced routing and deep linking

### Backend & Database
- **Firebase Core 3.8+** - Firebase integration
- **Firebase Authentication 5.3+** - Secure authentication
- **Cloud Firestore 5.6+** - Cloud-hosted NoSQL database
- **Firebase Storage 12.3+** - File storage for documents & images

### Data Persistence
- **Shared Preferences 2.3+** - Local key-value storage
- **Path Provider 2.1+** - File system access
- **Image Picker 1.0+** - Media selection
- **File Picker 8.1+** - File system browsing

### Features & Utilities
- **PDF Generation** - pdf (3.11.1) & printing (5.13.4)
- **Charts** - fl_chart (0.69.0) for data visualization
- **CSV Export** - csv (6.0.0) for data export
- **Internationalization** - intl (0.19.0)
- **Fonts** - google_fonts (5.0.0)
- **Animations** - flutter_animate (4.0.0)
- **Connectivity** - connectivity_plus (6.0.5) for offline detection
- **URL Launcher** - url_launcher (6.3.0)

### Development Tools
- **Flutter Lints 6.0+** - Code quality rules
- **Build Runner 2.4+** - Code generation
- **Mocktail 1.0+** - Testing utilities

---

## 🏛️ Architecture

### Layered Architecture

```
┌─────────────────────────────────────┐
│     PRESENTATION LAYER              │
│  ├─ Pages & UI Widgets              │
│  ├─ State Management (Riverpod)     │
│  └─ Navigation (GoRouter)           │
└────────────────┬──────────────────┘
                 │
┌─────────────────┴──────────────────┐
│     DOMAIN LAYER                    │
│  ├─ Entities (Business Models)      │
│  ├─ Repositories (Interfaces)       │
│  └─ Use Cases (Business Logic)      │
└────────────────┬──────────────────┘
                 │
┌─────────────────┴──────────────────┐
│     DATA LAYER                      │
│  ├─ Models (DTOs)                   │
│  ├─ Data Sources (Remote/Local)     │
│  ├─ Repositories (Implementation)   │
│  └─ Mappers (Entity ↔ Model)        │
└────────────────┬──────────────────┘
                 │
┌─────────────────┴──────────────────┐
│     INFRASTRUCTURE                  │
│  ├─ Firebase Services              │
│  ├─ Local Storage                   │
│  └─ Network (Connectivity)          │
└─────────────────────────────────────┘
```

### State Management with Riverpod

- **StateNotifier Providers** - Mutable state management
- **FutureProvider** - Async data handling
- **StreamProvider** - Real-time data streams
- **Family Modifiers** - Parameterized providers

---

## 📦 Getting Started

### Prerequisites

- **Flutter SDK** 3.4.0 or higher
- **Dart SDK** compatible with Flutter 3.4+
- **Windows OS** (Primary target platform)
- **Firebase Account** with Spark tier or higher
- **Visual Studio Code** or **Android Studio** with Flutter extension

### Quick Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd try1
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   ```bash
   # Follow the Firebase setup section below
   ```

4. **Run the application**
   ```bash
   flutter run -d windows
   ```

---

## 🚀 Setup & Installation

### Step 1: Environment Setup

```bash
# Verify Flutter installation
flutter --version

# Check Flutter Doctor
flutter doctor

# Ensure Windows desktop is enabled
flutter config --enable-windows-desktop
```

### Step 2: Project Setup

```bash
# Navigate to project directory
cd try1

# Get all dependencies
flutter pub get

# Generate code from annotations
flutter pub run build_runner build
```

### Step 3: Firebase Configuration

See [Firebase Configuration Setup](#firebase-configuration-setup) section below.

### Step 4: Run Application

```bash
# Development mode
flutter run -d windows

# Release mode (optimized)
flutter run -d windows --release

# Profile mode (performance testing)
flutter run -d windows --profile
```

---

## 🛠️ Development

### Project Setup

```bash
# Install dependencies
flutter pub get

# Generate code
flutter pub run build_runner build

# Watch mode (auto-regenerate on changes)
flutter pub run build_runner watch
```

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

### Code Quality

```bash
# Analyze code
flutter analyze

# Format code
dart format lib/

# Sort imports
dart run import_sorter:main
```

### Build Application

```bash
# Debug build
flutter build windows --debug

# Release build
flutter build windows --release
```

---

## 🔐 Firebase Configuration Setup

### Prerequisites
- Firebase Console Account
- Project with Firestore enabled
- Authentication methods configured

### Configuration Steps

#### 1. Firebase Project Creation

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in project
firebase init
```

#### 2. Enable Services in Firebase Console

- ✅ Firebase Authentication (Email/Password)
- ✅ Cloud Firestore
- ✅ Firebase Storage
- ✅ Firestore Rules

#### 3. Google Services Configuration

Update `google-services.json` in `android/app/` with your Firebase project credentials.

#### 4. Firestore Security Rules

Deploy security rules from `firestore.rules`:

```bash
firebase deploy --only firestore:rules
```

#### 5. Firestore Indexes

Deploy indexes from `firestore.indexes.json`:

```bash
firebase deploy --only firestore:indexes
```

#### 6. Verify Configuration

```bash
firebase emulators:start --only firestore
```

---

## 📋 Firestore Databases Structure

### Collections

```
users/
├── uid/
│   ├── email: string
│   ├── displayName: string
│   ├── role: string (admin/user/viewer)
│   └── createdAt: timestamp

expenses/
├── expenseId/
│   ├── userId: string
│   ├── amount: double
│   ├── category: string
│   ├── receipts: array
│   ├── status: string (pending/approved)
│   └── createdAt: timestamp

invoices/
├── invoiceId/
│   ├── userId: string
│   ├── customerId: string
│   ├── items: array
│   ├── totalAmount: double
│   ├── status: string
│   └── createdAt: timestamp

payroll/
├── payrollId/
│   ├── employeeId: string
│   ├── salary: double
│   ├── deductions: array
│   ├── netAmount: double
│   ├── period: string
│   └── createdAt: timestamp
```

---

## 🤝 Contributing

### Development Workflow

1. **Create a branch** for your feature
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Follow code style**
   - Follow Dart Style Guide
   - Use meaningful variable names
   - Add comments for complex logic
   - Run `dart format` before committing

3. **Test your changes**
   ```bash
   flutter test
   flutter analyze
   ```

4. **Commit with clear messages**
   ```bash
   git commit -m "feat: Add expense category filtering"
   ```

5. **Push and create Pull Request**
   ```bash
   git push origin feature/your-feature-name
   ```

### Code Style Guidelines

```dart
// ✅ Good
const String apiEndpoint = 'https://api.example.com';
Future<void> fetchUserData() async { }

// ❌ Avoid
const String API_ENDPOINT = 'https://api.example.com';
Future fetchUserData() async { }
```

---

## ❓ Troubleshooting

### Common Issues

#### Firebase Initialization Error
```
Error: FirebaseException caught
```
**Solution:** Ensure `google-services.json` is in `android/app/` and Firebase apps list is checked before initialization.

#### Build Errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner build
```

#### Windows Desktop Build Issues
```bash
# Enable Windows desktop support
flutter config --enable-windows-desktop

# Run with verbose output
flutter run -v
```

#### Offline Functionality Not Working
**Solution:** Ensure Firestore offline persistence is enabled in `main.dart`:
```dart
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

#### State Not Updating
**Solution:** Use Riverpod `ConsumerWidget` or `Consumer` for reactive UI updates.

---

## 📚 Additional Resources

### Documentation
- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [Firebase Flutter Guide](https://firebase.google.com/docs/flutter/setup)
- [Clean Architecture in Flutter](https://resocoder.com/clean-architecture)
- [Material Design 3](https://m3.material.io/)

### Related Files
- [Phase 1 Deliverable](./PHASE1_DELIVERABLE.md)
- [Firebase Implementation Guide](./FIREBASE_STORAGE_COMPLETE_IMPLEMENTATION.md)
- [Firestore Refactoring Summary](./FIRESTORE_REFACTORING_SUMMARY.md)

---

## 📄 License

This project is **private and proprietary**. All rights reserved.

---

## 📞 Support

For issues, questions, or suggestions:
- 📧 Report bugs through GitHub Issues
- 💬 Discuss features via Pull Requests
- 📖 Check documentation first

---

## 🎯 Roadmap

### Phase 1 ✅
- [x] Authentication System
- [x] Dashboard with analytics
- [x] Invoice Management
- [x] Expense Tracking
- [x] Firebase Integration

### Phase 2 🔄
- [ ] Advanced Reporting
- [ ] Multi-user Support with Roles
- [ ] Inventory Management
- [ ] Supplier Portal
- [ ] Mobile App (iOS/Android)

### Phase 3 📅
- [ ] API Integration
- [ ] Custom Workflows
- [ ] Advanced Analytics
- [ ] Web Platform
- [ ] Batch Operations

---

<div align="center">

**Made for Efficient Business Management** 🚀

⭐ Star the repository if you find it useful!

</div>
