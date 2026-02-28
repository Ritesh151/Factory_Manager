# SmartERP Information Architecture

**Version:** 1.0  
**Date:** February 2026  
**Status:** Production

---

## 1. Screen Hierarchy

### 1.1 Navigation Structure

```
App
├── Auth Flow (Unauthenticated)
│   ├── Splash Screen
│   ├── Login Screen
│   ├── Registration Screen
│   └── Forgot Password Screen
│
└── Main App Shell (Authenticated)
    ├── Bottom Navigation Bar
    │   ├── Dashboard (Home)
    │   ├── Sales
    │   ├── Products
    │   └── More
    │
    ├── Dashboard Stack
    │   ├── Dashboard Home
    │   ├── GST Summary
    │   ├── Profit & Loss
    │   └── Low Stock Alert
    │
    ├── Sales Stack
    │   ├── Sales List
    │   ├── Create Invoice
    │   ├── Invoice Detail (Read-only)
    │   └── Invoice PDF Preview
    │
    ├── Products Stack
    │   ├── Product List
    │   ├── Add Product
    │   ├── Edit Product
    │   ├── Product Detail
    │   └── Low Stock Filter
    │
    ├── Purchases Stack (Drawer)
    │   ├── Purchase List
    │   ├── Add Purchase
    │   └── Purchase Detail
    │
    ├── Expenses Stack (Drawer)
    │   ├── Expense List
    │   ├── Add Expense
    │   ├── Edit Expense (within 24h)
    │   └── Expense Detail
    │
    ├── Payroll Stack (Drawer)
    │   ├── Employee List
    │   ├── Add Employee
    │   ├── Employee Detail
    │   ├── Salary History
    │   └── Mark Salary Paid
    │
    ├── Reports Stack (Drawer)
    │   ├── Report Dashboard
    │   ├── Sales Report
    │   ├── Purchase Report
    │   ├── Expense Report
    │   ├── GST Report
    │   └── Stock Report
    │
    └── Settings Stack (Drawer)
        ├── Business Profile
        ├── Account Settings
        ├── Data Export
        ├── About
        └── Logout
```

### 1.2 Screen Classification

| Category | Screens | Access Frequency |
|----------|---------|------------------|
| **Core Transaction** | Create Invoice, Add Purchase, Add Expense | High (Daily) |
| **Reference Data** | Product List, Employee List | Medium (Weekly) |
| **Reporting** | Dashboard, Reports, GST Summary | High (Daily) |
| **Configuration** | Settings, Business Profile | Low (Monthly) |
| **Authentication** | Login, Register | One-time |

---

## 2. Navigation Flow (GoRouter Structure)

### 2.1 Route Configuration

```dart
// lib/core/navigation/app_router.dart

final router = GoRouter(
  initialLocation: '/splash',
  debugLogDiagnostics: kDebugMode,
  redirect: (context, state) {
    final isAuthenticated = authProvider.isAuthenticated;
    final isAuthRoute = state.matchedLocation.startsWith('/auth');
    
    if (!isAuthenticated && !isAuthRoute) return '/auth/login';
    if (isAuthenticated && isAuthRoute) return '/dashboard';
    return null;
  },
  routes: [
    // Auth Routes
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/auth/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/auth/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/auth/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    
    // Main App Shell with Bottom Navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => MainScaffold(
        navigationShell: navigationShell,
      ),
      branches: [
        // Dashboard Branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
              routes: [
                GoRoute(
                  path: 'gst-summary',
                  builder: (context, state) => const GstSummaryScreen(),
                ),
                GoRoute(
                  path: 'profit-loss',
                  builder: (context, state) => const ProfitLossScreen(),
                ),
                GoRoute(
                  path: 'low-stock',
                  builder: (context, state) => const LowStockScreen(),
                ),
              ],
            ),
          ],
        ),
        
        // Sales Branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/sales',
              builder: (context, state) => const SalesListScreen(),
              routes: [
                GoRoute(
                  path: 'create',
                  builder: (context, state) => const CreateInvoiceScreen(),
                ),
                GoRoute(
                  path: ':invoiceId',
                  builder: (context, state) => InvoiceDetailScreen(
                    invoiceId: state.pathParameters['invoiceId']!,
                  ),
                ),
                GoRoute(
                  path: ':invoiceId/pdf',
                  builder: (context, state) => InvoicePdfScreen(
                    invoiceId: state.pathParameters['invoiceId']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        
        // Products Branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/products',
              builder: (context, state) => const ProductListScreen(),
              routes: [
                GoRoute(
                  path: 'add',
                  builder: (context, state) => const AddProductScreen(),
                ),
                GoRoute(
                  path: ':productId/edit',
                  builder: (context, state) => EditProductScreen(
                    productId: state.pathParameters['productId']!,
                  ),
                ),
                GoRoute(
                  path: ':productId',
                  builder: (context, state) => ProductDetailScreen(
                    productId: state.pathParameters['productId']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        
        // More Branch (Drawer-based navigation)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/more',
              builder: (context, state) => const MoreScreen(),
            ),
          ],
        ),
      ],
    ),
    
    // Drawer Routes (outside shell)
    GoRoute(
      path: '/purchases',
      builder: (context, state) => const PurchaseListScreen(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) => const AddPurchaseScreen(),
        ),
        GoRoute(
          path: ':purchaseId',
          builder: (context, state) => PurchaseDetailScreen(
            purchaseId: state.pathParameters['purchaseId']!,
          ),
        ),
      ],
    ),
    
    GoRoute(
      path: '/expenses',
      builder: (context, state) => const ExpenseListScreen(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) => const AddExpenseScreen(),
        ),
        GoRoute(
          path: ':expenseId/edit',
          builder: (context, state) => EditExpenseScreen(
            expenseId: state.pathParameters['expenseId']!,
          ),
        ),
      ],
    ),
    
    GoRoute(
      path: '/employees',
      builder: (context, state) => const EmployeeListScreen(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) => const AddEmployeeScreen(),
        ),
        GoRoute(
          path: ':employeeId',
          builder: (context, state) => EmployeeDetailScreen(
            employeeId: state.pathParameters['employeeId']!,
          ),
          routes: [
            GoRoute(
              path: 'salary',
              builder: (context, state) => SalaryHistoryScreen(
                employeeId: state.pathParameters['employeeId']!,
              ),
            ),
            GoRoute(
              path: 'pay',
              builder: (context, state) => MarkSalaryPaidScreen(
                employeeId: state.pathParameters['employeeId']!,
              ),
            ),
          ],
        ),
      ],
    ),
    
    GoRoute(
      path: '/reports',
      builder: (context, state) => const ReportsDashboardScreen(),
      routes: [
        GoRoute(
          path: 'sales',
          builder: (context, state) => const SalesReportScreen(),
        ),
        GoRoute(
          path: 'purchases',
          builder: (context, state) => const PurchaseReportScreen(),
        ),
        GoRoute(
          path: 'expenses',
          builder: (context, state) => const ExpenseReportScreen(),
        ),
        GoRoute(
          path: 'gst',
          builder: (context, state) => const GstReportScreen(),
        ),
        GoRoute(
          path: 'stock',
          builder: (context, state) => const StockReportScreen(),
        ),
      ],
    ),
    
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
      routes: [
        GoRoute(
          path: 'profile',
          builder: (context, state) => const BusinessProfileScreen(),
        ),
        GoRoute(
          path: 'export',
          builder: (context, state) => const DataExportScreen(),
        ),
      ],
    ),
  ],
  
  // Error handling
  errorBuilder: (context, state) => ErrorScreen(error: state.error),
);
```

### 2.2 Deep Linking Support

| URL Pattern | Screen | Parameters |
|-------------|--------|------------|
| `app://smarterp/dashboard` | Dashboard Home | - |
| `app://smarterp/sales/:invoiceId` | Invoice Detail | invoiceId |
| `app://smarterp/sales/:invoiceId/pdf` | Invoice PDF | invoiceId |
| `app://smarterp/products/:productId` | Product Detail | productId |
| `app://smarterp/expenses` | Expense List | - |

### 2.3 Navigation State Preservation

| Scenario | Behavior |
|----------|----------|
| App Background | State preserved in memory |
| App Kill & Restart | Restore to last route via local storage |
| Deep Link | Navigate to target, preserve back stack |
| Authentication Timeout | Redirect to login, save intended route |

---

## 3. Feature Grouping

### 3.1 Feature Modules

```
lib/features/
├── auth/                    # Authentication
│   ├── login/
│   ├── register/
│   └── forgot_password/
│
├── dashboard/               # Analytics & Overview
│   ├── home/
│   ├── gst_summary/
│   └── profit_loss/
│
├── sales/                   # Invoicing
│   ├── invoice_list/
│   ├── create_invoice/
│   ├── invoice_detail/
│   └── invoice_pdf/
│
├── products/                # Product Management
│   ├── product_list/
│   ├── add_product/
│   ├── edit_product/
│   └── product_detail/
│
├── purchases/               # Purchase Entry
│   ├── purchase_list/
│   ├── add_purchase/
│   └── purchase_detail/
│
├── expenses/                # Expense Tracking
│   ├── expense_list/
│   ├── add_expense/
│   └── expense_detail/
│
├── payroll/                 # Employee Management
│   ├── employee_list/
│   ├── add_employee/
│   ├── employee_detail/
│   └── salary_management/
│
├── reports/                 # Reporting
│   ├── report_dashboard/
│   ├── sales_report/
│   ├── expense_report/
│   └── gst_report/
│
└── settings/                # Configuration
    ├── business_profile/
    ├── account_settings/
    └── data_export/
```

### 3.2 Feature Dependencies

| Feature | Depends On | Shared Components |
|---------|-----------|-------------------|
| Create Invoice | Products (for selection) | ProductPicker, QuantityInput |
| Invoice Detail | Sales | PdfViewer, ShareButton |
| Add Purchase | Products | ProductPicker, PriceInput |
| Dashboard | Sales, Purchases, Expenses, Payroll | SummaryCard, ChartWidget |
| GST Summary | Sales, Purchases | TaxBreakdownTable |
| Reports | All transaction modules | DateRangePicker, ExportButton |

---

## 4. UX Data Flow

### 4.1 Data Flow Patterns

#### Pattern 1: List → Detail → Edit
```
User Action                    State Change                    UI Update
────────────────────────────────────────────────────────────────────────
Tap Product List    →    Load products (cached)      →    Show list
↓
Tap Product         →    Load product details        →    Show detail
↓
Tap Edit            →    Enter edit mode             →    Show form
↓
Save Changes        →    Update Firestore            →    Show success
                        Update local cache          →    Return to detail
```

#### Pattern 2: Create Transaction (Invoice)
```
User Action                    State Change                    UI Update
────────────────────────────────────────────────────────────────────────
Tap Create Invoice  →    Initialize empty invoice    →    Show form
↓
Add Line Item       →    Add to invoice items        →    Update list
                        Calculate totals             →    Show subtotal
↓
Select Product      →    Fetch product (cached)      →    Auto-fill price
↓
Enter Quantity      →    Validate stock              →    Show error if > stock
                        Calculate line total         →    Update total
↓
Save Invoice        →    Validate entire form        →    Show validation
                        Batch write:                  →    Show loading
                          - Save invoice
                          - Update stock
                        Mark locked                   →    Redirect to detail
                        Generate PDF                  →    Show PDF option
```

#### Pattern 3: Dashboard Analytics
```
User Action                    State Change                    UI Update
────────────────────────────────────────────────────────────────────────
Open Dashboard      →    Load cached metrics          →    Show cached data
↓
Background Fetch    →    Query Firestore aggregates   →    Update silently
                        (optimized, single read)     →    Show last updated
↓
Pull to Refresh     →    Force refresh               →    Show loading
                        Update all metrics            →    Animate updates
```

### 4.2 Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         PRESENTATION LAYER                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐           │
│  │  Screen  │  │  Screen  │  │  Screen  │  │  Screen  │           │
│  │ Widgets  │  │ Widgets  │  │ Widgets  │  │ Widgets  │           │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘           │
│       │             │             │             │                  │
│       └─────────────┴──────┬──────┴─────────────┘                  │
│                            │                                       │
└────────────────────────────┼───────────────────────────────────────┘
                             │
                    ┌────────▼────────┐
                    │   UI State        │
                    │   (Riverpod)      │
                    │                   │
                    │  • FormState      │
                    │  • ViewState      │
                    │  • Navigation   │
                    └────────┬────────┘
                             │
┌────────────────────────────┼───────────────────────────────────────┐
│                         DOMAIN LAYER                               │
│                            │                                       │
│       ┌────────────────────┼────────────────────┐                 │
│       │                    │                    │                 │
│  ┌────▼────┐         ┌────▼────┐         ┌────▼────┐             │
│  │Use Cases│         │Use Cases│         │Use Cases│             │
│  │Invoicing│         │Inventory│         │Reporting│             │
│  └────┬────┘         └────┬────┘         └────┬────┘             │
│       │                   │                   │                   │
│       └───────────────────┼───────────────────┘                   │
│                           │                                       │
│                    ┌──────▼──────┐                                │
│                    │  Business   │                                │
│                    │   Logic     │                                │
│                    │  (Client)    │                                │
│                    └──────┬──────┘                                │
└───────────────────────────┼───────────────────────────────────────┘
                            │
┌───────────────────────────┼───────────────────────────────────────┐
│                      DATA LAYER                                    │
│                           │                                        │
│                    ┌──────▼──────┐                                │
│                    │ Repository  │                                │
│                    │  Interface  │                                │
│                    └──────┬──────┘                                │
│                           │                                        │
│       ┌───────────────────┼───────────────────┐                 │
│       │                   │                   │                 │
│  ┌────▼────┐         ┌────▼────┐         ┌────▼────┐             │
│  │ Firestore│         │  Local   │         │  Cache   │             │
│  │  Remote │         │  SQLite  │         │  Memory  │             │
│  └─────────┘         └─────────┘         └─────────┘             │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

---

## 5. State Ownership Mapping (Riverpod Providers)

### 5.1 Provider Hierarchy

```dart
// lib/core/providers/app_providers.dart

// ─────────────────────────────────────────────────────────────
// APP-LEVEL PROVIDERS (Global, Long-lived)
// ─────────────────────────────────────────────────────────────

// Authentication State
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

// Connectivity
final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged;
});

// ─────────────────────────────────────────────────────────────
// USER-DATA PROVIDERS (User-scoped, Cached)
// ─────────────────────────────────────────────────────────────

// User Profile
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.watch(userRepositoryProvider).getProfile(user.uid);
});

// Business Settings
final businessSettingsProvider = FutureProvider<BusinessSettings>((ref) async {
  final user = ref.watch(currentUserProvider);
  return ref.watch(settingsRepositoryProvider).getSettings(user!.uid);
});

// ─────────────────────────────────────────────────────────────
// FEATURE PROVIDERS (Feature-scoped, Disposable)
// ─────────────────────────────────────────────────────────────

// PRODUCTS
final productsListProvider = StreamProvider<List<Product>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(productRepositoryProvider).watchAll(user.uid);
});

final productDetailProvider = FutureProvider.family<Product?, String>((ref, productId) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.watch(productRepositoryProvider).getById(user.uid, productId);
});

final lowStockProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(productsListProvider);
  return productsAsync.when(
    data: (products) => AsyncValue.data(
      products.where((p) => p.stock <= 10).toList(),
    ),
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});

// SALES / INVOICES
final invoicesListProvider = StreamProvider.family<List<Invoice>, DateRange>((ref, range) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(invoiceRepositoryProvider).watchByDateRange(user.uid, range);
});

final invoiceDetailProvider = FutureProvider.family<Invoice?, String>((ref, invoiceId) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.watch(invoiceRepositoryProvider).getById(user.uid, invoiceId);
});

// Invoice Form State (Local, temporary)
final invoiceFormProvider = StateNotifierProvider<InvoiceFormNotifier, InvoiceFormState>((ref) {
  return InvoiceFormNotifier();
});

// PURCHASES
final purchasesListProvider = StreamProvider.family<List<Purchase>, DateRange>((ref, range) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(purchaseRepositoryProvider).watchByDateRange(user.uid, range);
});

// EXPENSES
final expensesListProvider = StreamProvider.family<List<Expense>, DateRange>((ref, range) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(expenseRepositoryProvider).watchByDateRange(user.uid, range);
});

// PAYROLL
final employeesListProvider = StreamProvider<List<Employee>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(employeeRepositoryProvider).watchAll(user.uid);
});

final employeeDetailProvider = FutureProvider.family<Employee?, String>((ref, employeeId) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.watch(employeeRepositoryProvider).getById(user.uid, employeeId);
});

// ─────────────────────────────────────────────────────────────
// COMPUTED/DERIVED PROVIDERS (Dashboard, Analytics)
// ─────────────────────────────────────────────────────────────

// Dashboard Metrics
final dashboardMetricsProvider = FutureProvider<DashboardMetrics>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('Not authenticated');
  
  // Fetch all data in parallel
  final results = await Future.wait([
    ref.watch(invoiceRepositoryProvider).getMonthlyTotal(user.uid, DateTime.now()),
    ref.watch(purchaseRepositoryProvider).getMonthlyTotal(user.uid, DateTime.now()),
    ref.watch(expenseRepositoryProvider).getMonthlyTotal(user.uid, DateTime.now()),
    ref.watch(employeeRepositoryProvider).getMonthlySalaryTotal(user.uid, DateTime.now()),
  ]);
  
  return DashboardMetrics(
    totalSales: results[0] as double,
    totalPurchases: results[1] as double,
    totalExpenses: results[2] as double,
    totalSalary: results[3] as double,
  );
});

// GST Summary
final gstSummaryProvider = FutureProvider.family<GstSummary, DateTime>((ref, month) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('Not authenticated');
  return ref.watch(gstRepositoryProvider).getMonthlySummary(user.uid, month);
});

// Profit Calculation
final netProfitProvider = Provider<AsyncValue<double>>((ref) {
  final metricsAsync = ref.watch(dashboardMetricsProvider);
  return metricsAsync.when(
    data: (m) => AsyncValue.data(m.totalSales - m.totalPurchases - m.totalExpenses - m.totalSalary),
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});
```

### 5.2 State Ownership Matrix

| State | Owner | Scope | Persistence | Lifecycle |
|-------|-------|-------|-------------|-----------|
| Auth State | `authStateProvider` | App | Firestore Auth | App lifetime |
| User Profile | `userProfileProvider` | User | Firestore | Session |
| Products List | `productsListProvider` | Feature | Firestore + Memory | While subscribed |
| Product Detail | `productDetailProvider` | Screen | Firestore + Cache | Screen lifetime |
| Invoice Form | `invoiceFormProvider` | Form | Memory only | Form lifetime |
| Dashboard | `dashboardMetricsProvider` | Screen | Computed | Screen lifetime |
| Low Stock | `lowStockProductsProvider` | Computed | Derived | Depends on source |
| GST Summary | `gstSummaryProvider` | Screen | Computed | Screen lifetime |

### 5.3 State Invalidation Strategy

| Provider | Invalidation Trigger | Cache Duration |
|----------|---------------------|----------------|
| `productsListProvider` | Product CRUD | Real-time (stream) |
| `invoicesListProvider` | Invoice created | Real-time (stream) |
| `dashboardMetricsProvider` | Manual refresh, 5 min auto | 5 minutes |
| `gstSummaryProvider` | Manual refresh | 1 hour |
| `invoiceFormProvider` | Form submit/cancel | N/A (disposed) |

---

## 6. Offline Strategy

### 6.1 Offline-First Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    UI LAYER                                 │
│  • Show cached data immediately                             │
│  • Indicate offline state                                   │
│  • Queue user actions                                       │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                 SYNC LAYER                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Write Queue │  │  Read Cache  │  │  Sync Engine │      │
│  │  (Pending)   │  │  (SQLite)    │  │  (Worker)    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│              FIRESTORE LAYER (When Online)                  │
│  • Two-way sync                                             │
│  • Conflict resolution (server wins)                        │
│  • Optimistic updates                                       │
└─────────────────────────────────────────────────────────────┘
```

### 6.2 Offline Capabilities by Feature

| Feature | Read Offline | Write Offline | Sync Strategy |
|---------|--------------|---------------|---------------|
| View Products | Yes | N/A | Cache all products |
| Create Invoice | Yes (cached products) | Queue | Batch on sync |
| View Invoices | Yes (last 100) | N/A | Pagination |
| Add Expense | Yes | Queue | Immediate on online |
| Dashboard | Yes (stale) | N/A | Background refresh |
| PDF Generation | Yes | N/A | Local generation |

---

**End of Document**
