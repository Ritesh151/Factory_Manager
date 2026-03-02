# SmartERP Quick-Start Implementation Examples

## 🎯 Real-Time Product List

```dart
// Simply use this screen and it auto-updates from Firestore
import 'package:flutter/material.dart';
import 'features/products/presentation/pages/product_list_screen.dart';

// In your router or app:
ProductListScreen() // Done! Real-time updates automatically
```

Real-time flow:
1. User adds product in Firestore Console
2. ProductListScreen watches `allProductsStreamProvider`
3. Stream provider listens to Firestore
4. UI rebuilds automatically with new product
5. No refresh button needed

---

## 📄 Create Invoice with Auto-Generated PDF

```dart
import 'features/invoices/domain/usecases/create_invoice_usecase.dart';
import 'features/invoices/presentation/providers/invoice_providers.dart';

// Example: Create invoice from a form
Future<void> submitInvoiceForm() async {
  try {
    ref.read(invoiceLoadingProvider.notifier).state = true;
    
    final useCase = CreateInvoiceWithPdfUseCase(
      invoiceRepository: ref.watch(invoiceRepositoryProvider),
      productRepository: ref.watch(productRepositoryProvider),
    );

    // Create invoice (validates stock, generates PDF, saves to Firestore)
    final invoice = await useCase(
      customerId: 'CUST-001',
      customerName: 'John Smith',
      customerEmail: 'john@example.com',
      customerPhone: '+1-555-0123',
      items: [
        (productId: 'prod-123', quantity: 2),  // Product ID and quantity
        (productId: 'prod-456', quantity: 1),
      ],
      notes: 'Payment due within 30 days',
    );

    // Invoice created, PDF generated and saved
    print('Invoice created: ${invoice.invoiceNumber}');
    print('PDF saved at: ${invoice.pdfUrl}');
    
    showSuccessSnackbar(
      context, 
      'Invoice ${invoice.invoiceNumber} created successfully!',
    );
    
    ref.read(invoiceLoadingProvider.notifier).state = false;
    
  } on ValidationException catch (e) {
    showErrorSnackbar(context, e.message); // Stock validation failed
  } on FirestoreException catch (e) {
    showErrorSnackbar(context, 'Error: ${e.message}');
  }
}
```

What happens automatically:
1. Validates product stock
2. Generates next invoice number (INV-00001, INV-00002)
3. Calculates totals and taxes
4. Creates invoice in Firestore
5. Generates professional PDF
6. Saves PDF locally
7. Updates product stock quantities
8. All in one call!

---

## 🔍 Display Products with Real-Time Stream

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/products/presentation/providers/product_providers.dart';

class ProductsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch real-time products from Firestore
    final productsAsyncValue = ref.watch(allProductsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: productsAsyncValue.when(
        // Loading: show spinner
        loading: () => const Center(child: CircularProgressIndicator()),
        
        // Error: show error message
        error: (error, st) => Center(
          child: Text('Error: $error'),
        ),
        
        // Success: show list
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text('No products'));
          }
          
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                title: Text(product.name),
                subtitle: Text('${product.quantity} units - \$${product.price}'),
                trailing: product.quantity < 10
                    ? const Chip(label: Text('Low Stock'))
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
```

---

## 📊 Display Real-Time Invoices

```dart
import 'features/invoices/presentation/pages/invoice_list_screen.dart';

// Simply use this screen for real-time invoice updates
InvoiceListScreen() // Auto-updates when invoices change in Firestore
```

---

## 🔎 Search Products in Real-Time

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/products/presentation/providers/product_providers.dart';

// State to hold search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Search provider that watches query
final searchResultsProvider = FutureProvider<List<ProductEntity>>((ref) {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];
  
  final repository = ref.watch(productRepositoryProvider);
  return repository.searchProducts(query);
});

// In UI:
class SearchProductsWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final searchResults = ref.watch(searchResultsProvider);

    return Column(
      children: [
        // Search input
        TextField(
          onChanged: (value) {
            ref.read(searchQueryProvider.notifier).state = value;
          },
          decoration: const InputDecoration(
            hintText: 'Search products...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        
        // Results
        Expanded(
          child: searchResults.when(
            loading: () => const CircularProgressIndicator(),
            error: (err, st) => Text('Error: $err'),
            data: (products) => ListView(
              children: products.map((p) => 
                ListTile(title: Text(p.name))
              ).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
```

---

## 💾 Persist Data Permanently

No special code needed! Data persists automatically:

```dart
// Data automatically:
// 1. Saved to Firebase Firestore (cloud)
// 2. Cached locally by Firestore offline persistence
// 3. Synced when online
// 4. Survives app restart

// Example:
final invoice = await invoiceRepository.createInvoice(invoice);
// Invoice is now:
// - In Firestore cloud ✅
// - In local cache ✅
// - Persisted permanently ✅
```

Check persistence is enabled in `main.dart`:
```dart
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

---

## 🎨 Custom Error Handling

```dart
import 'lib/core/error/exceptions.dart';
import 'lib/core/utils/ui_utils.dart';

try {
  await productRepository.createProduct(product);
} on ValidationException catch (e) {
  // Show validation error to user
  showErrorSnackbar(context, 'Invalid data: ${e.message}');
} on FirestoreException catch (e) {
  // Show Firestore error
  showErrorSnackbar(context, 'Database error: ${e.message}');
} on NetworkException catch (e) {
  // Handle network error
  showErrorSnackbar(context, 'Network error: ${e.message}');
}
```

---

## 📱 Filter Invoices by Status

```dart
import 'features/invoices/presentation/providers/invoice_providers.dart';

// Get only "paid" invoices, real-time
final paidInvoicesProvider = StreamProvider<List<InvoiceEntity>>((ref) {
  return ref.watch(invoiceRepositoryProvider)
      .getInvoicesByStatusStream('paid');
});

// In UI:
ref.watch(paidInvoicesProvider).when(
  data: (paidInvoices) => ListView(
    children: paidInvoices.map((inv) => 
      ListTile(
        title: Text(inv.invoiceNumber),
        subtitle: Text('Paid: \$${inv.totalAmount}'),
      )
    ).toList(),
  ),
  ...
);
```

---

## 📅 Get Invoices by Date Range

```dart
import 'features/invoices/presentation/providers/invoice_providers.dart';

final invoicesByDateProvider = FutureProvider<List<InvoiceEntity>>((ref) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  
  return repository.getInvoicesByDateRange(
    startDate: DateTime.now().subtract(const Duration(days: 30)), // Last 30 days
    endDate: DateTime.now(),
  );
});

// In UI:
ref.watch(invoicesByDateProvider).when(
  data: (invoices) => Text('${invoices.length} invoices in last 30 days'),
  ...
);
```

---

## 🏪 Update Product Stock After Sale

```dart
// Automatically done in CreateInvoiceWithPdfUseCase!
// But can be done manually:

final stockUpdates = {
  'prod-123': 5,  // Deduct 5 units
  'prod-456': 2,  // Deduct 2 units
};

await productRepository.updateProductStocks(stockUpdates);
```

---

## ⚠️ Get Low Stock Alerts

```dart
// Real-time stream of products with quantity < 10
final lowStockProvider = StreamProvider<List<ProductEntity>>((ref) {
  return ref.watch(productRepositoryProvider)
      .getLowStockProductsStream();
});

// In UI - Show alert badge
ref.watch(lowStockProvider).whenData((lowStockProducts) {
  if (lowStockProducts.isNotEmpty) {
    showWarningNotification(
      '${lowStockProducts.length} products have low stock!',
    );
  }
});
```

---

## 📊 Get Product Categories

```dart
// In your category filter screen
final categoriesProvider = FutureProvider<List<String>>((ref) async {
  // Fetch from datasource
  // (Add this method to ProductFirestoreDataSource)
  final snapshot = await FirebaseFirestore.instance
      .collection('products')
      .get();
  
  final categories = <String>{};
  for (final doc in snapshot.docs) {
    final product = ProductModel.fromFirestore(doc);
    categories.add(product.category);
  }
  return categories.toList();
});

// In UI:
ref.watch(categoriesProvider).whenData((categories) {
  return DropdownMenu(
    items: categories.map((cat) => 
      DropdownMenuItem(value: cat, child: Text(cat))
    ).toList(),
  );
});
```

---

## 🚀 Complete API Summary

### Products
```dart
// Get all real-time
ref.watch(allProductsStreamProvider)

// Search
ref.watch(searchProductsProvider('laptop'))

// By category
ref.watch(productsByCategoryProvider('Electronics'))

// Get one product
ref.watch(productByIdProvider('prod-123'))

// Low stock alerts
ref.watch(lowStockProductsStreamProvider)
```

### Invoices
```dart
// All real-time
ref.watch(allInvoicesStreamProvider)

// By status
ref.watch(invoicesByStatusStreamProvider('paid'))

// For customer
ref.watch(customerInvoicesStreamProvider('cust-123'))

// Date range
ref.watch(invoicesByDateRangeProvider(...))

// Search
ref.watch(searchInvoicesProvider('INV-00001'))

// Get next number
ref.watch(nextInvoiceNumberProvider)
```

---

## ✅ How Data Persists

```
App Start
  ↓
Check local cache (offline persistence)
  ↓
Display cached data immediately ✅
  ↓
Fetch fresh data from Firestore
  ↓
Stream updates = UI refreshes
  ↓
Go offline? Keep using cache ✅
  ↓
Go online? Sync changes automatically ✅
```

Example: User sees products even if offline!

---

**Next Step**: Run `flutter run -d windows` and watch real-time updates work!
