# SmartERP Production-Grade Implementation Guide

## Architecture Overview

This document describes the complete production-ready real-time persistent data system for SmartERP Flutter application.

## 📁 Folder Structure

```
lib/
├── features/
│   ├── products/
│   │   ├── domain/
│   │   │   ├── entities/ (ProductEntity)
│   │   │   ├── repositories/ (ProductRepository - abstract)
│   │   │   └── usecases/
│   │   ├── data/
│   │   │   ├── models/ (ProductModel - with JSON serialization)
│   │   │   ├── datasources/ (ProductFirestoreDataSource)
│   │   │   └── repositories/ (ProductRepositoryImpl - Firestore implementation)
│   │   └── presentation/
│   │       ├── pages/ (ProductListScreen - Real-time UI)
│   │       └── providers/ (Riverpod providers & StreamProviders)
│   │
│   ├── invoices/
│   │   ├── domain/
│   │   │   ├── entities/ (InvoiceEntity, InvoiceItemEntity)
│   │   │   ├── repositories/ (InvoiceRepository)
│   │   │   └── usecases/ (CreateInvoiceWithPdfUseCase)
│   │   ├── data/
│   │   │   ├── models/ (InvoiceModel with nested items)
│   │   │   ├── datasources/ (InvoiceFirestoreDataSource)
│   │   │   └── repositories/ (InvoiceRepositoryImpl)
│   │   └── presentation/
│   │       ├── pages/ (InvoiceListScreen)
│   │       └── providers/ (Riverpod invoice providers)
│   │
│   ├── sales/ ├── expense/
│   ├── payroll/
│   └── reports/
│
├── core/
│   ├── services/
│   │   ├── pdf/ (InvoicePdfService - PDF generation)
│   │   └── firestore/
│   ├── error/ (exceptions.dart - Error handling)
│   ├── utils/ (ui_utils.dart - UI helpers)
│   └── providers/ (Global Riverpod providers)
```

## 🏗️ Key Architecture Patterns

### 1. **Clean Architecture** (Domain → Data → Presentation)
- **Domain Layer**: Business logic, entities, abstract repositories
- **Data Layer**: Models, Firestore datasources, repository implementations
- **Presentation Layer**: UI, providers, state management

### 2. **Dependency Injection via Riverpod**
```dart
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final dataSource = ref.watch(productFirestoreDataSourceProvider);
  return ProductRepositoryImpl(dataSource);
});
```

### 3. **Real-Time Streams**
All list screens use `StreamProvider` for automatic UI updates:
```dart
final allProductsStreamProvider = StreamProvider<List<ProductEntity>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getAllProductsStream(); // Real-time Firestore listener
});
```

## 📊 Firestore Collections Structure

### Products Collection
```
/products/{productId}
  - name: string
  - description: string
  - price: number
  - quantity: number
  - sku: string
  - category: string
  - gstPercentage: number
  - tax: number
  - hsn: string
  - active: boolean
  - createdAt: timestamp
  - updatedAt: timestamp
```

### Invoices Collection
```
/invoices/{invoiceId}
  - invoiceNumber: string
  - customerId: string
  - customerName: string
  - customerEmail: string
  - customerPhone: string
  - items: array [
      {
        productId: string,
        productName: string,
        quantity: number,
        unitPrice: number,
        taxRate: number,
        total: number
      }
    ]
  - subtotal: number
  - taxAmount: number
  - totalAmount: number
  - status: string (draft|sent|paid|overdue)
  - notes: string
  - invoiceDate: timestamp
  - dueDate: timestamp
  - pdfUrl: string
  - createdAt: timestamp
  - updatedAt: timestamp
```

### Settings Collection (Counter for Invoice Numbers)
```
/settings/nextInvoiceNumber
  - number: integer (incremented for each invoice)
```

## 🔄 Real-Time Data Flow

```
┌─────────────────────┐
│  Firestore Update   │
└──────────┬──────────┘
           │
           │ Real-time listener
           ↓
┌──────────────────────────┐
│ StreamProvider watches   │
│ repository.getStream()   │
└──────────┬───────────────┘
           │
           ↓
┌──────────────────────────┐
│ UI ConsumerWidget        │
│ asyncValue.when()        │
│ automatically rebuilds   │
└──────────────────────────┘
```

## 📝 How to Use

### Example 1: Display Real-Time Products List

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/products/presentation/pages/product_list_screen.dart';

// In your router or app:
ProductListScreen() // Automatically gets real-time updates from Firestore
```

### Example 2: Create Invoice with PDF

```dart
import 'features/invoices/domain/usecases/create_invoice_usecase.dart';
import 'features/invoices/presentation/providers/invoice_providers.dart';

// In your provider/controller:
final useCase = CreateInvoiceWithPdfUseCase(
  invoiceRepository: ref.watch(invoiceRepositoryProvider),
  productRepository: ref.watch(productRepositoryProvider),
);

final invoice = await useCase(
  customerId: 'cust123',
  customerName: 'John Doe',
  customerEmail: 'john@example.com',
  customerPhone: '1234567890',
  items: [
    (productId: 'prod1', quantity: 2),
    (productId: 'prod2', quantity: 1),
  ],
  notes: 'Payment due in 30 days',
);

// PDF is automatically generated and saved locally
```

### Example 3: Search Products in Real-Time

```dart
final searchQuery = StateProvider<String>((ref) => '');

final searchedProductsProvider = FutureProvider<List<ProductEntity>>((ref) {
  final query = ref.watch(searchQuery);
  if (query.isEmpty) return [];
  
  final repository = ref.watch(productRepositoryProvider);
  return repository.searchProducts(query);
});

// In UI:
ref.watch(searchedProductsProvider).when(
  data: (products) => ListView(children: [...]),
  loading: () => CircularProgressIndicator(),
  error: (err, st) => ErrorWidget(),
);
```

## 🔐 Firestore Security Rules

All operations are protected by security rules in `firestore.rules`:
- ✅ Only authenticated users can read/write
- ✅ Single-user mode (all users share same data)
- ✅ Automatic timestamp validation
- ✅ Data structure validation

## 📈 Performance Optimization

### 1. Composite Indexes
Defined in `firestore.indexes.json` for:
- Products: `(category, active, createdAt)`
- Products: `(quantity, createdAt)` - for low stock alerts
- Invoices: `(status, invoiceDate)`
- Invoices: `(customerId, invoiceDate)`

### 2. Pagination
```dart
future<List<ProductEntity>> getProductsPaginated({
  required int page,
  required int pageSize,
}) // Limits data transfer
```

### 3. Selective Field Queries
Only fetch needed data, not entire documents.

### 4. Local Caching
Firestore offline persistence enabled:
```dart
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

## ✅ Data Persistence

All data persists permanently because:
1. **Firestore Cloud Storage** - Data stored in cloud
2. **Offline Persistence** - Local cache of data
3. **Real-time Sync** - Automatic synchronization when online
4. **No Session Loss** - Data survives app restart

Example flow:
```
App Launch → Load from Cloud ↔ Firestore
                    ↓
            Offline Persistence Cache
                    ↓
            Display to User (always has data)
```

## 🎨 UI State Management

### Loading State
Shows spinner while fetching from Firestore:
```dart
asyncValue.when(
  loading: () => LoadingWidget(),
  ...
)
```

### Empty State
Shows friendly message when no data:
```dart
if (data.isEmpty) {
  EmptyStateWidget(
    title: 'No products found',
    icon: Icons.inventory_2_outlined,
  );
}
```

### Error State
Shows error with retry option:
```dart
asyncValue.when(
  error: (error, st) => ErrorWidget(
    title: 'Error loading products',
    description: error.toString(),
    onRetry: () => ref.refresh(allProductsStreamProvider),
  ),
  ...
)
```

## 🐛 Error Handling

Custom exception classes in `core/error/exceptions.dart`:
```dart
try {
  await repository.createProduct(product);
} on FirestoreException catch (e) {
  showErrorSnackbar(context, e.message);
}
```

## 📦 Models vs Entities

- **Entity** (Domain): Pure business logic, no serialization
- **Model** (Data): Contains JSON serialization for Firestore

```dart
// Entity (domain layer)
class ProductEntity {
  final String id;
  final String name;
}

// Model (data layer)  
class ProductModel extends ProductEntity {
  factory ProductModel.fromFirestore(DocumentSnapshot doc) { ... }
  factory ProductModel.fromMap(Map<String, dynamic> map) { ... }
  Map<String, dynamic> toMap() { ... }
  ProductEntity toEntity() { ... }
}
```

## 🚀 Deployment Checklist

- [ ] Firestore security rules deployed
- [ ] Firestore composite indexes created
- [ ] Firebase Authentication enabled (Email/Password)
- [ ] Offline persistence enabled
- [ ] PDF generation tested
- [ ] Real-time streams verified
- [ ] Error handling tested
- [ ] Build app: `flutter build windows --release`

## 📚 Testing Real-Time Updates

1. Open app showing products list
2. Add product in Firestore Console
3. Watch UI update automatically (no refresh needed)
4. Modify product in Console
5. UI updates in real-time
6. Delete product in Console
7. Product disappears from list

This confirms real-time Firestore streams are working!

## 🔗 File References

- Product Models: `lib/features/products/data/models/product_model.dart`
- Invoice Models: `lib/features/invoices/data/models/invoice_model.dart`
- Firestore Datasources: `lib/features/*/data/datasources/*_firestore_datasource.dart`
- Repository Implementations: `lib/features/*/data/repositories/*_repository_impl.dart`
- Riverpod Providers: `lib/features/*/presentation/providers/*_providers.dart`
- PDF Service: `lib/core/services/pdf/invoice_pdf_service.dart`
- Example Screens: `lib/features/*/presentation/pages/*_screen.dart`
- Security Rules: `firestore.rules`
- Composite Indexes: `firestore.indexes.json`

---

**Status**: Production-ready ✅
**Last Updated**: March 2, 2026
**API Level**: Dart 3.4+, Flutter 3.4+
