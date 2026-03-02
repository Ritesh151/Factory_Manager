# 📖 Technical API Reference

## Products Module - Complete API

### Domain Repository Interface
```dart
// Location: lib/features/products/domain/repositories/product_repository.dart

abstract class ProductRepository {
  // Real-time streams
  Stream<List<ProductEntity>> getAllProductsStream();
  Stream<List<ProductEntity>> getLowStockProductsStream({int threshold = 10});
  Stream<List<ProductEntity>> getProductsByCategoryStream(String category);
  
  // Async operations
  Future<ProductEntity> getProductById(String id);
  Future<List<ProductEntity>> getProductsPaginated({
    int page = 1,
    int pageSize = 20,
  });
  Future<List<ProductEntity>> searchProducts(String query);
  
  // CRUD
  Future<String> createProduct(ProductEntity product);
  Future<void> updateProduct(ProductEntity product);
  Future<void> deleteProduct(String id);
  
  // Bulk operations
  Future<void> updateProductStocks(List<({String id, int quantity})> updates);
}
```

**Copy-Paste Usage:**
```dart
// Get all products in real-time
final repository = ref.watch(productRepositoryProvider);
final products = await repository.getAllProductsStream().first;

// Get low stock alert
final lowStockStream = repository.getLowStockProductsStream(threshold: 5);
lowStockStream.listen((products) {
  print('Low stock: ${products.length} products');
});

// Search for laptop
final results = await repository.searchProducts('laptop');

// Get single product
final product = await repository.getProductById('prod-123');

// Update product
await repository.updateProduct(product.copyWith(quantity: 100));

// Batch update stocks (after invoice)
await repository.updateProductStocks([
  (id: 'prod-1', quantity: -2),
  (id: 'prod-2', quantity: -3),
]);
```

---

## Invoices Module - Complete API

### Domain Repository Interface
```dart
// Location: lib/features/invoices/domain/repositories/invoice_repository.dart

abstract class InvoiceRepository {
  // Real-time streams
  Stream<List<InvoiceEntity>> getAllInvoicesStream();
  Stream<List<InvoiceEntity>> getInvoicesByStatusStream(String status);
  Stream<List<InvoiceEntity>> getCustomerInvoicesStream(String customerId);
  
  // Async operations
  Future<InvoiceEntity> getInvoiceById(String id);
  Future<List<InvoiceEntity>> getInvoicesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });
  Future<List<InvoiceEntity>> searchInvoices(String query);
  
  // CRUD
  Future<String> createInvoice(InvoiceEntity invoice);
  Future<void> updateInvoice(InvoiceEntity invoice);
  Future<void> deleteInvoice(String id);
  
  // Invoice operations
  Future<String> generateInvoiceNumber();
  Future<void> savePdfUrl(String invoiceId, String pdfUrl);
  Future<String?> getPdfUrl(String invoiceId);
  
  // Status updates
  Future<void> updateInvoiceStatus(String invoiceId, String newStatus);
}
```

**Copy-Paste Usage:**
```dart
// Get all invoices in real-time
final repository = ref.watch(invoiceRepositoryProvider);
final invoices = await repository.getAllInvoicesStream().first;

// Get paid invoices
final paidInvoicesStream = repository.getInvoicesByStatusStream('paid');

// Get invoices for specific customer
final customerInvoices = await repository
    .getCustomerInvoicesStream('customer-123').first;

// Get invoices in date range
final invoices = await repository.getInvoicesByDateRange(
  startDate: DateTime(2024, 1, 1),
  endDate: DateTime(2024, 12, 31),
);

// Create invoice
final invoiceId = await repository.createInvoice(
  InvoiceEntity(
    id: uuid.v4(),
    invoiceNumber: '001',
    customerId: 'cust-1',
    customerName: 'John Doe',
    items: [
      InvoiceItemEntity(
        productId: 'prod-1',
        productName: 'Laptop',
        quantity: 2,
        unitPrice: 1000,
        taxRate: 18,
      ),
    ],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
);

// Get next invoice number
final nextNumber = await repository.generateInvoiceNumber();
print('Next invoice: INV-$nextNumber');

// Save PDF
await repository.savePdfUrl('inv-123', 'gs://bucket/invoices/inv-123.pdf');

// Update status
await repository.updateInvoiceStatus('inv-123', 'paid');
```

---

## Sales Module - Complete API (Ready to Implement)

### Domain Repository Interface
```dart
// Location: lib/features/sales/domain/repositories/sales_repository.dart

abstract class SalesRepository {
  // Streams
  Stream<List<SalesOrderEntity>> getAllSalesOrdersStream();
  Stream<List<SalesOrderEntity>> getSalesByStatusStream(String status);
  
  // Async
  Future<SalesOrderEntity> getSalesOrderById(String id);
  Future<List<SalesOrderEntity>> getSalesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });
  
  // Analytics
  Future<double> getTotalSalesAmount({DateTime? from, DateTime? to});
  Future<double> getTotalProfit({DateTime? from, DateTime? to});
  Future<int> getTotalOrdersCount({DateTime? from, DateTime? to});
  
  // CRUD
  Future<String> createSalesOrder(SalesOrderEntity order);
  Future<void> updateSalesOrder(SalesOrderEntity order);
  Future<void> deleteSalesOrder(String id);
}
```

---

## Payroll Module - Complete API (Ready to Implement)

### Domain Repository Interface
```dart
// Location: lib/features/payroll/domain/repositories/payroll_repository.dart

abstract class PayrollRepository {
  // Streams
  Stream<List<PayrollEntity>> getAllPayrollStream();
  Stream<List<PayrollEntity>> getPayrollByMonthStream(String month);
  Stream<List<PayrollEntity>> getPayrollByStatusStream(String status);
  
  // Async
  Future<PayrollEntity> getPayrollById(String id);
  Future<double> getTotalPayrollAmount(String month);
  
  // CRUD
  Future<String> createPayroll(PayrollEntity payroll);
  Future<void> updatePayroll(PayrollEntity payroll);
  Future<void> deletePayroll(String id);
  
  // Operations
  Future<void> approvePayroll(String id);
  Future<void> markAsPaid(String id);
}
```

---

## Expense Module - Complete API (Ready to Implement)

### Domain Repository Interface  
```dart
// Location: lib/features/expense/domain/repositories/expense_repository.dart

abstract class ExpenseRepository {
  // Streams
  Stream<List<ExpenseEntity>> getAllExpensesStream();
  Stream<List<ExpenseEntity>> getExpensesByCategoryStream(String category);
  Stream<List<ExpenseEntity>> getExpensesByStatusStream(String status);
  
  // Async
  Future<ExpenseEntity> getExpenseById(String id);
  Future<List<ExpenseEntity>> getExpensesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });
  Future<double> getTotalExpensesByCategory(String category);
  
  // CRUD
  Future<String> createExpense(ExpenseEntity expense);
  Future<void> updateExpense(ExpenseEntity expense);
  Future<void> deleteExpense(String id);
  
  // Operations
  Future<void> uploadReceipt(String expenseId, String filePath);
  Future<void> approveExpense(String id);
  Future<void> rejectExpense(String id, String reason);
}
```

---

## Reports Module - Complete API (Ready to Implement)

### Domain Repository Interface
```dart
// Location: lib/features/reports/domain/repositories/report_repository.dart

abstract class ReportRepository {
  // Streams
  Stream<List<ReportEntity>> getAllReportsStream();
  
  // Async
  Future<ReportEntity> generateSalesReport({
    required DateTime from,
    required DateTime to,
  });
  
  Future<ReportEntity> generateProfitAndLossReport({
    required DateTime from,
    required DateTime to,
  });
  
  Future<ReportEntity> generateExpenseReport({
    required DateTime from,
    required DateTime to,
  });
  
  // Export
  Future<String> exportReportAsPdf(String reportId);
  Future<String> exportReportAsCsv(String reportId);
}
```

---

## Core Services - Complete API

### PDF Service
```dart
// Location: lib/core/services/pdf/invoice_pdf_service.dart

class InvoicePdfService {
  // Generate and save to local file
  Future<String> generateAndSavePdf(InvoiceEntity invoice) async {
    // Returns: /path/to/invoices/invoice_001.pdf
  }
  
  // Generate bytes for cloud upload
  Future<Uint8List> generatePdfBytes(InvoiceEntity invoice) async {
    // Returns: PDF bytes ready to upload to Firebase Storage
  }
}
```

**Copy-Paste Usage:**
```dart
// Save locally
final pdfPath = await InvoicePdfService().generateAndSavePdf(invoice);
print('PDF saved to: $pdfPath');

// Get bytes for cloud upload
final pdfBytes = await InvoicePdfService().generatePdfBytes(invoice);
await FirebaseStorage.instance
    .ref('invoices/inv-${invoice.invoiceNumber}.pdf')
    .putData(pdfBytes);
```

---

## Error Handling - Complete API

### Exception Classes
```dart
// Location: lib/core/error/exceptions.dart

// All exceptions inherit from RepositoryException
abstract class RepositoryException implements Exception {
  final String message;
  RepositoryException(this.message);
}

// Specific exceptions
class FirestoreException extends RepositoryException {
  FirestoreException(String message) : super(message);
}

class ValidationException extends RepositoryException {
  ValidationException(String message) : super(message);
}

class NetworkException extends RepositoryException {
  NetworkException(String message) : super(message);
}

class NotFoundException extends RepositoryException {
  NotFoundException(String message) : super(message);
}

class AuthenticationException extends RepositoryException {
  AuthenticationException(String message) : super(message);
}
```

**Copy-Paste Usage:**
```dart
try {
  await repository.createProduct(product);
} on ValidationException catch (e) {
  showErrorSnackbar('Validation Error: ${e.message}');
} on FirestoreException catch (e) {
  showErrorSnackbar('Database Error: ${e.message}');
} on Exception catch (e) {
  showErrorSnackbar('Unexpected Error: $e');
}
```

---

## UI Utilities - Complete API

### Loading Widget
```dart
LoadingWidget(message: 'Loading products...')
```

### Empty State Widget
```dart
EmptyStateWidget(
  icon: Icons.shopping_cart,
  title: 'No Products',
  subtitle: 'Add your first product to get started',
  actionLabel: 'Add Product',
  onAction: () => navigateToAddProduct(),
)
```

### Error Widget
```dart
ErrorWidget(
  message: 'Failed to load products',
  onRetry: () => ref.refresh(allProductsStreamProvider),
)
```

### Snackbars
```dart
showErrorSnackbar(context, 'Something went wrong');
showSuccessSnackbar(context, 'Product added successfully');
```

### Formatters
```dart
// Currency
NumberUtils.formatCurrency(1000.50); // Returns: ₹1,000.50

// Percentage
NumberUtils.formatPercentage(18); // Returns: 18%

// Quantity
NumberUtils.formatQuantity(100); // Returns: 100 units

// Date
DateUtils.formatDate(DateTime.now()); // Returns: 01-Mar-2024

// DateTime
DateUtils.formatDateTime(DateTime.now()); // Returns: 01-Mar-2024 2:30 PM
```

---

## Riverpod Providers - Complete API

### Products Providers
```dart
// Location: lib/features/products/presentation/providers/product_providers.dart

// Dependency Injection
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(
    datasource: ProductFirestoreDatasource(ref.watch(firestoreProvider)),
  );
});

// Real-time streams
final allProductsStreamProvider = StreamProvider<List<ProductEntity>>((ref) {
  return ref.watch(productRepositoryProvider).getAllProductsStream();
});

final lowStockProductsStreamProvider = StreamProvider<List<ProductEntity>>((ref) {
  return ref.watch(productRepositoryProvider).getLowStockProductsStream();
});

// Parameterized providers
final searchProductsProvider = FutureProvider.family<
  List<ProductEntity>, 
  String
>((ref, query) async {
  return ref.watch(productRepositoryProvider).searchProducts(query);
});

// UI state providers
final productLoadingProvider = StateProvider<bool>((ref) => false);
final productErrorProvider = StateProvider<String?>((ref) => null);
```

**Copy-Paste Usage:**
```dart
// In any ConsumerWidget
class ProductListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(allProductsStreamProvider);
    
    return asyncValue.when(
      loading: () => LoadingWidget(message: 'Loading products...'),
      error: (err, st) => ErrorWidget(
        message: err.toString(),
        onRetry: () => ref.refresh(allProductsStreamProvider),
      ),
      data: (products) => ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(title: Text(product.name));
        },
      ),
    );
  }
}
```

---

## Firestore Collections & Fields

### `/products` Collection
```
Document: product-123
├── name: String (required)
├── description: String
├── price: double (required)
├── quantity: int (required)
├── sku: String (required)
├── category: String
├── gstPercentage: double
├── tax: double (calculated)
├── hsn: String
├── active: bool
├── createdAt: Timestamp
└── updatedAt: Timestamp
```

### `/invoices` Collection
```
Document: invoice-456
├── invoiceNumber: String (unique)
├── customerId: String
├── customerName: String
├── customerEmail: String
├── customerPhone: String
├── items: Array<{
│   ├── productId: String
│   ├── productName: String
│   ├── quantity: int
│   ├── unitPrice: double
│   ├── taxRate: double
│   └── total: double
├── subtotal: double
├── taxAmount: double
├── totalAmount: double
├── status: String (draft|sent|paid|overdue)
├── notes: String
├── pdfUrl: String
├── createdAt: Timestamp
└── updatedAt: Timestamp
```

### `/settings` Collection
```
Document: invoice_counter
└── nextInvoiceNumber: int
```

---

## Composite Firestore Indexes

All indexes are pre-configured in `firestore.indexes.json`

**Product Indexes:**
- products (category ASC, createdAt DESC)
- products (quantity ASC, category ASC)
- products (active ASC, createdAt DESC)

**Invoice Indexes:**
- invoices (status ASC, createdAt DESC)
- invoices (customerId ASC, createdAt DESC)
- invoices (createdAt DESC)

---

## Security Rules - Key Patterns

```javascript
// Authenticated users only
match /{document=**} {
  allow read, write: if request.auth != null;
}

// Data validation
match /products/{productId} {
  allow create: if request.resource.data.keys().hasAll(['name', 'price']);
  allow update: if request.resource.data.price > 0;
}

// Status-based access
match /invoices/{invoiceId} {
  allow update: if resource.data.status == 'draft';
}
```

---

## Common Patterns

### Add a new field to a module
```dart
// 1. Add to Entity
class ProductEntity {
  final String manufacturer;  // NEW
}

// 2. Add to Model  
class ProductModel {
  final String? manufacturer;  // nullable for existing data
}

// 3. Update JSON serialization
ProductModel.fromMap(Map<String, dynamic> map) {
  return ProductModel(
    manufacturer: map['manufacturer'] as String?,  // NEW
  );
}

// 4. That's it! Firestore auto-stores new field
```

### Add a new repository method
```dart
// 1. Add to abstract repository
abstract class ProductRepository {
  Future<List<ProductEntity>> getProductsByManufacturer(String manufacturer);
}

// 2. Implement in datasource
class ProductFirestoreDatasource {
  Future<List<ProductModel>> getProductsByManufacturer(String manufacturer) {
    return _firestore
        .collection('products')
        .where('manufacturer', isEqualTo: manufacturer)
        .get()
        .then((snap) => snap.docs.map((doc) => ProductModel.fromFirestore(doc)).toList());
  }
}

// 3. Implement in repository
class ProductRepositoryImpl implements ProductRepository {
  @override
  Future<List<ProductEntity>> getProductsByManufacturer(String manufacturer) async {
    final models = await _datasource.getProductsByManufacturer(manufacturer);
    return models.map((model) => model.toEntity()).toList();
  }
}

// 4. Create provider
final productsByManufacturerProvider = FutureProvider.family<
  List<ProductEntity>, 
  String
>((ref, manufacturer) async {
  return ref.watch(productRepositoryProvider)
      .getProductsByManufacturer(manufacturer);
});

// 5. Use in UI
ref.watch(productsByManufacturerProvider('Dell'))
```

### Add a new validation rule
```dart
// In your use case or repository method:
if (product.price <= 0) {
  throw ValidationException('Price must be greater than 0');
}

if (product.name.isEmpty) {
  throw ValidationException('Product name is required');
}

if (product.quantity < 0) {
  throw ValidationException('Quantity cannot be negative');
}

// In your UI, catch and show:
try {
  await repository.createProduct(product);
} on ValidationException catch (e) {
  showErrorSnackbar(context, e.message);
}
```

---

## Ready-to-Use Code Templates

### Complete Product CRUD Operation
[See QUICK_START_EXAMPLES.md → "Complete CRUD Example"]

### Real-Time Dashboard
[See QUICK_START_EXAMPLES.md → "Real-Time Dashboard"]

### Invoice Creation with PDF
[See QUICK_START_EXAMPLES.md → "Create Invoice with PDF"]

### Search and Filter
[See QUICK_START_EXAMPLES.md → "Advanced Search"]

### Error Handling Pattern
[See QUICK_START_EXAMPLES.md → "Error Handling"]

---

## Quick Navigation

- **All files**: See FILES_SUMMARY.md
- **Practical examples**: See QUICK_START_EXAMPLES.md
- **Architecture**: See PRODUCTION_IMPLEMENTATION_GUIDE.md
- **Getting started**: See START_HERE.md
- **Verification**: See MASTER_CHECKLIST.md

---

**This is your complete technical reference for the entire SmartERP system!**

Copy-paste from here and customize for your needs. 🚀
