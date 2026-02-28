# SmartERP Testing Strategy

**Version:** 1.0  
**Date:** February 2026  
**Status:** Production  
**Coverage Target:** > 80% overall

---

## 1. Testing Philosophy

### 1.1 Testing Principles

| Principle | Implementation |
|-----------|---------------|
| **Shift Left** | Testing starts at unit level, catches defects early |
| **Test Pyramid** | 70% unit, 20% widget, 10% integration |
| **Automated First** | All critical paths automated, manual only for UX |
| **Business Value** | Tests verify requirements, not implementation details |
| **Fast Feedback** | Unit tests < 100ms, full suite < 5 minutes |

### 1.2 Testing Pyramid

```
                    /\
                   /  \
                  / E2E\         5% - Critical user journeys
                 /______\         (Integration tests with Firebase Emulator)
                /        \
               /  Widget  \      25% - Screen/widget interactions
              /    Tests    \     (Widget testing with Riverpod)
             /______________\
            /                \
           /    Unit Tests     \   70% - Business logic, calculations
          /   (Domain Layer)    \  (Pure Dart, fast, isolated)
         /______________________\
```

### 1.3 Testing Coverage Targets

| Layer | Target | Minimum | Critical Areas |
|-------|--------|---------|----------------|
| **Domain/Business Logic** | 90% | 85% | GST calc, stock logic, profit calc |
| **Data/Repositories** | 80% | 75% | All CRUD operations |
| **Presentation/Widgets** | 75% | 70% | Forms, validation, user flows |
| **Integration** | 60% | 50% | Critical end-to-end paths |
| **Overall** | 80% | 80% | Combined weighted average |

---

## 2. Testing Layers

### 2.1 Unit Testing

#### Scope
- Business logic calculations
- Entity validation
- Repository interfaces (with mocks)
- Utility functions
- State management logic

#### Example: GST Calculator Test

```dart
// test/domain/calculations/gst_calculator_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_erp/domain/calculations/gst_calculator.dart';

void main() {
  group('GSTCalculator', () {
    group('calculate', () {
      test('should calculate GST correctly for 18%', () {
        // Arrange
        const amount = 1000.0;
        const gstRate = 18;
        
        // Act
        final result = GstCalculator.calculate(amount, gstRate);
        
        // Assert
        expect(result.baseAmount, equals(1000.0));
        expect(result.cgst, equals(90.0));
        expect(result.sgst, equals(90.0));
        expect(result.totalAmount, equals(1180.0));
      });
      
      test('should calculate GST correctly for 5%', () {
        const amount = 250.0;
        const gstRate = 5;
        
        final result = GstCalculator.calculate(amount, gstRate);
        
        expect(result.cgst, equals(6.25));
        expect(result.sgst, equals(6.25));
        expect(result.totalAmount, equals(262.50));
      });
      
      test('should handle zero GST', () {
        const amount = 500.0;
        const gstRate = 0;
        
        final result = GstCalculator.calculate(amount, gstRate);
        
        expect(result.cgst, equals(0.0));
        expect(result.sgst, equals(0.0));
        expect(result.totalAmount, equals(500.0));
      });
    });
    
    group('calculateForInvoice', () {
      test('should handle multiple line items', () {
        final lineItems = [
          InvoiceLineItem(amount: 1000, gstRate: 18),
          InvoiceLineItem(amount: 500, gstRate: 12),
        ];
        
        final result = GstCalculator.calculateForInvoice(lineItems);
        
        expect(result.subtotal, equals(1500.0));
        expect(result.totalCgst, equals(75.0)); // 90 + 30 / 2 (approx)
      });
    });
  });
}
```

#### Example: Stock Calculator Test

```dart
// test/domain/calculations/stock_calculator_test.dart

void main() {
  group('StockCalculator', () {
    group('calculateNewStock', () {
      test('should reduce stock on sale', () {
        final result = StockCalculator.calculateNewStock(
          currentStock: 100,
          quantity: 5,
          operation: StockOperation.sale,
        );
        
        expect(result, equals(95));
      });
      
      test('should increase stock on purchase', () {
        final result = StockCalculator.calculateNewStock(
          currentStock: 50,
          quantity: 20,
          operation: StockOperation.purchase,
        );
        
        expect(result, equals(70));
      });
    });
    
    group('hasSufficientStock', () {
      test('should return true when stock is sufficient', () {
        expect(
          StockCalculator.hasSufficientStock(100, 50),
          isTrue,
        );
      });
      
      test('should return false when stock is insufficient', () {
        expect(
          StockCalculator.hasSufficientStock(10, 15),
          isFalse,
        );
      });
      
      test('should return true when stock equals requested', () {
        expect(
          StockCalculator.hasSufficientStock(10, 10),
          isTrue,
        );
      });
    });
  });
}
```

### 2.2 Widget Testing

#### Scope
- Screen rendering
- User interactions (taps, inputs)
- Form validation
- Navigation
- State changes (Riverpod providers)

#### Example: Product List Screen Test

```dart
// test/features/products/presentation/screens/product_list_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_erp/domain/entities/product.dart';
import 'package:smart_erp/domain/repositories/product_repository.dart';
import 'package:smart_erp/features/products/presentation/screens/product_list_screen.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository mockRepository;
  
  setUp(() {
    mockRepository = MockProductRepository();
  });
  
  group('ProductListScreen', () {
    testWidgets('should display loading indicator initially', 
        (WidgetTester tester) async {
      // Arrange
      when(() => mockRepository.watchAll(any()))
          .thenAnswer((_) => Stream.value([]));
      
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: const MaterialApp(
            home: ProductListScreen(),
          ),
        ),
      );
      
      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    
    testWidgets('should display products when loaded', 
        (WidgetTester tester) async {
      // Arrange
      final products = [
        Product(id: '1', name: 'Widget A', hsnCode: '1234', 
                gstRate: 18, price: 100, stock: 50, unit: 'PCS',
                createdAt: DateTime.now(), updatedAt: DateTime.now()),
        Product(id: '2', name: 'Widget B', hsnCode: '5678',
                gstRate: 12, price: 200, stock: 30, unit: 'PCS',
                createdAt: DateTime.now(), updatedAt: DateTime.now()),
      ];
      
      when(() => mockRepository.watchAll(any()))
          .thenAnswer((_) => Stream.value(products));
      
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: const MaterialApp(
            home: ProductListScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Widget A'), findsOneWidget);
      expect(find.text('Widget B'), findsOneWidget);
    });
    
    testWidgets('should show low stock indicator', 
        (WidgetTester tester) async {
      // Arrange
      final lowStockProduct = Product(
        id: '1',
        name: 'Low Stock Item',
        hsnCode: '1234',
        gstRate: 18,
        price: 100,
        stock: 5, // Below threshold
        unit: 'PCS',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      when(() => mockRepository.watchAll(any()))
          .thenAnswer((_) => Stream.value([lowStockProduct]));
      
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: const MaterialApp(
            home: ProductListScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.byIcon(Icons.warning), findsOneWidget);
      expect(find.text('Low Stock'), findsOneWidget);
    });
    
    testWidgets('should navigate to add product on FAB tap', 
        (WidgetTester tester) async {
      // Arrange
      when(() => mockRepository.watchAll(any()))
          .thenAnswer((_) => Stream.value([]));
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            home: const ProductListScreen(),
            routes: {
              '/products/add': (context) => 
                  const Scaffold(body: Text('Add Product')),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      // Act
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Add Product'), findsOneWidget);
    });
  });
}
```

#### Example: Form Validation Test

```dart
// test/features/products/presentation/forms/product_form_test.dart

void main() {
  group('ProductForm', () {
    testWidgets('should show error when name is empty', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductForm(
              onSubmit: (_) {},
            ),
          ),
        ),
      );
      
      // Submit empty form
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      expect(find.text('Name is required'), findsOneWidget);
    });
    
    testWidgets('should show error when HSN code is invalid', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductForm(
              onSubmit: (_) {},
            ),
          ),
        ),
      );
      
      // Enter invalid HSN
      await tester.enterText(find.byKey(const Key('hsn_field')), '12');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      expect(find.text('HSN must be 4-8 digits'), findsOneWidget);
    });
    
    testWidgets('should submit when all fields are valid', 
        (WidgetTester tester) async {
      Product? submittedProduct;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductForm(
              onSubmit: (product) => submittedProduct = product,
            ),
          ),
        ),
      );
      
      // Fill valid data
      await tester.enterText(find.byKey(const Key('name_field')), 'Test Product');
      await tester.enterText(find.byKey(const Key('hsn_field')), '1234');
      await tester.enterText(find.byKey(const Key('price_field')), '100');
      await tester.enterText(find.byKey(const Key('stock_field')), '50');
      
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      expect(submittedProduct, isNotNull);
      expect(submittedProduct!.name, equals('Test Product'));
    });
  });
}
```

### 2.3 Integration Testing

#### Scope
- End-to-end user flows
- Firebase interactions (with emulator)
- Complete business workflows
- Data persistence across screens

#### Example: Invoice Creation Flow

```dart
// test/integration/invoice_creation_test.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smart_erp/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Invoice Creation Flow', () {
    testWidgets('complete invoice creation', (WidgetTester tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();
      
      // Login (assuming test account exists)
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Navigate to Sales
      await tester.tap(find.byIcon(Icons.receipt));
      await tester.pumpAndSettle();
      
      // Tap create invoice
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      
      // Fill customer details
      await tester.enterText(
        find.byKey(const Key('customer_name')),
        'Test Customer',
      );
      await tester.enterText(
        find.byKey(const Key('customer_address')),
        '123 Test Street',
      );
      
      // Add line item
      await tester.tap(find.byKey(const Key('add_item_button')));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(const Key('product_selector')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Widget A'));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byKey(const Key('quantity')), '5');
      await tester.pumpAndSettle();
      
      // Verify totals
      expect(find.text('₹590.00'), findsOneWidget); // 500 + 18% GST
      
      // Generate invoice
      await tester.tap(find.byKey(const Key('generate_invoice')));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Verify success
      expect(find.text('Invoice generated successfully'), findsOneWidget);
    });
  });
}
```

---

## 3. Firestore Rule Testing

### 3.1 Test Setup

```javascript
// test/firestore_rules_test.js

const firebase = require('@firebase/testing');
const fs = require('fs');

const projectId = 'smarterp-test';

beforeAll(async () => {
  await firebase.loadFirestoreRules({
    projectId,
    rules: fs.readFileSync('firestore.rules', 'utf8'),
  });
});

beforeEach(async () => {
  await firebase.clearFirestoreData({ projectId });
});

afterAll(async () => {
  await Promise.all(firebase.apps().map(app => app.delete()));
});

function authedApp(auth) {
  return firebase.initializeTestApp({
    projectId,
    auth,
  }).firestore();
}
```

### 3.2 Security Rules Tests

```javascript
// test/firestore_security_test.js

describe('Firestore Security Rules', () => {
  describe('User isolation', () => {
    it('should allow users to read their own data', async () => {
      const db = authedApp({ uid: 'user123' });
      const userDoc = db.collection('users').doc('user123');
      
      await firebase.assertSucceeds(userDoc.get());
    });
    
    it('should deny users from reading other users data', async () => {
      const db = authedApp({ uid: 'user123' });
      const otherUserDoc = db.collection('users').doc('user456');
      
      await firebase.assertFails(otherUserDoc.get());
    });
    
    it('should deny unauthenticated access', async () => {
      const db = authedApp(null);
      const userDoc = db.collection('users').doc('user123');
      
      await firebase.assertFails(userDoc.get());
    });
  });
  
  describe('Product operations', () => {
    it('should allow creating valid products', async () => {
      const db = authedApp({ uid: 'user123' });
      const product = {
        name: 'Test Product',
        hsnCode: '1234',
        gstRate: 18,
        price: 100,
        stock: 50,
        unit: 'PCS',
        isActive: true,
      };
      
      await firebase.assertSucceeds(
        db.collection('users/user123/products').add(product)
      );
    });
    
    it('should deny products with invalid data', async () => {
      const db = authedApp({ uid: 'user123' });
      const invalidProduct = {
        name: 'A', // Too short
        hsnCode: '12', // Too short
        price: -10, // Negative
      };
      
      await firebase.assertFails(
        db.collection('users/user123/products').add(invalidProduct)
      );
    });
  });
  
  describe('Invoice immutability', () => {
    it('should allow creating invoices', async () => {
      const db = authedApp({ uid: 'user123' });
      const invoice = {
        invoiceNumber: 'INV-2025-00001',
        customer: { name: 'Customer', address: 'Address' },
        totalAmount: 1000,
        createdAt: firebase.firestore.FieldValue.serverTimestamp(),
      };
      
      await firebase.assertSucceeds(
        db.collection('users/user123/sales').add(invoice)
      );
    });
    
    it('should deny updating invoices', async () => {
      const db = authedApp({ uid: 'user123' });
      
      // Create invoice first
      const invoiceRef = await db.collection('users/user123/sales').add({
        invoiceNumber: 'INV-2025-00001',
        customer: { name: 'Customer', address: 'Address' },
        totalAmount: 1000,
        createdAt: firebase.firestore.FieldValue.serverTimestamp(),
      });
      
      // Try to update
      await firebase.assertFails(
        invoiceRef.update({ totalAmount: 2000 })
      );
    });
  });
});
```

---

## 4. Edge Case Testing

### 4.1 Business Logic Edge Cases

```dart
// test/edge_cases/business_logic_edge_cases_test.dart

void main() {
  group('Edge Cases - GST Calculation', () {
    test('should handle very large amounts', () {
      final result = GstCalculator.calculate(999999.99, 28);
      expect(result.totalAmount, greaterThan(999999.99));
    });
    
    test('should handle very small amounts', () {
      final result = GstCalculator.calculate(0.01, 18);
      expect(result.totalAmount, greaterThan(0));
    });
    
    test('should handle zero amount', () {
      final result = GstCalculator.calculate(0, 18);
      expect(result.totalAmount, equals(0));
    });
  });
  
  group('Edge Cases - Stock Management', () {
    test('should handle maximum stock values', () {
      final result = StockCalculator.calculateNewStock(
        currentStock: 999999,
        quantity: 1,
        operation: StockOperation.sale,
      );
      expect(result, equals(999998));
    });
    
    test('should prevent negative stock', () {
      expect(
        () => StockCalculator.calculateNewStock(
          currentStock: 0,
          quantity: 1,
          operation: StockOperation.sale,
        ),
        throwsA(isA<InsufficientStockException>()),
      );
    });
  });
  
  group('Edge Cases - Invoice Numbering', () {
    test('should handle year rollover', () {
      final now = DateTime(2025, 3, 31); // March 31
      final number = InvoiceNumberService.generate(now);
      expect(number, equals('INV-2024-XXXXX'));
      
      final nextDay = DateTime(2025, 4, 1); // April 1 (new fiscal year)
      final nextNumber = InvoiceNumberService.generate(nextDay);
      expect(nextNumber, equals('INV-2025-00001'));
    });
    
    test('should handle large invoice counts', () {
      final number = InvoiceNumberService.generateWithCounter(
        DateTime.now(),
        99999,
      );
      expect(number, equals('INV-2025-99999'));
    });
  });
}
```

### 4.2 Offline Scenarios

```dart
// test/edge_cases/offline_scenarios_test.dart

void main() {
  group('Offline Scenarios', () {
    test('should queue invoice when offline', () async {
      final syncManager = SyncManager(
        localDb: mockLocalDb,
        connectivity: mockOfflineConnectivity,
      );
      
      final invoice = createTestInvoice();
      await syncManager.saveInvoice(invoice);
      
      // Verify queued locally
      verify(() => mockLocalDb.queueOperation(any())).called(1);
    });
    
    test('should sync queued operations when back online', () async {
      final syncManager = SyncManager(
        localDb: mockLocalDb,
        firestore: mockFirestore,
        connectivity: mockOnlineConnectivity,
      );
      
      // Add pending operations
      when(() => mockLocalDb.getPendingOperations())
          .thenAnswer((_) async => [pendingInvoiceOp, pendingProductOp]);
      
      await syncManager.processQueue();
      
      // Verify sync occurred
      verify(() => mockFirestore.createInvoice(any())).called(1);
      verify(() => mockFirestore.updateProduct(any())).called(1);
    });
    
    test('should handle sync conflicts', () async {
      // Server has newer version
      final serverInvoice = Invoice(id: '1', totalAmount: 1000);
      final localInvoice = Invoice(id: '1', totalAmount: 1200);
      
      // Server wins
      final resolved = ConflictResolver.resolve(
        local: localInvoice,
        server: serverInvoice,
        strategy: ResolutionStrategy.serverWins,
      );
      
      expect(resolved.totalAmount, equals(1000));
    });
  });
}
```

---

## 5. Testing Folder Structure

```
test/
├── unit/
│   ├── core/
│   │   ├── utils/
│   │   └── extensions/
│   │
│   ├── domain/
│   │   ├── calculations/
│   │   │   ├── gst_calculator_test.dart
│   │   │   ├── stock_calculator_test.dart
│   │   │   └── profit_calculator_test.dart
│   │   │
│   │   ├── entities/
│   │   │   ├── product_test.dart
│   │   │   ├── invoice_test.dart
│   │   │   └── expense_test.dart
│   │   │
│   │   └── value_objects/
│   │       ├── date_range_test.dart
│   │       └── money_test.dart
│   │
│   └── data/
│       ├── repositories/
│       │   ├── product_repository_impl_test.dart
│       │   ├── invoice_repository_impl_test.dart
│       │   └── expense_repository_impl_test.dart
│       │
│       └── models/
│           └── (model conversion tests)
│
├── widget/
│   ├── core/
│   │   └── (shared widget tests)
│   │
│   └── features/
│       ├── auth/
│       │   ├── login_screen_test.dart
│       │   └── register_screen_test.dart
│       │
│       ├── products/
│       │   ├── product_list_screen_test.dart
│       │   ├── add_product_screen_test.dart
│       │   └── product_form_test.dart
│       │
│       ├── sales/
│       │   ├── invoice_list_screen_test.dart
│       │   ├── create_invoice_screen_test.dart
│       │   └── invoice_form_test.dart
│       │
│       ├── dashboard/
│       │   └── dashboard_screen_test.dart
│       │
│       └── shared/
│           ├── buttons_test.dart
│           ├── inputs_test.dart
│           └── cards_test.dart
│
├── integration/
│   ├── auth_flow_test.dart
│   ├── product_crud_test.dart
│   ├── invoice_creation_test.dart
│   └── offline_sync_test.dart
│
├── edge_cases/
│   ├── business_logic_edge_cases_test.dart
│   ├── offline_scenarios_test.dart
│   ├── performance_edge_cases_test.dart
│   └── data_corruption_recovery_test.dart
│
├── firestore_rules/
│   └── (JavaScript test files)
│
├── fixtures/
│   ├── products.json
│   ├── invoices.json
│   └── test_data.dart
│
├── helpers/
│   ├── test_helpers.dart
│   ├── mock_providers.dart
│   └── golden_file_helper.dart
│
└── test_runner.dart
```

---

## 6. Test Utilities & Helpers

### 6.1 Mock Providers

```dart
// test/helpers/mock_providers.dart

import 'package:mocktail/mocktail.dart';
import 'package:smart_erp/domain/repositories/product_repository.dart';
import 'package:smart_erp/domain/repositories/invoice_repository.dart';

class MockProductRepository extends Mock implements ProductRepository {}
class MockInvoiceRepository extends Mock implements InvoiceRepository {}
class MockExpenseRepository extends Mock implements ExpenseRepository {}
class MockEmployeeRepository extends Mock implements EmployeeRepository {}

// Provider overrides for testing
List<Override> createMockOverrides({
  ProductRepository? productRepository,
  InvoiceRepository? invoiceRepository,
}) {
  return [
    if (productRepository != null)
      productRepositoryProvider.overrideWithValue(productRepository),
    if (invoiceRepository != null)
      invoiceRepositoryProvider.overrideWithValue(invoiceRepository),
  ];
}
```

### 6.2 Test Data Builders

```dart
// test/helpers/test_data.dart

class ProductBuilder {
  String id = 'test-id';
  String name = 'Test Product';
  String hsnCode = '1234';
  int gstRate = 18;
  double price = 100;
  int stock = 50;
  String unit = 'PCS';
  
  ProductBuilder withId(String id) {
    this.id = id;
    return this;
  }
  
  ProductBuilder withName(String name) {
    this.name = name;
    return this;
  }
  
  ProductBuilder withStock(int stock) {
    this.stock = stock;
    return this;
  }
  
  Product build() {
    return Product(
      id: id,
      name: name,
      hsnCode: hsnCode,
      gstRate: gstRate,
      price: price,
      stock: stock,
      unit: unit,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

// Usage in tests
final testProduct = ProductBuilder()
    .withName('Widget A')
    .withStock(100)
    .build();
```

---

## 7. Running Tests

### 7.1 Commands

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html
# Then open coverage/html/index.html

# Run specific test file
flutter test test/domain/calculations/gst_calculator_test.dart

# Run tests matching pattern
flutter test --name="GST"

# Run widget tests only
flutter test test/widget

# Run integration tests
flutter test integration_test/invoice_creation_test.dart

# Run with verbose output
flutter test --verbose

# Watch mode (re-run on file changes)
flutter test --watch
```

### 7.2 CI/CD Integration

```yaml
# .github/workflows/test.yml

name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        
      - name: Get dependencies
        run: flutter pub get
        
      - name: Run unit tests
        run: flutter test --coverage
        
      - name: Check coverage threshold
        run: |
          COVERAGE=$(lcov --summary coverage/lcov.info | grep "lines" | awk '{print $2}' | tr -d '%')
          if (( $(echo "$COVERAGE < 80" | bc -l) )); then
            echo "Coverage $COVERAGE% is below 80% threshold"
            exit 1
          fi
        
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info
```

---

## 8. Performance Testing

### 8.1 Benchmark Tests

```dart
// test/performance/calculation_performance_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_erp/domain/calculations/gst_calculator.dart';

void main() {
  group('Performance Tests', () {
    test('GST calculation should complete in < 1ms', () async {
      const iterations = 10000;
      final stopwatch = Stopwatch()..start();
      
      for (var i = 0; i < iterations; i++) {
        GstCalculator.calculate(1000.0, 18);
      }
      
      stopwatch.stop();
      final averageMs = stopwatch.elapsedMilliseconds / iterations;
      
      expect(averageMs, lessThan(1.0));
    });
    
    test('Invoice total calculation should complete in < 10ms for 50 items', 
        () async {
      final lineItems = List.generate(50, (i) => 
        InvoiceLineItem(amount: 100 * (i + 1), gstRate: 18),
      );
      
      final stopwatch = Stopwatch()..start();
      GstCalculator.calculateForInvoice(lineItems);
      stopwatch.stop();
      
      expect(stopwatch.elapsedMilliseconds, lessThan(10));
    });
  });
}
```

---

**End of Document**
