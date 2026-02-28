# SmartERP API Contracts (Repository Layer)

**Version:** 1.0  
**Date:** February 2026  
**Status:** Production  
**Pattern:** Repository Pattern with Firestore Backend

---

## 1. Architecture Overview

### 1.1 Repository Pattern Structure

```
┌─────────────────────────────────────────────────────────────────┐
│                     REPOSITORY LAYER                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                     Interface Layer                        │  │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────┐ │  │
│  │  │ Product  │ │  Invoice │ │ Purchase │ │   Expense    │ │  │
│  │  │   Repo   │ │   Repo   │ │   Repo   │ │    Repo      │ │  │
│  │  │Interface │ │Interface │ │Interface │ │  Interface   │ │  │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────────┘ │  │
│  └───────────────────────────────────────────────────────────┘  │
│                              │                                   │
│                              ▼                                   │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                  Implementation Layer                      │  │
│  │  ┌─────────────────────────────────────────────────────┐ │  │
│  │  │            FirestoreRepositoryImpl                   │ │  │
│  │  │  ┌──────────────┐  ┌──────────────┐                 │ │  │
│  │  │  │   Firestore  │  │ Local Cache  │                 │ │  │
│  │  │  │   Client     │  │   (Hive)     │                 │ │  │
│  │  │  └──────────────┘  └──────────────┘                 │ │  │
│  │  └─────────────────────────────────────────────────────┘ │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 Repository Contract Philosophy

| Principle | Implementation |
|-----------|---------------|
| **Abstract Data Source** | Interface hides Firestore implementation |
| **Async-First** | All operations return Future/Stream |
| **Error Propagation** | Domain-specific exceptions |
| **Batch Operations** | Support for atomic multi-document writes |
| **Local Cache Integration** | Transparent caching layer |

---

## 2. Repository Interfaces

### 2.1 Product Repository

```dart
// lib/domain/repositories/product_repository.dart

import 'package:smart_erp/domain/entities/product.dart';

/// Repository contract for Product operations
abstract class ProductRepository {
  /// Watch all products for a user (real-time stream)
  /// 
  /// Returns stream of products sorted by name
  /// Emits updates on any product change
  Stream<List<Product>> watchAll(String userId);
  
  /// Get all products (one-time fetch)
  /// 
  /// [userId] - Firebase Auth UID
  /// Returns list of active products
  /// Throws [RepositoryException] on failure
  Future<List<Product>> getAll(String userId);
  
  /// Get product by ID
  /// 
  /// [userId] - Firebase Auth UID
  /// [productId] - Firestore document ID
  /// Returns null if not found
  /// Throws [RepositoryException] on failure
  Future<Product?> getById(String userId, String productId);
  
  /// Create new product
  /// 
  /// [userId] - Firebase Auth UID
  /// [product] - Product entity to create
  /// Returns created product with generated ID
  /// Throws [ValidationException] if validation fails
  /// Throws [RepositoryException] on failure
  Future<Product> create(String userId, Product product);
  
  /// Update existing product
  /// 
  /// [userId] - Firebase Auth UID
  /// [product] - Product with updated values
  /// Returns updated product
  /// Throws [NotFoundException] if product doesn't exist
  /// Throws [RepositoryException] on failure
  Future<Product> update(String userId, Product product);
  
  /// Delete product (soft delete)
  /// 
  /// [userId] - Firebase Auth UID
  /// [productId] - Product to delete
  /// Actually sets isActive to false
  /// Throws [NotFoundException] if product doesn't exist
  Future<void> delete(String userId, String productId);
  
  /// Get products with low stock
  /// 
  /// [userId] - Firebase Auth UID
  /// [threshold] - Optional custom threshold (default: 10)
  /// Returns products where stock <= threshold
  Future<List<Product>> getLowStock(String userId, {int threshold = 10});
  
  /// Search products by name
  /// 
  /// [userId] - Firebase Auth UID
  /// [query] - Search string (case-insensitive partial match)
  /// Returns matching products
  Future<List<Product>> search(String userId, String query);
  
  /// Update stock quantity
  /// 
  /// [userId] - Firebase Auth UID
  /// [productId] - Product to update
  /// [newStock] - New stock value
  /// [reason] - Reason for update (audit trail)
  Future<void> updateStock(
    String userId, 
    String productId, 
    int newStock, {
    String? reason,
  });
  
  /// Batch update multiple products
  /// 
  /// Atomic operation - all succeed or all fail
  /// [userId] - Firebase Auth UID
  /// [products] - List of products to update
  Future<void> batchUpdate(String userId, List<Product> products);
}
```

### 2.2 Invoice (Sales) Repository

```dart
// lib/domain/repositories/invoice_repository.dart

import 'package:smart_erp/domain/entities/invoice.dart';
import 'package:smart_erp/domain/value_objects/date_range.dart';

/// Repository contract for Invoice operations
abstract class InvoiceRepository {
  /// Watch invoices in date range (real-time stream)
  /// 
  /// [userId] - Firebase Auth UID
  /// [dateRange] - Optional date filter
  /// Returns stream sorted by date descending
  Stream<List<Invoice>> watchByDateRange(
    String userId, {
    DateRange? dateRange,
  });
  
  /// Get invoices by date range (one-time fetch)
  /// 
  /// [userId] - Firebase Auth UID
  /// [dateRange] - Date filter
  /// [limit] - Optional limit (default: 100)
  /// [lastDocument] - For pagination
  Future<List<Invoice>> getByDateRange(
    String userId, 
    DateRange dateRange, {
    int limit = 100,
    String? lastDocument,
  });
  
  /// Get invoice by ID
  /// 
  /// [userId] - Firebase Auth UID
  /// [invoiceId] - Invoice document ID
  /// Returns null if not found
  Future<Invoice?> getById(String userId, String invoiceId);
  
  /// Get invoice by invoice number
  /// 
  /// [userId] - Firebase Auth UID
  /// [invoiceNumber] - Formatted invoice number (INV-YYYY-XXXXX)
  Future<Invoice?> getByNumber(String userId, String invoiceNumber);
  
  /// Create new invoice with automatic stock reduction
  /// 
  /// This is an atomic operation:
  /// 1. Saves invoice document
  /// 2. Updates product stocks
  /// 3. Marks invoice as locked
  /// 
  /// [userId] - Firebase Auth UID
  /// [invoice] - Invoice to create
  /// [lineItems] - Invoice line items with product references
  /// Returns created invoice with generated ID and number
  /// 
  /// Throws [InsufficientStockException] if stock unavailable
  /// Throws [ValidationException] if validation fails
  /// Throws [RepositoryException] on failure
  Future<Invoice> create(
    String userId, 
    Invoice invoice, 
    List<InvoiceLineItem> lineItems,
  );
  
  /// Get next invoice number
  /// 
  /// [userId] - Firebase Auth UID
  /// Returns next sequential invoice number for current fiscal year
  Future<String> getNextInvoiceNumber(String userId);
  
  /// Check if invoice number exists
  /// 
  /// [userId] - Firebase Auth UID
  /// [invoiceNumber] - Number to check
  Future<bool> invoiceNumberExists(String userId, String invoiceNumber);
  
  /// Get monthly invoice totals
  /// 
  /// [userId] - Firebase Auth UID
  /// [month] - Target month
  /// Returns total sales amount for month
  Future<double> getMonthlyTotal(String userId, DateTime month);
  
  /// Generate and store PDF
  /// 
  /// [userId] - Firebase Auth UID
  /// [invoiceId] - Invoice to generate PDF for
  /// [pdfBytes] - PDF binary data
  /// Returns download URL
  Future<String> storePdf(String userId, String invoiceId, Uint8List pdfBytes);
  
  /// Get PDF download URL
  /// 
  /// [userId] - Firebase Auth UID
  /// [invoiceId] - Invoice ID
  /// Returns URL or null if PDF not generated
  Future<String?> getPdfUrl(String userId, String invoiceId);
}
```

### 2.3 Purchase Repository

```dart
// lib/domain/repositories/purchase_repository.dart

import 'package:smart_erp/domain/entities/purchase.dart';

/// Repository contract for Purchase operations
abstract class PurchaseRepository {
  /// Watch purchases in date range
  Stream<List<Purchase>> watchByDateRange(
    String userId, {
    DateRange? dateRange,
  });
  
  /// Get purchases by date range
  Future<List<Purchase>> getByDateRange(
    String userId, 
    DateRange dateRange, {
    int limit = 100,
  });
  
  /// Get purchase by ID
  Future<Purchase?> getById(String userId, String purchaseId);
  
  /// Create purchase with stock increase
  /// 
  /// Atomic operation:
  /// 1. Saves purchase
  /// 2. Updates product stocks
  Future<Purchase> create(
    String userId, 
    Purchase purchase, 
    List<PurchaseLineItem> lineItems,
  );
  
  /// Update purchase (within 24h window)
  /// 
  /// [purchase] - Updated purchase
  /// [stockAdjustments] - Stock changes to apply
  /// Throws [EditWindowExpiredException] if > 24h
  Future<Purchase> update(
    String userId, 
    Purchase purchase,
    List<StockAdjustment> stockAdjustments,
  );
  
  /// Delete purchase
  /// 
  /// Reverts stock changes
  Future<void> delete(String userId, String purchaseId);
  
  /// Get monthly purchase totals
  Future<double> getMonthlyTotal(String userId, DateTime month);
  
  /// Get next purchase number
  Future<String> getNextPurchaseNumber(String userId);
}
```

### 2.4 Expense Repository

```dart
// lib/domain/repositories/expense_repository.dart

import 'package:smart_erp/domain/entities/expense.dart';

/// Repository contract for Expense operations
abstract class ExpenseRepository {
  /// Watch expenses in date range
  Stream<List<Expense>> watchByDateRange(
    String userId, {
    DateRange? dateRange,
    String? category,
  });
  
  /// Get expenses by date range
  Future<List<Expense>> getByDateRange(
    String userId, 
    DateRange dateRange, {
    String? category,
  });
  
  /// Get expense by ID
  Future<Expense?> getById(String userId, String expenseId);
  
  /// Create expense
  Future<Expense> create(String userId, Expense expense);
  
  /// Update expense (within 24h window)
  /// Throws [EditWindowExpiredException] if > 24h
  Future<Expense> update(String userId, Expense expense);
  
  /// Delete expense
  Future<void> delete(String userId, String expenseId);
  
  /// Get monthly expense totals
  Future<double> getMonthlyTotal(String userId, DateTime month);
  
  /// Get expenses grouped by category
  Future<Map<String, double>> getCategoryTotals(
    String userId, 
    DateRange dateRange,
  );
  
  /// Store receipt image
  Future<String> storeReceipt(
    String userId, 
    String expenseId, 
    Uint8List imageBytes,
  );
}
```

### 2.5 Employee Repository

```dart
// lib/domain/repositories/employee_repository.dart

import 'package:smart_erp/domain/entities/employee.dart';

/// Repository contract for Employee operations
abstract class EmployeeRepository {
  /// Watch all employees
  Stream<List<Employee>> watchAll(String userId);
  
  /// Get all employees
  Future<List<Employee>> getAll(String userId);
  
  /// Get employee by ID
  Future<Employee?> getById(String userId, String employeeId);
  
  /// Create employee
  Future<Employee> create(String userId, Employee employee);
  
  /// Update employee
  Future<Employee> update(String userId, Employee employee);
  
  /// Soft delete employee
  Future<void> delete(String userId, String employeeId);
  
  /// Mark employee as resigned
  Future<Employee> markResigned(
    String userId, 
    String employeeId, 
    DateTime resignationDate,
  );
  
  /// Search employees by name
  Future<List<Employee>> search(String userId, String query);
  
  /// Get active employees count
  Future<int> getActiveCount(String userId);
}
```

### 2.6 Salary Payment Repository

```dart
// lib/domain/repositories/salary_payment_repository.dart

import 'package:smart_erp/domain/entities/salary_payment.dart';

/// Repository contract for Salary Payment operations
abstract class SalaryPaymentRepository {
  /// Watch salary payments for employee
  Stream<List<SalaryPayment>> watchByEmployee(
    String userId, 
    String employeeId,
  );
  
  /// Get payments for employee
  Future<List<SalaryPayment>> getByEmployee(
    String userId, 
    String employeeId, {
    int limit = 24, // 2 years
  });
  
  /// Get payment by ID
  Future<SalaryPayment?> getById(String userId, String paymentId);
  
  /// Record salary payment
  /// 
  /// Also creates corresponding expense entry
  Future<SalaryPayment> create(
    String userId, 
    SalaryPayment payment,
  );
  
  /// Check if salary already paid for month
  Future<bool> isSalaryPaid(
    String userId, 
    String employeeId, 
    int month, 
    int year,
  );
  
  /// Get monthly salary total
  Future<double> getMonthlyTotal(String userId, DateTime month);
  
  /// Get payment history for month
  Future<List<SalaryPayment>> getByMonth(
    String userId, 
    int month, 
    int year,
  );
}
```

### 2.7 User Settings Repository

```dart
// lib/domain/repositories/user_settings_repository.dart

import 'package:smart_erp/domain/entities/user_settings.dart';
import 'package:smart_erp/domain/entities/user_profile.dart';

/// Repository contract for User Settings operations
abstract class UserSettingsRepository {
  /// Watch user profile
  Stream<UserProfile?> watchProfile(String userId);
  
  /// Get user profile
  Future<UserProfile?> getProfile(String userId);
  
  /// Create/update user profile
  Future<UserProfile> saveProfile(String userId, UserProfile profile);
  
  /// Watch user settings
  Stream<UserSettings> watchSettings(String userId);
  
  /// Get user settings
  Future<UserSettings> getSettings(String userId);
  
  /// Save user settings
  Future<UserSettings> saveSettings(String userId, UserSettings settings);
  
  /// Update specific setting
  Future<UserSettings> updateSetting(
    String userId, 
    String key, 
    dynamic value,
  );
  
  /// Store business logo
  Future<String> storeLogo(String userId, Uint8List imageBytes);
  
  /// Get logo URL
  Future<String?> getLogoUrl(String userId);
}
```

---

## 3. Data Transfer Objects (DTOs)

### 3.1 Input Models

```dart
// lib/data/models/create_product_dto.dart

/// DTO for creating a new product
class CreateProductDto {
  final String name;
  final String hsnCode;
  final int gstRate;
  final double price;
  final int stock;
  final String unit;
  final String? description;
  final double? costPrice;
  final String? category;
  
  CreateProductDto({
    required this.name,
    required this.hsnCode,
    required this.gstRate,
    required this.price,
    required this.stock,
    required this.unit,
    this.description,
    this.costPrice,
    this.category,
  });
  
  /// Validation
  ValidationResult validate() {
    final errors = <String, String>{};
    
    if (name.trim().length < 2) {
      errors['name'] = 'Name must be at least 2 characters';
    }
    if (name.trim().length > 100) {
      errors['name'] = 'Name must not exceed 100 characters';
    }
    
    if (!RegExp(r'^\d{4,8}$').hasMatch(hsnCode)) {
      errors['hsnCode'] = 'HSN code must be 4-8 digits';
    }
    
    if (![0, 5, 12, 18, 28].contains(gstRate)) {
      errors['gstRate'] = 'Invalid GST rate';
    }
    
    if (price <= 0) {
      errors['price'] = 'Price must be greater than zero';
    }
    
    if (stock < 0) {
      errors['stock'] = 'Stock cannot be negative';
    }
    
    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }
  
  Map<String, dynamic> toJson() => {
    'name': name.trim(),
    'hsnCode': hsnCode,
    'gstRate': gstRate,
    'price': price,
    'stock': stock,
    'unit': unit,
    'description': description,
    'costPrice': costPrice,
    'category': category,
    'isActive': true,
  };
}

// lib/data/models/create_invoice_dto.dart

/// DTO for creating a new invoice
class CreateInvoiceDto {
  final String customerName;
  final String customerAddress;
  final String? customerGstin;
  final String? customerPhone;
  final List<InvoiceLineItemDto> lineItems;
  final String? notes;
  final String? terms;
  
  CreateInvoiceDto({
    required this.customerName,
    required this.customerAddress,
    this.customerGstin,
    this.customerPhone,
    required this.lineItems,
    this.notes,
    this.terms,
  });
  
  ValidationResult validate() {
    final errors = <String, String>{};
    
    if (customerName.trim().length < 2) {
      errors['customerName'] = 'Customer name required';
    }
    
    if (customerAddress.trim().length < 10) {
      errors['customerAddress'] = 'Complete address required';
    }
    
    if (lineItems.isEmpty) {
      errors['lineItems'] = 'At least one item required';
    }
    
    for (var i = 0; i < lineItems.length; i++) {
      final itemErrors = lineItems[i].validate();
      if (!itemErrors.isValid) {
        errors['item_$i'] = itemErrors.errors.toString();
      }
    }
    
    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }
}

/// Line item for invoice creation
class InvoiceLineItemDto {
  final String productId;
  final double quantity;
  final double rate;
  
  InvoiceLineItemDto({
    required this.productId,
    required this.quantity,
    required this.rate,
  });
  
  ValidationResult validate() {
    final errors = <String, String>{};
    
    if (productId.isEmpty) {
      errors['productId'] = 'Product required';
    }
    
    if (quantity <= 0) {
      errors['quantity'] = 'Quantity must be positive';
    }
    
    if (rate <= 0) {
      errors['rate'] = 'Rate must be positive';
    }
    
    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }
}
```

### 3.2 Output/Response Models

```dart
// lib/data/models/repository_response.dart

/// Generic repository response wrapper
class RepositoryResponse<T> {
  final bool success;
  final T? data;
  final RepositoryError? error;
  final String? message;
  
  RepositoryResponse._({
    required this.success,
    this.data,
    this.error,
    this.message,
  });
  
  factory RepositoryResponse.success(T data, {String? message}) =>
      RepositoryResponse._(
        success: true,
        data: data,
        message: message,
      );
  
  factory RepositoryResponse.error(RepositoryError error, {String? message}) =>
      RepositoryResponse._(
        success: false,
        error: error,
        message: message,
      );
  
  R when<R>({
    required R Function(T data) success,
    required R Function(RepositoryError error) error,
  }) {
    if (this.success && data != null) {
      return success(data as T);
    }
    return error(this.error!);
  }
}

/// Repository error types
abstract class RepositoryError {
  final String code;
  final String message;
  final dynamic details;
  
  RepositoryError(this.code, this.message, {this.details});
}

class NetworkError extends RepositoryError {
  NetworkError({String? message, dynamic details})
      : super('NETWORK_ERROR', message ?? 'Network connection failed', details: details);
}

class NotFoundError extends RepositoryError {
  NotFoundError({String? resource})
      : super('NOT_FOUND', 'Resource not found: $resource');
}

class ValidationError extends RepositoryError {
  final Map<String, String> fieldErrors;
  
  ValidationError({required this.fieldErrors})
      : super('VALIDATION_ERROR', 'Validation failed');
}

class InsufficientStockError extends RepositoryError {
  final String productId;
  final String productName;
  final int requested;
  final int available;
  
  InsufficientStockError({
    required this.productId,
    required this.productName,
    required this.requested,
    required this.available,
  }) : super(
         'INSUFFICIENT_STOCK',
         'Only $available units available for $productName (requested: $requested)',
       );
}

class EditWindowExpiredError extends RepositoryError {
  final DateTime createdAt;
  final Duration window;
  
  EditWindowExpiredError({required this.createdAt, required this.window})
      : super(
         'EDIT_WINDOW_EXPIRED',
         'Edit window closed. Document created at $createdAt, window: ${window.inHours}h',
       );
}

class QuotaExceededError extends RepositoryError {
  QuotaExceededError() : super('QUOTA_EXCEEDED', 'Firebase quota exceeded');
}
```

---

## 4. Error Handling Strategy

### 4.1 Error Handling Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                     ERROR HANDLING FLOW                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐      ┌──────────────┐      ┌──────────────┐  │
│  │   Firestore  │      │   Local      │      │   Business   │  │
│  │    Error     │      │   Cache      │      │   Logic      │  │
│  └──────┬───────┘      └──────┬───────┘      └──────┬───────┘  │
│         │                     │                     │          │
│         └───────────┬─────────┴─────────┬───────────┘          │
│                     │                     │                    │
│                     ▼                     ▼                    │
│            ┌─────────────────────────────────────┐             │
│            │      Repository Implementation       │             │
│            │  • Catches platform exceptions        │             │
│            │  • Translates to domain exceptions    │             │
│            │  • Implements retry logic             │             │
│            └──────────────────┬──────────────────┘             │
│                               │                                 │
│                               ▼                                 │
│            ┌─────────────────────────────────────┐             │
│            │         Use Case / Service           │             │
│            │  • Handles business-level errors      │             │
│            │  • Orchestrates recovery              │             │
│            └──────────────────┬──────────────────┘             │
│                               │                                 │
│                               ▼                                 │
│            ┌─────────────────────────────────────┐             │
│            │         Presentation Layer           │             │
│            │  • Displays user-friendly errors    │             │
│            │  • Implements retry UI             │             │
│            └─────────────────────────────────────┘             │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 Error Recovery Strategies

| Error Type | Recovery Strategy | User Message |
|------------|------------------|--------------|
| Network Error | Queue for retry | "Will sync when online" |
| Not Found | Log error, return null | "Item not found" |
| Validation | Show field errors | "Please check input fields" |
| Insufficient Stock | Block operation | "Only X units available" |
| Quota Exceeded | Pause sync, alert | "Daily limit reached" |
| Permission Denied | Logout, redirect | "Session expired" |

---

## 5. Data Validation Layer

### 5.1 Validation Pipeline

```dart
// lib/data/validation/validation_pipeline.dart

/// Validation pipeline for repository operations
class ValidationPipeline {
  final List<ValidationStep> _steps = [];
  
  ValidationPipeline add(ValidationStep step) {
    _steps.add(step);
    return this;
  }
  
  ValidationResult execute<T>(T input) {
    final errors = <String, String>{};
    
    for (final step in _steps) {
      final result = step.validate(input);
      if (!result.isValid) {
        errors.addAll(result.errors);
      }
    }
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}

abstract class ValidationStep<T> {
  ValidationResult validate(T input);
}

/// Required fields validator
class RequiredFieldsValidator implements ValidationStep<Map<String, dynamic>> {
  final List<String> requiredFields;
  
  RequiredFieldsValidator(this.requiredFields);
  
  @override
  ValidationResult validate(Map<String, dynamic> input) {
    final errors = <String, String>{};
    
    for (final field in requiredFields) {
      if (!input.containsKey(field) || input[field] == null) {
        errors[field] = '$field is required';
      }
    }
    
    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }
}

/// Type validator
class TypeValidator implements ValidationStep<Map<String, dynamic>> {
  final Map<String, Type> fieldTypes;
  
  TypeValidator(this.fieldTypes);
  
  @override
  ValidationResult validate(Map<String, dynamic> input) {
    final errors = <String, String>{};
    
    fieldTypes.forEach((field, expectedType) {
      if (input.containsKey(field)) {
        final value = input[field];
        if (value != null && value.runtimeType != expectedType) {
          errors[field] = '$field must be ${expectedType.toString()}';
        }
      }
    });
    
    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }
}

/// Range validator
class RangeValidator implements ValidationStep<Map<String, dynamic>> {
  final String field;
  final num min;
  final num max;
  
  RangeValidator(this.field, {required this.min, required this.max});
  
  @override
  ValidationResult validate(Map<String, dynamic> input) {
    if (!input.containsKey(field)) {
      return ValidationResult.success();
    }
    
    final value = input[field];
    if (value is! num) {
      return ValidationResult.error({field: '$field must be a number'});
    }
    
    if (value < min || value > max) {
      return ValidationResult.error({
        field: '$field must be between $min and $max'
      });
    }
    
    return ValidationResult.success();
  }
}
```

---

**End of Document**
