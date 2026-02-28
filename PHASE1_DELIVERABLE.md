# SmartERP — Phase 1 Deep Analysis Deliverable

**Target:** Flutter Windows Desktop ERP | Firebase Spark (FREE) | Single User | Client-Heavy | Offline

---

## 1. Architecture Summary

### 1.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    PRESENTATION (Flutter UI — Windows Desktop)                │
│  Screens │ Providers (Riverpod) │ NavigationRail │ DataTables │ Forms       │
└─────────────────────────────────────────┬───────────────────────────────────┘
                                          │ never imports data/domain directly
                                          ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         DOMAIN (Pure Dart, no Flutter)                        │
│  Entities │ Repository Contracts │ Use Cases │ Value Objects │ Calculations │
└─────────────────────────────────────────┬───────────────────────────────────┘
                                          │ data layer implements repos
                                          ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         DATA (Repository Implementations)                    │
│  DTOs │ Mappers │ Firestore DataSource │ Offline Cache │ Batch Writes       │
└─────────────────────────────────────────┬───────────────────────────────────┘
                                          │
                                          ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                    EXTERNAL: Firebase (Auth, Firestore, Storage)             │
│  Spark Plan only │ Offline persistence │ No Cloud Functions │ No paid APIs  │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 Engineering Constraints (from docs)

| Constraint | Source | Implication |
|------------|--------|-------------|
| UI must never access Firestore | Clean Architecture | All data via repositories only |
| Domain cannot import Flutter | Clean Architecture | Entities, repos, use cases are pure Dart |
| Repository abstract in domain | 6_api_contracts, 7_monorepo | Interface in domain, impl in data |
| DTOs never in UI | 6_api_contracts | UI receives entities from use cases/providers |
| Use cases contain business logic | 4_system_architecture | GST, stock, profit in use cases |
| No Cloud Functions | PRD, MVP_Tech_Doc | All logic client-side |
| No Razorpay / paid WhatsApp API | PRD, Architecture | Excluded |
| Single user, SaaS-ready structure only | PRD | Data under `users/{uid}/` |
| Firebase Spark only | All docs | &lt; 50K reads/day, 20K writes/day |
| Reports & aggregation client-side only | 5_data_base_schema, MVP_Tech_Doc | No Firestore aggregation queries |

### 1.3 Information Architecture (Navigation — Windows)

- **Shell:** NavigationRail (left) + TopBar + main content.
- **Auth:** Splash → Login / Register / Forgot Password.
- **Main:** Dashboard (default), Sales, Products, Purchases, Expenses, Payroll, Reports, Settings (drawer or rail).
- **Flows:** List → Detail → Edit/Create; Invoice: List → Create → PDF/Share.

---

## 2. Feature Checklist (from PRD + User Stories + Phase 4 Requirements)

### 2.1 Product Management
- [ ] CRUD (Create, Read, Update, Soft Delete)
- [ ] GST % (0, 5, 12, 18, 28)
- [ ] HSN Code (4–8 digits)
- [ ] Stock tracking, low stock threshold
- [ ] Price history (store priceAtSale in invoice line only; no separate table)
- [ ] Bulk import/export (CSV)
- [ ] Real-time price update in invoice (cached product list)

### 2.2 Invoice System
- [ ] Add products (line items with product ref, qty, rate)
- [ ] Auto GST (CGST + SGST; IGST for inter-state if needed)
- [ ] Extra cost in bill (optional line or adjustment)
- [ ] Custom margin calculator (optional)
- [ ] Real-time recalculation on change
- [ ] priceAtSale snapshot per line
- [ ] Invoice locking (immutable after save)
- [ ] Batched write (invoice + stock update atomic)
- [ ] PDF generation (local, offline)
- [ ] WhatsApp share (desktop share intent / file open only)

### 2.3 Sales Tracking
- [ ] History list with date filter
- [ ] Profit per sale (computed client-side)
- [ ] Re-download / view PDF

### 2.4 Purchase Tracking
- [ ] Supplier (name, GSTIN, address)
- [ ] Stock increment on purchase
- [ ] Purchase history

### 2.5 Expense Management
- [ ] CRUD
- [ ] Category (Salary, Rent, Utilities, etc.)
- [ ] Date filter, monthly summary
- [ ] CSV export (local)

### 2.6 Payroll
- [ ] Employee CRUD
- [ ] Salary marking (month, amount, date, mode)
- [ ] Due indicator (unpaid months)
- [ ] Salary history

### 2.7 Dashboard
- [ ] Total Sales, Purchases, Expenses, Salary Paid
- [ ] Net Profit (Sales - Purchases - Expenses - Salary)
- [ ] GST Summary (output vs input)
- [ ] Low stock alerts
- [ ] Charts (Syncfusion Community or fl_chart)

### 2.8 Reports Engine (Client-Side Only)
- [ ] Monthly revenue, expense breakdown, P&L, GST summary
- [ ] Product performance, salary expense report
- [ ] Export PDF & CSV (local aggregation only)

### 2.9 Inventory Conflict Resolution (Phase 5)
- [ ] Stock validation before invoice save
- [ ] Atomic batch write (invoice + stock)
- [ ] Re-check stock before commit
- [ ] Prevent negative stock, duplicate invoice numbers
- [ ] Double-click prevention, optimistic UI rollback
- [ ] Offline-safe sync, conflict detection (client-only)

---

## 3. Folder Structure Blueprint

```
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── error/                 # Failures, exceptions, handler
│   ├── utils/                 # Logger, formatters, validators
│   ├── theme/                 # theme.dart, colors, typography, spacing
│   ├── router/                # GoRouter config, routes
│   ├── constants/             # App + Firebase paths, enums
│   └── network/               # Connectivity (optional)
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── product/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── invoice/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── sales/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── purchase/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── expense/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── payroll/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── dashboard/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── reports/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── settings/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── shared/
│   ├── widgets/               # PrimaryButton, AppDataTable, AppDialog, etc.
│   └── services/              # PDF service, export service (if shared)
│
└── data/                      # Shared data layer (repos impl, DTOs, mappers)
    ├── datasources/
    │   ├── remote/            # Firestore
    │   └── local/             # Hive/cache if used
    ├── models/                # DTOs (product_dto, invoice_dto, ...)
    ├── mappers/               # DTO ↔ Entity
    └── repositories/          # *RepositoryImpl
```

Each feature contains:
- **data/** — feature-specific DTOs/datasources if any; else uses shared data.
- **domain/** — entities (or re-export), repository interface (if feature-specific), use cases.
- **presentation/** — screens, widgets, providers (Riverpod).

---

## 4. Layer Responsibility Mapping

| Layer | Responsibility | Can Import | Cannot Import |
|-------|----------------|------------|----------------|
| **Presentation** | UI, forms, navigation, consume providers only | core, shared, domain (entities/value objects via providers), use case interfaces via providers | data (no DTOs), Firestore, Firebase |
| **Domain** | Entities, repo contracts, use cases, business rules, calculations | core (utils, errors, constants — no Flutter) | Flutter, data, presentation |
| **Data** | Repository implementations, DTOs, mappers, Firestore/cache | core, domain | presentation |
| **Core** | Theme, router, errors, utils, constants | — | features (no feature imports) |
| **Shared** | Reusable widgets, shared services | core, Flutter | data (no DTO in widget API), domain entities OK via params |

### Data Flow (Example: Create Invoice)

1. **UI** calls `ref.read(createInvoiceProvider.notifier).create(...)` with form data (entity or DTO-like map).
2. **Provider** (presentation) uses `CreateInvoiceUseCase` (domain).
3. **Use case** validates, computes totals (GST), calls `InvoiceRepository.create()` and `ProductRepository.updateStock()`; coordinates batch.
4. **Repository** (data) maps to DTOs, runs batch write (invoice + stock updates), returns entity.
5. **UI** observes provider state; never sees DTOs.

### Repository Contract Placement

- **Domain:** `ProductRepository`, `InvoiceRepository`, `PurchaseRepository`, `ExpenseRepository`, `EmployeeRepository`, `SalaryPaymentRepository`, `UserSettingsRepository` (abstract).
- **Data:** `ProductRepositoryImpl`, `InvoiceRepositoryImpl`, etc., plus DTOs and mappers.

---

## 5. Database Schema (Firestore) — Summary

- **users/{userId}** — profile/settings docs.
- **users/{userId}/products/{productId}**
- **users/{userId}/sales/{saleId}** (invoices)
- **users/{userId}/purchases/{purchaseId}**
- **users/{userId}/expenses/{expenseId}**
- **users/{userId}/employees/{employeeId}**
- **users/{userId}/salary_payments/{paymentId}**

All access: `request.auth != null && request.auth.uid == userId`. Locked invoices: no update/delete.

---

## 6. Performance Rules (Spark Plan)

- Minimize reads: cache product list, avoid redundant listeners.
- Pagination for sales/purchases/expenses (e.g. limit 50).
- Batch writes for invoice + stock.
- Local aggregation for dashboard and reports (no Firestore aggregation).
- Use Riverpod `.select()` to avoid rebuild storms.
- DataTable: virtualize or paginate for large lists (e.g. 50k records).
- Desktop-optimized layout: NavigationRail, wide forms, dense tables.

---

*End of Phase 1 Deliverable. Proceed to Phase 2–8 implementation.*
