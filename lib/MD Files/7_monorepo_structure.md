# SmartERP Monorepo Structure

**Version:** 1.0  
**Date:** February 2026  
**Status:** Production  
**Architecture:** Feature-Based Clean Architecture

---

## 1. Directory Structure Overview

```
smart_erp/
├── android/                          # Android platform code
├── ios/                              # iOS platform code
├── lib/                              # Main Dart source code
│   ├── main.dart                     # Application entry point
│   ├── app.dart                      # App widget & configuration
│   │
│   ├── core/                         # Core shared infrastructure
│   │   ├── constants/                  # App constants
│   │   ├── errors/                   # Error handling
│   │   ├── extensions/               # Dart extensions
│   │   ├── navigation/               # GoRouter configuration
│   │   ├── providers/                # Global Riverpod providers
│   │   ├── theme/                    # Theme & styling
│   │   ├── usecases/                 # Base use case classes
│   │   └── utils/                    # Utility functions
│   │
│   ├── data/                         # Data layer
│   │   ├── datasources/              # Data sources
│   │   │   ├── local/                # Local storage
│   │   │   └── remote/               # Firestore/remote
│   │   ├── models/                   # DTOs / Data models
│   │   └── repositories/             # Repository implementations
│   │
│   ├── domain/                       # Domain layer
│   │   ├── calculations/             # Business calculations
│   │   ├── entities/                 # Core business entities
│   │   ├── enums/                    # Domain enums
│   │   ├── exceptions/               # Domain exceptions
│   │   ├── repositories/             # Repository interfaces
│   │   ├── services/                 # Domain services
│   │   └── value_objects/            # Value objects
│   │
│   ├── features/                     # Feature modules
│   │   ├── auth/                     # Authentication
│   │   ├── dashboard/                # Dashboard & analytics
│   │   ├── products/                 # Product management
│   │   ├── sales/                    # Invoicing
│   │   ├── purchases/                # Purchase entry
│   │   ├── expenses/                 # Expense tracking
│   │   ├── payroll/                  # Payroll management
│   │   ├── reports/                  # Reports & exports
│   │   └── settings/                 # App settings
│   │
│   └── shared/                       # Shared presentation
│       ├── widgets/                  # Common widgets
│       ├── dialogs/                  # Common dialogs
│       ├── forms/                    # Form components
│       └── animations/               # Shared animations
│
├── test/                             # Test files
├── assets/                           # Static assets
│   ├── images/                       # Image files
│   ├── fonts/                        # Custom fonts
│   └── documents/                    # Templates, etc.
├── pubspec.yaml                      # Dependencies
├── analysis_options.yaml             # Static analysis rules
└── README.md                         # Project documentation
```

---

## 2. Core Layer (`lib/core/`)

### 2.1 Purpose
The Core layer contains infrastructure code that is shared across all features. It has no business logic and is purely technical in nature.

### 2.2 Structure

```
lib/core/
├── constants/
│   ├── app_constants.dart            # App-wide constants
│   ├── api_constants.dart            # API/endpoint constants
│   ├── storage_constants.dart        # Storage keys
│   └── firebase_constants.dart       # Firestore paths
│
├── errors/
│   ├── exceptions.dart               # Core exceptions
│   ├── failures.dart                 # Failure classes
│   └── error_handler.dart            # Error handling logic
│
├── extensions/
│   ├── date_time_extensions.dart     # DateTime helpers
│   ├── string_extensions.dart        # String helpers
│   ├── number_extensions.dart        # Number helpers
│   └── context_extensions.dart       # BuildContext helpers
│
├── navigation/
│   ├── app_router.dart               # GoRouter configuration
│   ├── route_names.dart              # Route constants
│   └── route_arguments.dart          # Typed arguments
│
├── providers/
│   ├── auth_provider.dart            # Auth state provider
│   ├── connectivity_provider.dart    # Network state
│   ├── app_lifecycle_provider.dart   # App lifecycle
│   └── firebase_provider.dart        # Firebase instances
│
├── theme/
│   ├── app_theme.dart                # Theme configuration
│   ├── app_colors.dart               # Color palette
│   ├── app_typography.dart           # Text styles
│   └── app_dimensions.dart           # Spacing/sizing
│
├── usecases/
│   └── usecase.dart                  # Base use case interface
│
└── utils/
    ├── logger.dart                   # Logging utility
    ├── connectivity_checker.dart     # Network checker
    ├── date_formatter.dart         # Date formatting
    ├── number_formatter.dart       # Number formatting
    └── validators.dart               # Input validators
```

### 2.3 Key Files

**app_router.dart** - Navigation configuration:
```dart
// Centralized routing with GoRouter
class AppRouter {
  static final router = GoRouter(
    routes: [
      // Auth routes
      ...AuthRoutes.routes,
      // Main app routes with shell
      ...MainRoutes.routes,
      // Feature routes
      ...ProductRoutes.routes,
      ...SalesRoutes.routes,
      // ...etc
    ],
  );
}
```

**app_theme.dart** - Theme management:
```dart
// Light and dark theme definitions
class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: AppColors.lightScheme,
    textTheme: AppTypography.textTheme,
  );
  
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: AppColors.darkScheme,
    textTheme: AppTypography.textTheme,
  );
}
```

---

## 3. Data Layer (`lib/data/`)

### 3.1 Purpose
The Data layer handles data persistence and retrieval. It implements the Repository interfaces defined in the Domain layer.

### 3.2 Structure

```
lib/data/
├── datasources/
│   ├── local/
│   │   ├── local_database.dart           # SQLite/Hive interface
│   │   ├── cache_manager.dart            # Caching logic
│   │   ├── secure_storage.dart           # Encrypted storage
│   │   └── local_data_source.dart        # Abstract local DS
│   │
│   └── remote/
│       ├── firestore_client.dart         # Firestore wrapper
│       ├── firebase_auth_client.dart     # Auth wrapper
│       ├── firebase_storage_client.dart   # Storage wrapper
│       └── remote_data_source.dart       # Abstract remote DS
│
├── models/
│   ├── product_model.dart                # Product DTO
│   ├── invoice_model.dart                # Invoice DTO
│   ├── purchase_model.dart               # Purchase DTO
│   ├── expense_model.dart                # Expense DTO
│   ├── employee_model.dart               # Employee DTO
│   ├── salary_payment_model.dart         # Salary DTO
│   ├── user_profile_model.dart           # User DTO
│   └── ...
│
└── repositories/
    ├── product_repository_impl.dart      # Product repo impl
    ├── invoice_repository_impl.dart      # Invoice repo impl
    ├── purchase_repository_impl.dart     # Purchase repo impl
    ├── expense_repository_impl.dart       # Expense repo impl
    ├── employee_repository_impl.dart     # Employee repo impl
    └── settings_repository_impl.dart     # Settings repo impl
```

### 3.3 Repository Implementation Pattern

```dart
// lib/data/repositories/product_repository_impl.dart

class ProductRepositoryImpl implements ProductRepository {
  final FirestoreClient _firestore;
  final LocalDatabase _localDb;
  final ConnectivityChecker _connectivity;
  
  ProductRepositoryImpl(
    this._firestore,
    this._localDb,
    this._connectivity,
  );
  
  @override
  Stream<List<Product>> watchAll(String userId) async* {
    // Try remote first
    if (await _connectivity.isOnline) {
      yield* _firestore.watchProducts(userId).map(
        (models) => models.map((m) => m.toEntity()).toList(),
      );
    } else {
      // Fallback to local
      yield* _localDb.watchProducts(userId).map(
        (models) => models.map((m) => m.toEntity()).toList(),
      );
    }
  }
  
  @override
  Future<Product> create(String userId, Product product) async {
    final model = ProductModel.fromEntity(product);
    
    // Save to Firestore
    final docId = await _firestore.createProduct(userId, model);
    
    // Update local cache
    await _localDb.saveProduct(userId, model.copyWith(id: docId));
    
    return product.copyWith(id: docId);
  }
  
  // ... other implementations
}
```

---

## 4. Domain Layer (`lib/domain/`)

### 4.1 Purpose
The Domain layer contains pure business logic with no external dependencies. It defines the core entities, repository contracts, and business rules.

### 4.2 Structure

```
lib/domain/
├── calculations/                       # Business calculations
│   ├── gst_calculator.dart             # GST computation
│   ├── stock_calculator.dart           # Stock calculations
│   ├── profit_calculator.dart          # Profit computation
│   └── invoice_calculator.dart         # Invoice totals
│
├── entities/                           # Core business entities
│   ├── product.dart                    # Product entity
│   ├── invoice.dart                    # Invoice entity
│   ├── purchase.dart                   # Purchase entity
│   ├── expense.dart                    # Expense entity
│   ├── employee.dart                   # Employee entity
│   ├── salary_payment.dart             # Salary entity
│   ├── user_profile.dart               # User entity
│   └── user_settings.dart              # Settings entity
│
├── enums/                              # Domain enums
│   ├── gst_rate.dart                   # GST rate enum
│   ├── unit_of_measure.dart            # UOM enum
│   ├── expense_category.dart           # Expense category
│   ├── payment_mode.dart               # Payment mode
│   └── employee_status.dart            # Employee status
│
├── exceptions/                         # Domain exceptions
│   ├── domain_exception.dart           # Base exception
│   ├── validation_exception.dart       # Validation error
│   ├── not_found_exception.dart        # Missing entity
│   └── business_rule_exception.dart    # Rule violation
│
├── repositories/                       # Repository interfaces
│   ├── product_repository.dart         # Product contract
│   ├── invoice_repository.dart         # Invoice contract
│   ├── purchase_repository.dart        # Purchase contract
│   ├── expense_repository.dart        # Expense contract
│   ├── employee_repository.dart        # Employee contract
│   └── user_settings_repository.dart    # Settings contract
│
├── services/                           # Domain services
│   ├── invoice_number_service.dart     # Invoice numbering
│   ├── stock_update_service.dart       # Stock operations
│   ├── pdf_generation_service.dart     # PDF generation
│   └── export_service.dart             # Data export
│
└── value_objects/                      # Value objects
    ├── date_range.dart                 # Date range VO
    ├── address.dart                    # Address VO
    ├── money.dart                      # Money VO
    ├── gst_breakdown.dart              # GST calculation VO
    └── invoice_line_item.dart          # Line item VO
```

### 4.3 Entity Definition Example

```dart
// lib/domain/entities/product.dart

class Product extends Equatable {
  final String id;
  final String name;
  final String hsnCode;
  final int gstRate;
  final double price;
  final int stock;
  final String unit;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const Product({
    required this.id,
    required this.name,
    required this.hsnCode,
    required this.gstRate,
    required this.price,
    required this.stock,
    required this.unit,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });
  
  bool get isLowStock => stock <= 10;
  
  double getPriceWithGst() => price * (1 + gstRate / 100);
  
  Product copyWith({...}) => ...;
  
  @override
  List<Object?> get props => [id, name, hsnCode, price, stock];
}
```

---

## 5. Features Layer (`lib/features/`)

### 5.1 Purpose
Each feature is a self-contained module implementing a specific business capability. Features follow a consistent internal structure.

### 5.2 Feature Structure Template

```
lib/features/{feature_name}/
├── data/
│   ├── models/                         # Feature-specific models
│   └── repositories/                   # Feature repository implementations (if any)
│
├── domain/
│   ├── entities/                       # Feature-specific entities (if any)
│   └── repositories/                   # Feature repository interfaces (if any)
│
├── presentation/
│   ├── providers/                      # Feature Riverpod providers
│   ├── screens/                        # Feature screens
│   ├── widgets/                        # Feature-specific widgets
│   ├── forms/                          # Form widgets
│   └── states/                         # State classes
│
├── usecases/                           # Feature use cases
│
└── {feature_name}_module.dart          # Feature exports
```

### 5.3 Feature: Products Example

```
lib/features/products/
├── data/
│   └── (uses shared repositories)
│
├── domain/
│   └── (uses shared entities)
│
├── presentation/
│   ├── providers/
│   │   ├── product_list_provider.dart       # Product list state
│   │   ├── product_form_provider.dart         # Form state
│   │   └── product_search_provider.dart       # Search state
│   │
│   ├── screens/
│   │   ├── product_list_screen.dart         # List screen
│   │   ├── product_detail_screen.dart       # Detail screen
│   │   ├── add_product_screen.dart          # Add screen
│   │   └── edit_product_screen.dart         # Edit screen
│   │
│   ├── widgets/
│   │   ├── product_card.dart                # Product card
│   │   ├── product_list_item.dart           # List item
│   │   ├── stock_indicator.dart             # Stock badge
│   │   └── product_search_bar.dart          # Search bar
│   │
│   ├── forms/
│   │   ├── product_form.dart                # Main form
│   │   ├── product_form_fields.dart         # Form fields
│   │   └── product_validation.dart          # Validation
│   │
│   └── states/
│       ├── product_list_state.dart          # List state
│       └── product_form_state.dart          # Form state
│
├── usecases/
│   ├── get_products_usecase.dart            # List products
│   ├── create_product_usecase.dart          # Create product
│   ├── update_product_usecase.dart          # Update product
│   ├── delete_product_usecase.dart          # Delete product
│   └── search_products_usecase.dart         # Search products
│
└── products_module.dart                     # Feature exports
```

### 5.4 Feature Module Example

```dart
// lib/features/products/products_module.dart

// Providers
export 'presentation/providers/product_list_provider.dart';
export 'presentation/providers/product_form_provider.dart';

// Screens
export 'presentation/screens/product_list_screen.dart';
export 'presentation/screens/product_detail_screen.dart';
export 'presentation/screens/add_product_screen.dart';
export 'presentation/screens/edit_product_screen.dart';

// Widgets
export 'presentation/widgets/product_card.dart';
export 'presentation/widgets/stock_indicator.dart';

// Use cases
export 'usecases/get_products_usecase.dart';
export 'usecases/create_product_usecase.dart';
export 'usecases/update_product_usecase.dart';
export 'usecases/delete_product_usecase.dart';

// Routes
class ProductRoutes {
  static List<RouteBase> get routes => [
    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductListScreen(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) => const AddProductScreen(),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) => ProductDetailScreen(
            id: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: ':id/edit',
          builder: (context, state) => EditProductScreen(
            id: state.pathParameters['id']!,
          ),
        ),
      ],
    ),
  ];
}
```

---

## 6. Shared Layer (`lib/shared/`)

### 6.1 Purpose
Contains UI components and utilities shared across multiple features. This layer has no business logic.

### 6.2 Structure

```
lib/shared/
├── widgets/
│   ├── buttons/
│   │   ├── primary_button.dart              # Main CTA button
│   │   ├── secondary_button.dart            # Secondary button
│   │   ├── icon_button.dart                 # Icon button
│   │   └── loading_button.dart              # Async button
│   │
│   ├── cards/
│   │   ├── summary_card.dart                # Dashboard card
│   │   ├── info_card.dart                   # Info display
│   │   └── stat_card.dart                   # Statistic card
│   │
│   ├── inputs/
│   │   ├── text_input.dart                  # Text field
│   │   ├── number_input.dart                # Number field
│   │   ├── date_input.dart                  # Date picker
│   │   ├── dropdown_input.dart              # Dropdown
│   │   ├── search_input.dart                # Search field
│   │   └── currency_input.dart              # Currency field
│   │
│   ├── feedback/
│   │   ├── loading_indicator.dart           # Loading spinner
│   │   ├── error_widget.dart                # Error display
│   │   ├── empty_state.dart                 # Empty state
│   │   └── success_toast.dart               # Success message
│   │
│   ├── layout/
│   │   ├── responsive_layout.dart           # Responsive wrapper
│   │   ├── scrollable_container.dart        # Scrollable view
│   │   └── section_header.dart              # Section divider
│   │
│   └── data/
│       ├── data_table.dart                  # Table widget
│       ├── pagination.dart                  # Pagination
│       └── sortable_list.dart               # Sortable list
│
├── dialogs/
│   ├── confirm_dialog.dart                  # Confirmation dialog
│   ├── alert_dialog.dart                    # Alert dialog
│   ├── bottom_sheet_dialog.dart             # Bottom sheet
│   ├── date_picker_dialog.dart              # Date picker
│   └── filter_dialog.dart                   # Filter dialog
│
├── forms/
│   ├── form_builder.dart                    # Form builder
│   ├── form_field_wrapper.dart              # Field wrapper
│   ├── form_validation.dart                 # Validation messages
│   └── form_section.dart                    # Form section
│
└── animations/
    ├── fade_transition.dart                 # Fade animation
    ├── slide_transition.dart                # Slide animation
    ├── loading_shimmer.dart                 # Shimmer effect
    └── page_transition.dart                 # Page transition
```

---

## 7. Dependency Injection

### 7.1 Provider Setup

```dart
// lib/core/providers/dependency_injection.dart

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Repositories
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(
    ref.watch(firestoreProvider),
    ref.watch(localDatabaseProvider),
    ref.watch(connectivityProvider),
  );
});

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  return InvoiceRepositoryImpl(
    ref.watch(firestoreProvider),
    ref.watch(productRepositoryProvider),
  );
});

// ... other repositories

// Use cases
final getProductsUseCaseProvider = Provider<GetProductsUseCase>((ref) {
  return GetProductsUseCase(ref.watch(productRepositoryProvider));
});

final createInvoiceUseCaseProvider = Provider<CreateInvoiceUseCase>((ref) {
  return CreateInvoiceUseCase(
    ref.watch(invoiceRepositoryProvider),
    ref.watch(productRepositoryProvider),
    ref.watch(stockUpdateServiceProvider),
  );
});

// ... other use cases
```

---

## 8. Import Rules

### 8.1 Layer Dependencies

| Layer | Can Import From | Cannot Import From |
|-------|-----------------|-------------------|
| `core` | None (bottom layer) | features, data, domain |
| `data` | core, domain | features |
| `domain` | core | data, features |
| `features` | core, data, domain, shared | Other features (use interfaces) |
| `shared` | core | data, domain, features |

### 8.2 Feature Isolation

Features should not directly import from other features. Use:
- Core providers for shared state
- Domain repositories for data access
- Shared widgets for UI components

---

## 9. File Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Screens | `{name}_screen.dart` | `product_list_screen.dart` |
| Widgets | `{name}.dart` | `product_card.dart` |
| Providers | `{name}_provider.dart` | `product_list_provider.dart` |
| Models | `{name}_model.dart` | `product_model.dart` |
| Entities | `{name}.dart` | `product.dart` |
| Use Cases | `{action}_{resource}_usecase.dart` | `create_product_usecase.dart` |
| Repositories | `{resource}_repository.dart` | `product_repository.dart` |
| Extensions | `{type}_extensions.dart` | `date_time_extensions.dart` |

---

**End of Document**
