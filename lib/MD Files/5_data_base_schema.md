# SmartERP Database Schema

**Version:** 1.0  
**Date:** February 2026  
**Status:** Production  
**Database:** Cloud Firestore (Firebase)

---

## 1. Schema Design Philosophy

### 1.1 Design Principles

| Principle | Implementation |
|-----------|---------------|
| **User Isolation** | All data nested under `users/{userId}` |
| **Denormalization** | Duplication for read efficiency |
| **Document Size** | Maximum 500KB per document |
| **Query Optimization** | Flat structure, single collection queries |
| **Free Tier Compliance** | Minimize deep queries, favor local aggregation |

### 1.2 Collection Structure Overview

```
users/{userId}/
├── profile (document)
├── settings (document)
├── products/{productId} (collection)
├── sales/{saleId} (collection)
├── purchases/{purchaseId} (collection)
├── expenses/{expenseId} (collection)
├── employees/{employeeId} (collection)
└── salary_payments/{paymentId} (collection)
```

---

## 2. Collection Definitions

### 2.1 Users Collection

**Path:** `users/{userId}`

#### User Profile Document

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `userId` | String | Auto | Firebase Auth UID |
| `email` | String | Yes | User email address |
| `businessName` | String | Yes | Display business name |
| `businessType` | String | No | Manufacturing/Trading/etc |
| `gstin` | String | No | GST Registration Number |
| `phone` | String | No | Contact number |
| `address` | Map | No | Business address structure |
| `address.street` | String | No | Street address |
| `address.city` | String | No | City |
| `address.state` | String | No | State |
| `address.pincode` | String | No | PIN code |
| `bankDetails` | Map | No | Bank information |
| `bankDetails.accountName` | String | No | Account holder name |
| `bankDetails.accountNumber` | String | No | Account number |
| `bankDetails.ifscCode` | String | No | IFSC code |
| `bankDetails.bankName` | String | No | Bank name |
| `invoiceConfig` | Map | No | Invoice settings |
| `invoiceConfig.prefix` | String | No | Invoice number prefix |
| `invoiceConfig.terms` | String | No | Default terms & conditions |
| `createdAt` | Timestamp | Auto | Account creation |
| `updatedAt` | Timestamp | Auto | Last update |
| `lastLoginAt` | Timestamp | Auto | Last successful login |

#### User Settings Document

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `lowStockThreshold` | Integer | No | 10 | Alert threshold |
| `defaultGstRate` | Integer | No | 18 | Default GST % |
| `currency` | String | No | INR | Currency code |
| `fiscalYearStart` | String | No | 04 | Month (April) |
| `dateFormat` | String | No | DD/MM/YYYY | Display format |
| `theme` | String | No | system | light/dark/system |
| `notificationsEnabled` | Boolean | No | true | Push notifications |
| `offlineMode` | Boolean | No | true | Enable offline sync |

---

### 2.2 Products Collection

**Path:** `users/{userId}/products/{productId}`

| Field | Type | Required | Constraints | Description |
|-------|------|----------|-------------|-------------|
| `productId` | String | Auto | Unique | Firestore document ID |
| `name` | String | Yes | 2-100 chars | Product name |
| `description` | String | No | Max 500 chars | Detailed description |
| `hsnCode` | String | Yes | 4-8 digits | Harmonized System Code |
| `gstRate` | Number | Yes | [0,5,12,18,28] | GST percentage |
| `price` | Number | Yes | > 0 | Unit selling price |
| `costPrice` | Number | No | >= 0 | Unit cost price |
| `stock` | Integer | Yes | >= 0 | Current stock quantity |
| `unit` | String | Yes | Enum | Unit of measurement |
| `lowStockThreshold` | Integer | No | Default 10 | Custom threshold |
| `isActive` | Boolean | Yes | Default true | Product status |
| `category` | String | No | Custom | Product category |
| `createdAt` | Timestamp | Auto | - | Creation timestamp |
| `updatedAt` | Timestamp | Auto | - | Last update |
| `imageUrl` | String | No | URL | Product image reference |

#### Unit Enum Values

| Value | Description |
|-------|-------------|
| `PCS` | Pieces |
| `KG` | Kilograms |
| `LTR` | Liters |
| `MTR` | Meters |
| `BOX` | Boxes |
| `SET` | Sets |
| `PKT` | Packets |
| `BAG` | Bags |
| `DOZ` | Dozens |

---

### 2.3 Sales (Invoices) Collection

**Path:** `users/{userId}/sales/{saleId}`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `saleId` | String | Auto | Firestore document ID |
| `invoiceNumber` | String | Yes | Formatted: INV-YYYY-XXXXX |
| `invoiceDate` | Timestamp | Yes | Invoice date |
| `customer` | Map | Yes | Customer information |
| `customer.name` | String | Yes | Customer name |
| `customer.address` | String | Yes | Customer address |
| `customer.gstin` | String | No | Customer GSTIN |
| `customer.phone` | String | No | Customer phone |
| `lineItems` | Array | Yes | Invoice line items |
| `lineItems[].productId` | String | Yes | Product reference |
| `lineItems[].productName` | String | Yes | Denormalized name |
| `lineItems[].hsnCode` | String | Yes | Denormalized HSN |
| `lineItems[].quantity` | Number | Yes | Item quantity |
| `lineItems[].unit` | String | Yes | Unit of measurement |
| `lineItems[].rate` | Number | Yes | Price per unit |
| `lineItems[].gstRate` | Number | Yes | GST % at time of sale |
| `lineItems[].amount` | Number | Yes | quantity × rate |
| `lineItems[].gstAmount` | Number | Yes | Calculated GST |
| `lineItems[].totalAmount` | Number | Yes | amount + gstAmount |
| `summary` | Map | Yes | Invoice totals |
| `summary.subtotal` | Number | Yes | Sum of line amounts |
| `summary.totalCgst` | Number | Yes | Total CGST |
| `summary.totalSgst` | Number | Yes | Total SGST |
| `summary.totalIgst` | Number | Yes | Total IGST |
| `summary.totalGst` | Number | Yes | Total tax |
| `summary.roundOff` | Number | Yes | Rounding adjustment |
| `summary.totalAmount` | Number | Yes | Final total |
| `summary.amountInWords` | String | Yes | Text representation |
| `isLocked` | Boolean | Auto | Always true |
| `pdfUrl` | String | No | Generated PDF reference |
| `notes` | String | No | Internal notes |
| `terms` | String | No | Payment terms |
| `createdAt` | Timestamp | Auto | Creation timestamp |
| `updatedAt` | Timestamp | Auto | Same as created (immutable) |

#### Document Size Considerations

| Field Category | Estimated Size |
|---------------|----------------|
| Base fields | ~500 bytes |
| Customer data | ~300 bytes |
| Line items (10 items) | ~2,000 bytes |
| Summary | ~200 bytes |
| **Total (10 item invoice)** | **~3 KB** |
| **Max (50 items)** | **~12 KB** |

---

### 2.4 Purchases Collection

**Path:** `users/{userId}/purchases/{purchaseId}`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `purchaseId` | String | Auto | Firestore document ID |
| `purchaseNumber` | String | Yes | Formatted: PUR-YYYY-XXXXX |
| `purchaseDate` | Timestamp | Yes | Purchase date |
| `supplier` | Map | Yes | Supplier information |
| `supplier.name` | String | Yes | Supplier name |
| `supplier.gstin` | String | No | Supplier GSTIN |
| `supplier.address` | String | No | Supplier address |
| `lineItems` | Array | Yes | Purchase items |
| `lineItems[].productId` | String | Yes | Product reference |
| `lineItems[].productName` | String | Yes | Denormalized |
| `lineItems[].hsnCode` | String | Yes | Denormalized |
| `lineItems[].quantity` | Number | Yes | Quantity |
| `lineItems[].rate` | Number | Yes | Cost per unit |
| `lineItems[].gstRate` | Number | Yes | Input GST % |
| `summary` | Map | Yes | Purchase totals |
| `summary.subtotal` | Number | Yes | Pre-tax amount |
| `summary.totalCgst` | Number | Yes | Input CGST |
| `summary.totalSgst` | Number | Yes | Input SGST |
| `summary.totalAmount` | Number | Yes | Final total |
| `notes` | String | No | Purchase notes |
| `isLocked` | Boolean | No | Locked after 24h |
| `createdAt` | Timestamp | Auto | Creation |
| `updatedAt` | Timestamp | Auto | Last update |

---

### 2.5 Expenses Collection

**Path:** `users/{userId}/expenses/{expenseId}`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `expenseId` | String | Auto | Firestore document ID |
| `amount` | Number | Yes | Expense amount |
| `category` | String | Yes | Expense category |
| `subCategory` | String | No | Detailed classification |
| `description` | String | No | Description |
| `expenseDate` | Timestamp | Yes | Date of expense |
| `paymentMode` | String | No | Cash/Bank/UPI/Cheque |
| `gstAmount` | Number | No | GST on expense (if applicable) |
| `gstRate` | Number | No | GST rate on expense |
| `vendor` | String | No | Vendor/Payee name |
| `billNumber` | String | No | Reference number |
| `isRecurring` | Boolean | No | Monthly recurring |
| `recurringDay` | Integer | No | Day of month (1-31) |
| `isLocked` | Boolean | Auto | Locked after 24h |
| `receiptUrl` | String | No | Receipt image reference |
| `createdAt` | Timestamp | Auto | Creation timestamp |
| `updatedAt` | Timestamp | Auto | Last update |

#### Expense Categories

| Category | Default GST | Common Sub-categories |
|----------|-------------|----------------------|
| `SALARY` | 0% | Employee wages |
| `RENT` | 0% | Factory, Office, Godown |
| `UTILITIES` | 18% | Electricity, Water, Internet |
| `RAW_MATERIAL` | As per HSN | Purchase inputs |
| `TRANSPORT` | 12% | Logistics, Delivery |
| `MAINTENANCE` | 18% | Repairs, Service |
| `OFFICE_SUPPLIES` | 18% | Stationery, Printing |
| `MARKETING` | 18% | Advertising, Promotion |
| `TRAVEL` | 5% | Conveyance, Accommodation |
| `INSURANCE` | 18% | Premiums |
| `TAXES` | N/A | Professional tax, Licenses |
| `OTHER` | 0% | Miscellaneous |

---

### 2.6 Employees Collection

**Path:** `users/{userId}/employees/{employeeId}`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `employeeId` | String | Auto | Firestore document ID |
| `fullName` | String | Yes | Employee full name |
| `employeeCode` | String | No | Internal code |
| `designation` | String | Yes | Job title |
| `department` | String | No | Department |
| `joiningDate` | Timestamp | Yes | Date of joining |
| `monthlySalary` | Number | Yes | Gross monthly salary |
| `basicSalary` | Number | No | Basic component |
| `hra` | Number | No | House rent allowance |
| `da` | Number | No | Dearness allowance |
| `otherAllowances` | Number | No | Other components |
| `deductions` | Map | No | Standard deductions |
| `deductions.pf` | Number | No | Provident fund |
| `deductions.esi` | Number | No | ESI contribution |
| `deductions.tds` | Number | No | Tax deduction |
| `netSalary` | Number | Computed | monthlySalary - deductions |
| `phone` | String | No | Contact number |
| `email` | String | No | Email address |
| `address` | String | No | Residential address |
| `bankDetails` | Map | No | Payment details |
| `bankDetails.accountNumber` | String | No | Account number |
| `bankDetails.ifscCode` | String | No | IFSC code |
| `bankDetails.bankName` | String | No | Bank name |
| `emergencyContact` | Map | No | Emergency info |
| `documents` | Array | No | Document references |
| `status` | String | Yes | ACTIVE, ON_LEAVE, RESIGNED |
| `resignationDate` | Timestamp | No | If resigned |
| `isActive` | Boolean | Yes | Current employee |
| `createdAt` | Timestamp | Auto | Creation timestamp |
| `updatedAt` | Timestamp | Auto | Last update |

---

### 2.7 Salary Payments Collection

**Path:** `users/{userId}/salary_payments/{paymentId}`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `paymentId` | String | Auto | Firestore document ID |
| `employeeId` | String | Yes | Reference to employee |
| `employeeName` | String | Yes | Denormalized name |
| `month` | Integer | Yes | Payment month (1-12) |
| `year` | Integer | Yes | Payment year |
| `monthYear` | String | Yes | Composite: "YYYY-MM" |
| `amount` | Number | Yes | Paid amount |
| `paymentDate` | Timestamp | Yes | Date of payment |
| `paymentMode` | String | Yes | Cash/Bank/UPI/Cheque |
| `workingDays` | Integer | No | Days worked |
| `paidDays` | Integer | No | Days paid |
| `overtimeHours` | Number | No | OT hours |
| `overtimeAmount` | Number | No | OT pay |
| `bonus` | Number | No | Bonus/Incentive |
| `deductions` | Number | No | Advances/Loans |
| `netPaid` | Number | Computed | Final amount |
| `notes` | String | No | Payment notes |
| `transactionRef` | String | No | Bank/UPI reference |
| `isLocked` | Boolean | Auto | true (immutable) |
| `createdAt` | Timestamp | Auto | Creation timestamp |

---

## 3. Indexing Recommendations

### 3.1 Single Field Indexes

| Collection | Field | Index Type | Purpose |
|------------|-------|------------|---------|
| `products` | `isActive` | Ascending | Filter active products |
| `products` | `stock` | Ascending | Low stock alerts |
| `sales` | `invoiceDate` | Descending | Recent invoices first |
| `sales` | `invoiceNumber` | Ascending | Search by number |
| `purchases` | `purchaseDate` | Descending | Recent purchases |
| `expenses` | `expenseDate` | Descending | Recent expenses |
| `expenses` | `category` | Ascending | Filter by category |
| `salary_payments` | `monthYear` | Descending | Payment history |
| `salary_payments` | `employeeId` | Ascending | Employee payments |

### 3.2 Composite Indexes

| Collection | Fields | Query Pattern |
|------------|--------|---------------|
| `products` | `isActive` ASC, `stock` ASC | Active products with low stock |
| `sales` | `invoiceDate` DESC, `totalAmount` DESC | Recent large invoices |
| `expenses` | `category` ASC, `expenseDate` DESC | Category-wise recent expenses |
| `salary_payments` | `employeeId` ASC, `monthYear` DESC | Employee salary history |

---

## 4. Free-Tier Optimization Notes

### 4.1 Query Optimization Strategies

| Strategy | Implementation | Read Savings |
|----------|---------------|--------------|
| **Single Collection Stream** | `collection.snapshots()` | 70% |
| **Local Aggregation** | Fetch once, compute in Dart | 60% |
| **Pagination** | `limit(50)` with cursor | 80% |
| **Date Range Filtering** | Fetch range, filter locally | 40% |
| **Selective Field Retrieval** | Not used (Firestore limitation) | N/A |

### 4.2 Document Count Estimates

| Document Type | Estimated Monthly | Annual Growth |
|--------------|-------------------|---------------|
| Products | 50-100 total | 100-200 |
| Sales/Invoices | 100-500 | 1,200-6,000 |
| Purchases | 50-200 | 600-2,400 |
| Expenses | 100-300 | 1,200-3,600 |
| Employees | 10-50 total | 20-100 |
| Salary Payments | 10-50/month | 120-600 |
| **Total Documents** | **~400-1,200/month** | **~5,000-15,000/year** |

### 4.3 Storage Calculation

| Content Type | Average Size | Monthly Volume | Annual |
|--------------|--------------|----------------|--------|
| Documents (JSON) | 2 KB each | 1-3 MB | 12-36 MB |
| Invoice PDFs | 100 KB each | 10-50 MB | 120-600 MB |
| Receipt Images | 500 KB each | 10-50 MB | 120-600 MB |
| Logo/Assets | 200 KB | < 1 MB | < 1 MB |
| **Total Storage** | - | **~25-105 MB/month** | **~300 MB - 1.2 GB/year** |

### 4.4 Free Tier Limits Assessment

| Metric | Free Limit | Projected Usage | Buffer |
|--------|-----------|-----------------|--------|
| Reads | 50,000/day | < 15,000/day | 70% |
| Writes | 20,000/day | < 5,000/day | 75% |
| Deletes | 20,000/day | < 500/day | 97% |
| Storage | 1 GB | < 800 MB/year | 20% |
| Bandwidth | 10 GB/month | < 3 GB/month | 70% |

---

## 5. Data Validation Rules

### 5.1 Firestore Security Rules (Validation)

```javascript
// Validation for invoice creation
function isValidInvoice() {
  return request.resource.data.keys().hasAll([
    'invoiceNumber', 'customer', 'lineItems', 'summary', 'createdAt'
  ])
  && request.resource.data.invoiceNumber is string
  && request.resource.data.invoiceNumber.matches('^INV-[0-9]{4}-[0-9]{5}$')
  && request.resource.data.lineItems is list
  && request.resource.data.lineItems.size() > 0
  && request.resource.data.lineItems.size() <= 100
  && request.resource.data.summary.totalAmount is number
  && request.resource.data.summary.totalAmount > 0
  && request.resource.data.createdAt == request.time;
}

// Validation for product
function isValidProduct() {
  return request.resource.data.keys().hasAll([
    'name', 'hsnCode', 'gstRate', 'price', 'stock', 'unit', 'isActive'
  ])
  && request.resource.data.name is string
  && request.resource.data.name.size() >= 2
  && request.resource.data.name.size() <= 100
  && request.resource.data.hsnCode is string
  && request.resource.data.hsnCode.matches('^[0-9]{4,8}$')
  && request.resource.data.gstRate in [0, 5, 12, 18, 28]
  && request.resource.data.price is number
  && request.resource.data.price > 0
  && request.resource.data.stock is number
  && request.resource.data.stock >= 0
  && request.resource.data.isActive is bool;
}
```

### 5.2 Client-Side Validation

| Operation | Validation Layer | Error Handling |
|-----------|-----------------|----------------|
| Create Product | Client before Firestore | Immediate feedback |
| Create Invoice | Client (complex calculations) | Form-level errors |
| Update Stock | Client (transaction safety) | Rollback on failure |
| Add Expense | Client (required fields) | Field highlighting |

---

## 6. Data Migration Considerations

### 6.1 Versioning Strategy

| Schema Version | Date | Changes |
|---------------|------|---------|
| 1.0 | Feb 2026 | Initial release |

### 6.2 Future Schema Evolution

| Potential Change | Migration Strategy |
|-----------------|-------------------|
| Add product variants | New `variants` subcollection |
| Add customer master | New `customers` collection |
| Add inventory batches | New `inventory_batches` collection |
| Multi-location support | Add `locationId` to documents |

---

**End of Document**
