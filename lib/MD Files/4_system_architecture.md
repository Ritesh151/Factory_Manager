# SmartERP System Architecture

**Version:** 1.0  
**Date:** February 2026  
**Status:** Production  
**Classification:** Internal

---

## 1. High-Level Architecture Overview

### 1.1 Architectural Goals

| Goal | Priority | Implementation |
|------|----------|----------------|
| Zero Operational Cost | Critical | Firebase Spark Plan |
| Client-Heavy Processing | Critical | Local business logic |
| Single User System | Critical | Simple auth, no multi-tenancy |
| Offline Capability | High | Firestore persistence |
| < 2 Second Response | High | Aggressive caching |
| Scalable Foundation | Medium | Modular architecture |

### 1.2 Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              CLIENT LAYER                                    │
│                    Flutter Application (Android/iOS)                         │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                         PRESENTATION                                  │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌───────────┐  │  │
│  │  │    UI       │  │   State     │  │ Navigation  │  │   Forms   │  │  │
│  │  │  Widgets    │  │  Riverpod   │  │  GoRouter   │  │ Validation│  │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └───────────┘  │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                    │                                         │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                          DOMAIN/BUSINESS                               │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌───────────┐  │  │
│  │  │  Invoice    │  │    GST      │  │   Stock     │  │  Profit   │  │  │
│  │  │ Calculation │  │ Calculation │  │   Logic     │  │    Calc   │  │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └───────────┘  │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌───────────┐  │  │
│  │  │  PDF Gen    │  │   Export    │  │   Reports   │  │   Utils   │  │  │
│  │  │  (Offline)  │  │  CSV/PDF    │  │ Aggregation │  │ Helpers   │  │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └───────────┘  │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                    │                                         │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                            DATA LAYER                                  │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌───────────┐  │  │
│  │  │ Repository  │  │   Local     │  │    Sync     │  │   Cache   │  │  │
│  │  │  Pattern    │  │ Persistence │  │   Engine    │  │  Manager  │  │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └───────────┘  │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
└────────────────────────────────────┬───────────────────────────────────────┘
                                     │
                                     │ HTTPS / gRPC
                                     │
┌────────────────────────────────────▼───────────────────────────────────────┐
│                         FIREBASE BACKEND (Spark Plan)                        │
│                                                                              │
│  ┌──────────────────────┐  ┌──────────────────────┐  ┌────────────────┐  │
│  │  FIRESTORE DATABASE  │  │   FIREBASE STORAGE   │  │ FIREBASE AUTH  │  │
│  │                      │  │                      │  │                │  │
│  │  • users/{uid}/      │  │  • invoice_pdfs/     │  │ • Email/Pass   │  │
│  │  • products/         │  │  • logos/            │  │ • Secure Token │  │
│  │  • sales/            │  │  • exports/          │  │ • Session Mgmt │  │
│  │  • purchases/        │  │                      │  │                │  │
│  │  • expenses/         │  │                      │  │                │  │
│  │  • employees/        │  │                      │  │                │  │
│  │                      │  │                      │  │                │  │
│  │  Rules: User Isolation│  │  Rules: User Scoped  │  │ Free Tier      │  │
│  └──────────────────────┘  └──────────────────────┘  └────────────────┘  │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────┐    │
│  │                    FIREBASE SECURITY RULES                          │    │
│  │  ┌──────────────────────────────────────────────────────────────┐  │    │
│  │  │  match /users/{userId}/{document=**} {                       │  │    │
│  │  │    allow read, write: if request.auth != null &&              │  │    │
│  │  │                          request.auth.uid == userId;          │  │    │
│  │  │  }                                                           │  │    │
│  │  └──────────────────────────────────────────────────────────────┘  │    │
│  └────────────────────────────────────────────────────────────────────┘    │
└────────────────────────────────────────────────────────────────────────────┘
```

### 1.3 Technology Stack

| Layer | Technology | Version | Purpose |
|-------|------------|---------|---------|
| **Framework** | Flutter | 3.22+ | Cross-platform UI |
| **Language** | Dart | 3.4+ | Application logic |
| **State Management** | Riverpod | 2.5+ | Reactive state |
| **Navigation** | GoRouter | 14.0+ | Declarative routing |
| **Database** | Cloud Firestore | Latest | Document storage |
| **Auth** | Firebase Auth | Latest | User authentication |
| **Storage** | Firebase Storage | Latest | File storage |
| **Local Cache** | Hive/Isar | Latest | Local persistence |
| **PDF Generation** | pdf package | Latest | Invoice PDFs |
| **Charts** | fl_chart | Latest | Analytics |
| **Connectivity** | connectivity_plus | Latest | Network detection |
| **DI** | Riverpod | 2.5+ | Dependency injection |

---

## 2. Layered Architecture Breakdown

### 2.1 Layer Responsibilities

```
┌─────────────────────────────────────────────────────────────────┐
│ Layer 4: PRESENTATION                                           │
│ ─────────────────────────────────────────────────────────────── │
│ • Widgets & UI Components                                       │
│ • Screen layouts & navigation                                   │
│ • Form validation & input handling                              │
│ • Riverpod state consumption                                    │
│ • Error boundaries & loading states                             │
├─────────────────────────────────────────────────────────────────┤
│ Layer 3: APPLICATION / DOMAIN                                   │
│ ─────────────────────────────────────────────────────────────── │
│ • Business logic & use cases                                    │
│ • Entity definitions                                            │
│ • Business rules validation                                     │
│ • Calculation engines (GST, Profit, Stock)                      │
│ • DTO to Entity mapping                                         │
├─────────────────────────────────────────────────────────────────┤
│ Layer 2: DATA / INFRASTRUCTURE                                  │
│ ─────────────────────────────────────────────────────────────── │
│ • Repository implementations                                    │
│ • Firestore data source                                         │
│ • Local cache data source                                       │
│ • Data synchronization                                          │
│ • Error handling & retry logic                                  │
├─────────────────────────────────────────────────────────────────┤
│ Layer 1: EXTERNAL SERVICES                                      │
│ ─────────────────────────────────────────────────────────────── │
│ • Firebase SDK                                                  │
│ • Local database (SQLite/Hive)                                  │
│ • File system (PDF storage)                                     │
│ • Network layer                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 Dependency Flow

```
         External Services
                │
                ▼
    ┌───────────────────────┐
    │    Data / Infra       │ ◄── Repository Pattern
    │    (implements)       │     Abstracts data source
    └───────────┬───────────┘
                │
                ▼
    ┌───────────────────────┐
    │   Domain / Business   │ ◄── Pure Dart, no dependencies
    │   (contains)          │     Contains core logic
    └───────────┬───────────┘
                │
                ▼
    ┌───────────────────────┐
    │    Presentation       │ ◄── Depends on domain, state mgmt
    │    (consumes)         │     UI layer only
    └───────────────────────┘
```

---

## 3. Client vs Backend Responsibility Matrix

### 3.1 Processing Distribution

| Function | Location | Reason |
|----------|----------|--------|
| **GST Calculation** | Client | Zero backend cost, instant |
| **Invoice Total** | Client | Real-time as user types |
| **Stock Updates** | Client | Immediate feedback |
| **Profit Calculation** | Client | No backend aggregation needed |
| **PDF Generation** | Client | Offline capable, no API cost |
| **Data Validation** | Client | Instant user feedback |
| **Dashboard Charts** | Client | Local computation |
| **CSV Export** | Client | Offline processing |
| **Invoice Numbering** | Client | No concurrency (single user) |
| **Auth State** | Backend | Firebase handles security |
| **Data Persistence** | Backend | Firestore for durability |
| **File Storage** | Backend | Firebase Storage |
| **Data Sync** | Backend | Firestore offline support |

### 3.2 Client-Side Processing Details

```dart
// lib/domain/calculations/gst_calculator.dart

class GstCalculator {
  static GstBreakdown calculate(double amount, double gstRate) {
    final gstAmount = (amount * gstRate) / 100;
    final cgst = gstAmount / 2;
    final sgst = gstAmount / 2;
    final total = amount + gstAmount;
    
    return GstBreakdown(
      baseAmount: amount,
      cgst: cgst,
      sgst: sgst,
      igst: gstAmount, // For inter-state
      totalAmount: total,
    );
  }
  
  static double calculateNetProfit({
    required double totalSales,
    required double totalPurchases,
    required double totalExpenses,
    required double totalSalary,
  }) {
    return totalSales - totalPurchases - totalExpenses - totalSalary;
  }
}

// lib/domain/calculations/stock_calculator.dart

class StockCalculator {
  static int calculateNewStock(int currentStock, int quantity, StockOperation operation) {
    switch (operation) {
      case StockOperation.sale:
        return currentStock - quantity;
      case StockOperation.purchase:
        return currentStock + quantity;
      case StockOperation.adjustment:
        return quantity; // Direct set
    }
  }
  
  static bool hasSufficientStock(int currentStock, int requestedQuantity) {
    return currentStock >= requestedQuantity;
  }
}
```

### 3.3 Backend Responsibility (Firestore)

| Responsibility | Implementation |
|---------------|----------------|
| Data Storage | Document-based, user-scoped |
| Authentication | Token-based, email/password |
| Access Control | Security rules per user |
| Offline Sync | Automatic, configurable |
| Backup | Firebase-managed daily |
| Scalability | Automatic sharding |

---

## 4. Real-Time Strategy

### 4.1 Real-Time Data Flow

```
┌────────────────────────────────────────────────────────────────┐
│                     REAL-TIME ARCHITECTURE                      │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│   ┌──────────────┐         ┌──────────────┐                   │
│   │   Firestore  │◄───────►│  Repository  │                   │
│   │   Snapshot   │  Stream │   Stream     │                   │
│   └──────────────┘         └──────┬───────┘                   │
│                                   │                            │
│                                   │ Stream<Model>               │
│                                   ▼                            │
│                           ┌──────────────┐                    │
│                           │   Riverpod   │                    │
│                           │   Provider   │                    │
│                           └──────┬───────┘                    │
│                                  │                           │
│                                  │ AsyncValue<Model>          │
│                                  ▼                           │
│                           ┌──────────────┐                    │
│                           │     UI       │                    │
│                           │   Consumer   │                    │
│                           └──────────────┘                    │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

### 4.2 Real-Time Usage Strategy

| Data Type | Real-Time | Strategy | Optimization |
|-----------|-----------|----------|--------------|
| Products | Yes | Stream on list screen | Cache in memory |
| Invoices | Conditional | Stream for current month | Pagination |
| Dashboard | No | Manual refresh + timer | Cache 5 min |
| Low Stock | Yes | Computed from product stream | Derived provider |
| GST Summary | No | Manual refresh | Cache 1 hour |
| Employee List | Yes | Stream | Small dataset |

### 4.3 Free Tier Optimization

| Technique | Implementation | Read Savings |
|-----------|---------------|--------------|
| Single Collection Stream | `collection.snapshots()` vs multiple | 60-80% |
| Local Filtering | Fetch once, filter in Dart | 50-70% |
| Aggressive Caching | Memory + Hive cache | 40-60% |
| Pagination | Limit 50, load more on scroll | 70-90% |
| Debounced Search | Wait 300ms before query | 30-50% |
| Background Sync | Batch updates when online | 20-40% |

---

## 5. Offline Strategy

### 5.1 Offline Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    OFFLINE STRATEGY                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    UI LAYER                              │   │
│  │  • Show cached data immediately                          │   │
│  │  • Disable actions requiring connectivity                │   │
│  │  • Queue modifications for sync                          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                            │                                    │
│                            ▼                                    │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                  SYNC LAYER                                │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐      │   │
│  │  │ Write Queue │  │  Conflict   │  │   Retry     │      │   │
│  │  │  (SQLite)   │  │ Resolution│  │   Logic     │      │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘      │   │
│  └─────────────────────────────────────────────────────────┘   │
│                            │                                    │
│            ┌───────────────┼───────────────┐                    │
│            ▼               ▼               ▼                   │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │
│  │   Local     │  │   Memory    │  │  Firestore  │            │
│  │   SQLite    │  │    Cache    │  │   (Online)  │            │
│  │  (Primary)   │  │  (Hot Data) │  │  (Backup)   │            │
│  └─────────────┘  └─────────────┘  └─────────────┘            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 5.2 Offline Capabilities Matrix

| Feature | Offline Read | Offline Write | Sync Priority |
|---------|--------------|---------------|---------------|
| View Products | Yes (Full) | N/A | Real-time |
| View Invoices | Yes (Last 100) | N/A | Background |
| Create Invoice | Yes | Queue | Immediate |
| Add Expense | Yes | Queue | Immediate |
| Add Purchase | Yes | Queue | Immediate |
| View Dashboard | Yes (Stale) | N/A | Background |
| PDF Generation | Yes | Local only | N/A |
| Export Data | Yes | Local only | N/A |
| Employee Management | Yes | Queue | Immediate |

### 5.3 Sync Strategy

```dart
// lib/data/sync/sync_manager.dart

class SyncManager {
  final LocalDatabase _localDb;
  final FirestoreDataSource _firestore;
  
  // Queue write operations when offline
  Future<void> queueWrite(SyncOperation operation) async {
    await _localDb.insertPendingOperation(operation);
    
    // Try immediate sync if online
    if (await _isOnline()) {
      await processQueue();
    }
  }
  
  // Process pending operations
  Future<void> processQueue() async {
    final pending = await _localDb.getPendingOperations();
    
    for (final operation in pending) {
      try {
        await _executeOperation(operation);
        await _localDb.markOperationComplete(operation.id);
      } catch (e) {
        // Retry with exponential backoff
        await _scheduleRetry(operation);
      }
    }
  }
  
  // Conflict resolution: Server wins
  Future<void> resolveConflict(SyncConflict conflict) async {
    final serverData = await _firestore.getDocument(conflict.path);
    await _localDb.updateDocument(conflict.localId, serverData);
  }
}
```

---

## 6. Security Model

### 6.1 Security Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     SECURITY LAYERS                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Layer 4: Application                                           │
│  • Input validation                                             │
│  • Business rule enforcement                                    │
│  • Secure storage (Android Keystore / iOS Keychain)             │
│                                                                 │
│  Layer 3: Transport                                             │
│  • TLS 1.3 encryption                                           │
│  • Certificate pinning (optional)                               │
│  • No sensitive data in URLs                                    │
│                                                                 │
│  Layer 2: Authentication                                        │
│  • Firebase Auth (Email/Password)                               │
│  • Secure token storage                                         │
│  • Session timeout (30 min idle)                                │
│  • Automatic logout on security event                           │
│                                                                 │
│  Layer 1: Database Access                                       │
│  • Firestore Security Rules                                     │
│  • User-scoped data access                                      │
│  • No cross-user data visibility                                │
│  • Validation on write                                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 6.2 Firestore Security Rules

```javascript
// firestore.rules

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    function isValidProduct() {
      return request.resource.data.keys().hasAll(['name', 'hsnCode', 'gstRate', 'price', 'stock'])
        && request.resource.data.name is string
        && request.resource.data.name.size() >= 2
        && request.resource.data.price is number
        && request.resource.data.price > 0
        && request.resource.data.stock is number
        && request.resource.data.stock >= 0;
    }
    
    function isValidInvoice() {
      return request.resource.data.keys().hasAll(['invoiceNumber', 'customerName', 'totalAmount', 'createdAt'])
        && request.resource.data.invoiceNumber is string
        && request.resource.data.totalAmount is number
        && request.resource.data.totalAmount > 0
        && request.resource.data.createdAt is timestamp;
    }
    
    // User data - strict isolation
    match /users/{userId} {
      allow read: if isOwner(userId);
      allow write: if isOwner(userId) 
        && request.resource.data.keys().hasAll(['businessName', 'createdAt']);
      
      // Products subcollection
      match /products/{productId} {
        allow read: if isOwner(userId);
        allow create, update: if isOwner(userId) && isValidProduct();
        allow delete: if isOwner(userId);
      }
      
      // Sales subcollection
      match /sales/{saleId} {
        allow read: if isOwner(userId);
        allow create: if isOwner(userId) && isValidInvoice();
        allow update, delete: if false; // Immutable after creation
      }
      
      // Purchases subcollection
      match /purchases/{purchaseId} {
        allow read: if isOwner(userId);
        allow create: if isOwner(userId);
        allow update: if isOwner(userId) 
          && resource.data.createdAt.toMillis() > request.time.toMillis() - 86400000; // 24h edit window
        allow delete: if isOwner(userId);
      }
      
      // Expenses subcollection
      match /expenses/{expenseId} {
        allow read: if isOwner(userId);
        allow create: if isOwner(userId);
        allow update: if isOwner(userId)
          && resource.data.createdAt.toMillis() > request.time.toMillis() - 86400000; // 24h edit window
        allow delete: if isOwner(userId);
      }
      
      // Employees subcollection
      match /employees/{employeeId} {
        allow read: if isOwner(userId);
        allow create, update: if isOwner(userId);
        allow delete: if isOwner(userId);
      }
    }
    
    // Deny all other access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

### 6.3 Data Encryption Strategy

| Data Type | Storage | Encryption | Key Management |
|-----------|---------|------------|----------------|
| Auth Token | Secure Storage | AES-256 | OS Keychain |
| Local DB | SQLite | SQLCipher | Device key |
| PDF Files | App Documents | None (user data) | N/A |
| Bank Details | Firestore | Server-side | Firebase |

---

## 7. Performance Strategy

### 7.1 Performance Targets

| Metric | Target | Measurement |
|--------|--------|-------------|
| App Launch | < 3 seconds | Cold start |
| Screen Transition | < 300ms | Navigation |
| Invoice Generation | < 2 seconds | End-to-end |
| PDF Generation | < 3 seconds | 10 items |
| Dashboard Load | < 1 second | With cache |
| Search Response | < 500ms | Product search |
| List Scroll | 60 FPS | Large lists |

### 7.2 Optimization Techniques

```dart
// 1. Lazy Loading
class PaginatedListNotifier<T> extends StateNotifier<AsyncValue<List<T>>> {
  final int pageSize = 50;
  DocumentSnapshot? lastDocument;
  bool hasMore = true;
  
  Future<void> loadMore() async {
    if (!hasMore) return;
    
    final query = FirebaseFirestore.instance
      .collection('users/${userId}/sales')
      .orderBy('createdAt', descending: true)
      .limit(pageSize);
    
    final snapshot = lastDocument != null
      ? await query.startAfterDocument(lastDocument!).get()
      : await query.get();
    
    hasMore = snapshot.docs.length == pageSize;
    if (snapshot.docs.isNotEmpty) {
      lastDocument = snapshot.docs.last;
    }
    
    // Append to existing state
    final newItems = snapshot.docs.map((d) => fromJson(d.data())).toList();
    state = AsyncValue.data([...(state.value ?? []), ...newItems]);
  }
}

// 2. Memory Cache
class ProductCache {
  final Map<String, Product> _cache = {};
  
  Product? get(String id) => _cache[id];
  
  void set(String id, Product product) => _cache[id] = product;
  
  void setAll(List<Product> products) {
    for (final p in products) {
      _cache[p.id] = p;
    }
  }
}

// 3. Debounced Search
final searchProvider = StateProvider<String>((ref) => '');

final debouncedSearchProvider = Provider<String>((ref) {
  final search = ref.watch(searchProvider);
  // Using Riverpod's built-in debouncing via autoDispose delay
  return search;
});

// 4. Image Optimization
class OptimizedImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      maxHeight: 200,
      maxWidth: 200,
      memCacheWidth: 200,
      placeholder: (context, url) => const CircularProgressIndicator(),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }
}
```

### 7.3 Firebase Free Tier Limits

| Resource | Free Tier | App Usage | Buffer |
|----------|-----------|-----------|--------|
| Reads | 50,000/day | < 15,000 | 70% |
| Writes | 20,000/day | < 8,000 | 60% |
| Deletes | 20,000/day | < 2,000 | 90% |
| Storage | 1 GB | < 500 MB | 50% |
| Bandwidth | 10 GB/month | < 3 GB | 70% |

---

## 8. Scalability Considerations

### 8.1 Current vs Future Architecture

| Aspect | Current (MVP) | Future (V2) |
|--------|---------------|-------------|
| Users | Single per device | Multiple per business |
| Sync | Real-time streams | Optimistic + background |
| Storage | Firestore only | Firestore + local archive |
| Processing | 100% client | Cloud Functions for heavy |
| Billing | Free tier | Blaze for multi-user |
| Offline | Basic queue | Full CRDT sync |

### 8.2 Extension Points

```dart
// Extension-ready repository pattern
abstract class ProductRepository {
  Stream<List<Product>> watchAll(String userId);
  Future<Product?> getById(String userId, String productId);
  Future<void> create(String userId, Product product);
  Future<void> update(String userId, Product product);
  Future<void> delete(String userId, String productId);
  
  // Extension point for future search
  Future<List<Product>> search(String userId, String query);
  
  // Extension point for bulk operations
  Future<void> batchUpdate(String userId, List<Product> products);
}
```

---

**End of Document**
