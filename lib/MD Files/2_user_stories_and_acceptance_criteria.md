# SmartERP User Stories and Acceptance Criteria

**Version:** 1.0  
**Date:** February 2026  
**Status:** Production

---

## 1. User Personas

### 1.1 Primary Persona: Factory Owner (Rajesh Kumar)
| Attribute | Details |
|-----------|---------|
| **Demographics** | Age 42, owns small manufacturing unit (15-20 workers) |
| **Technical Proficiency** | Basic smartphone user, uses WhatsApp, YouTube |
| **Business Context** | Produces electrical components, turnover ₹25-50 lakhs/year |
| **Pain Points** | Manual bookkeeping, GST filing confusion, stock mismatches |
| **Goals** | Track daily sales, know exact profit, file GST without accountant |
| **Device** | Android smartphone (₹12,000-15,000 range) |
| **Usage Pattern** | 30-45 minutes daily, mostly evening hours |

### 1.2 Secondary Persona: Production Manager (Anita Sharma)
| Attribute | Details |
|-----------|---------|
| **Demographics** | Age 35, manages day-to-day operations |
| **Technical Proficiency** | Comfortable with mobile apps, basic Excel |
| **Business Context** | Oversees inventory, coordinates with suppliers |
| **Pain Points** | Running out of raw materials, unplanned purchases |
| **Goals** | Maintain optimal stock levels, track material usage |
| **Device** | Android smartphone, occasionally tablet |
| **Usage Pattern** | Multiple short sessions throughout the day |

### 1.3 Tertiary Persona: Accountant (Freelance)
| Attribute | Details |
|-----------|---------|
| **Demographics** | Part-time GST return filer |
| **Technical Proficiency** | Tally/Excel expert |
| **Business Context** | Files monthly GST, reconciles books |
| **Pain Points** | Client provides unorganized data |
| **Goals** | Export clean data, verify calculations |
| **Device** | Laptop primary, phone for communication |
| **Usage Pattern** | Once a month, intensive data export session |

---

## 2. User Stories

### 2.1 Product Management (PROD)

#### PROD-01: Create New Product
**Story:**
> As a Factory Owner, I want to add a new product to the system so that I can track its inventory and include it in invoices.

**Acceptance Criteria:**
```gherkin
Given I am on the Products screen
When I tap the "Add Product" button
Then I see a form with fields: Name, HSN Code, GST Rate, Price, Initial Stock, Unit

Given I fill all required fields with valid data
When I tap "Save"
Then the product is saved
And I see a success message "Product created successfully"
And the product appears in the product list

Given I leave required fields empty
When I tap "Save"
Then I see validation errors highlighting empty fields
And the product is not saved

Given I enter an invalid HSN code (less than 4 digits)
When I tap "Save"
Then I see an error "HSN Code must be 4-8 digits"
And the product is not saved

Given I enter a negative price
When I tap "Save"
Then I see an error "Price must be greater than zero"
And the product is not saved
```

**Edge Cases:**
| Scenario | Expected Behavior |
|----------|-------------------|
| Duplicate product name | Allow with warning, store with unique ID |
| Special characters in name | Allow alphanumeric, hyphen, space |
| Very long name (>100 chars) | Truncate at 100, show counter |
| Zero initial stock | Allow, mark as "Out of Stock" |

---

#### PROD-02: Edit Product
**Story:**
> As a Factory Owner, I want to update product details so that the information remains accurate when prices or GST rates change.

**Acceptance Criteria:**
```gherkin
Given I am viewing the product list
When I tap on a product
Then I see the product details screen

Given I tap the "Edit" button
When I modify valid fields
And tap "Save"
Then changes are saved
And "Updated At" timestamp is refreshed

Given the product has existing sales history
When I change the price or GST rate
Then I see a warning "Price change will not affect past invoices"
And changes are saved
```

**Validation Rules:**
| Field | Rule | Error Message |
|-------|------|---------------|
| Price | > 0 | "Price must be positive" |
| GST Rate | In [0, 5, 12, 18, 28] | "Select valid GST rate" |
| Stock | >= 0 | "Stock cannot be negative" |

---

#### PROD-03: View Product Stock Status
**Story:**
> As a Production Manager, I want to see which products are running low on stock so that I can plan purchases in advance.

**Acceptance Criteria:**
```gherkin
Given I am on the Products screen
When I view the product list
Then each product shows current stock quantity

Given a product has stock <= 10 (configurable threshold)
When I view the list
Then the product is highlighted with a red indicator

Given I tap on "Low Stock" filter
Then only products below threshold are displayed

Given I am creating an invoice
When I select a product with zero stock
Then the product is disabled in selection
And I see "Out of Stock" label
```

---

### 2.2 Invoice System (INV)

#### INV-01: Create Sales Invoice
**Story:**
> As a Factory Owner, I want to generate a GST-compliant invoice for my customers so that I can maintain proper sales records and provide professional documentation.

**Acceptance Criteria:**
```gherkin
Given I am on the Sales screen
When I tap "Create Invoice"
Then I see an invoice creation form

Given I enter customer details (Name, Address)
And I add at least one line item with valid product and quantity
When I view the invoice summary
Then I see:
  - Subtotal (sum of line item amounts)
  - CGST amount (calculated correctly)
  - SGST amount (calculated correctly)
  - Total amount (subtotal + taxes)
  - Amount in words

Given I tap "Generate Invoice"
When the invoice is saved
Then:
  - Invoice number auto-generates (format: INV-YYYY-XXXXX)
  - Invoice is locked (no edit allowed)
  - Stock is reduced for each product
  - PDF is generated
  - I see options to Share PDF or View

Given I try to save an invoice without line items
When I tap "Generate Invoice"
Then I see error "Add at least one product"
And invoice is not created
```

**GST Calculation Verification:**
| Product Price | GST% | CGST | SGST | Total |
|---------------|------|------|------|-------|
| ₹1000 | 18% | ₹90 | ₹90 | ₹1180 |
| ₹500 | 12% | ₹30 | ₹30 | ₹560 |
| ₹250 | 5% | ₹6.25 | ₹6.25 | ₹262.50 |

---

#### INV-02: Invoice Immutability
**Story:**
> As a Factory Owner, I want invoices to be locked after creation so that my financial records remain tamper-proof and audit-ready.

**Acceptance Criteria:**
```gherkin
Given an invoice has been created and saved
When I view the invoice details
Then I see a "LOCKED" indicator
And there is no "Edit" button

Given I attempt to modify a locked invoice via any means
Then the system prevents modification
And logs the attempt (if possible)

Given I need to correct an invoice
When I contact support (future feature)
Then I can create a credit note (separate document)
```

---

#### INV-03: Generate Invoice PDF
**Story:**
> As a Factory Owner, I want to generate a professional PDF invoice that I can share via WhatsApp or print for my customers.

**Acceptance Criteria:**
```gherkin
Given I have created and saved an invoice
When I tap "Download PDF" or "Share"
Then a PDF is generated within 3 seconds
And the PDF contains:
  - Company header (user-configurable)
  - Invoice number and date
  - Customer details
  - Line items with HSN codes
  - GST breakdown (CGST, SGST, IGST if applicable)
  - Total amount in numbers and words
  - Terms and conditions section

Given the PDF is generated
When I tap "Share"
Then the system opens the native share sheet
With PDF attached

Given I am offline
When I generate PDF
Then PDF is created from cached data
And queued for sync (if needed)
```

---

#### INV-04: Invoice Numbering
**Story:**
> As a Factory Owner, I want invoices to have sequential numbers so that my records are organized and compliant with tax regulations.

**Acceptance Criteria:**
```gherkin
Given it is the fiscal year 2025-26
When I create my first invoice
Then the invoice number is "INV-2025-00001"

Given I have created 50 invoices this year
When I create the next invoice
Then the invoice number is "INV-2025-00051"

Given it is a new fiscal year (April 1)
When I create the first invoice
Then the counter resets to "INV-2026-00001"

Given I delete a draft invoice (before finalization)
When I check the next invoice number
Then the sequence continues without gap
```

---

### 2.3 Inventory Management (STOCK)

#### STOCK-01: Automatic Stock Reduction
**Story:**
> As a Production Manager, I want the system to automatically reduce stock when I create a sales invoice so that my inventory records stay accurate without manual updates.

**Acceptance Criteria:**
```gherkin
Given Product A has 100 units in stock
When I create an invoice with 5 units of Product A
And the invoice is saved
Then Product A stock becomes 95 units
And the change is reflected immediately in the product list

Given Product B has 3 units in stock
When I try to create an invoice with 5 units of Product B
Then the system blocks the action
And shows error "Insufficient stock: Only 3 units available"
And the invoice is not created

Given an invoice with 10 units is created
When the stock update occurs
Then it happens as an atomic transaction with invoice save
Either both succeed, or both fail
```

---

#### STOCK-02: Purchase Entry and Stock Increase
**Story:**
> As a Factory Owner, I want to record purchases so that my stock levels increase and I can track input GST for tax filing.

**Acceptance Criteria:**
```gherkin
Given I am on the Purchases screen
When I tap "Add Purchase"
Then I see a form similar to invoice creation

Given I select a product and enter quantity and rate
When I save the purchase
Then:
  - Stock increases by the quantity
  - Purchase record is saved
  - Input GST is recorded for GST summary

Given I enter a purchase for a new product (not in catalog)
When I save
Then the system offers to "Add as New Product" or select existing
```

---

#### STOCK-03: Low Stock Alerts
**Story:**
> As a Production Manager, I want to be alerted when products are running low on stock so that I can reorder before stockout.

**Acceptance Criteria:**
```gherkin
Given the low stock threshold is set to 10 units
When any product stock drops to 10 or below
Then:
  - The product is highlighted in red in the list
  - A "Low Stock" badge appears on the product
  - Dashboard shows "X products low on stock" indicator

Given I am on the Dashboard
When I tap the low stock indicator
Then I am taken to the Products screen with low stock filter applied

Given I receive a low stock alert
When I update stock via purchase entry
Then the alert clears automatically
```

---

### 2.4 Expense Management (EXP)

#### EXP-01: Record Business Expense
**Story:**
> As a Factory Owner, I want to record all business expenses so that I can track my actual profit and claim tax deductions.

**Acceptance Criteria:**
```gherkin
Given I am on the Expenses screen
When I tap "Add Expense"
Then I see a form with:
  - Amount (required)
  - Category dropdown (required)
  - Description (optional)
  - Date (default today)
  - Notes (optional)

Given I fill valid expense data
When I tap "Save"
Then the expense is recorded
And it appears in the expense list
And Dashboard expense total updates

Given I leave amount empty
When I tap "Save"
Then I see error "Amount is required"
And expense is not saved
```

---

#### EXP-02: Expense Categorization
**Story:**
> As a Factory Owner, I want to categorize expenses so that I can understand where my money is going and prepare for tax filing.

**Acceptance Criteria:**
```gherkin
Given I am adding an expense
When I tap the Category field
Then I see predefined categories:
  - Salary
  - Rent
  - Utilities
  - Raw Material
  - Transport
  - Maintenance
  - Other

Given I select "Other" category
When I save the expense
Then I am prompted to enter a custom category name
And it is saved for future use

Given I view the Expense Summary
When I filter by month
Then expenses are grouped by category with totals
And I see a percentage breakdown
```

---

#### EXP-03: Expense Date Filtering
**Story:**
> As a Factory Owner, I want to filter expenses by date range so that I can review expenses for specific periods.

**Acceptance Criteria:**
```gherkin
Given I am on the Expenses screen
When I tap the filter icon
Then I see preset options:
  - Today
  - This Week
  - This Month
  - Last Month
  - Custom Range

Given I select "This Month"
Then the list shows only expenses from current month
And the header shows total for the filtered period

Given I select "Custom Range"
When I select start and end dates
Then the list filters to that range
And the URL/screen state reflects the filter (for sharing)
```

---

#### EXP-04: Expense Editing Window
**Story:**
> As a Factory Owner, I want to be able to correct expense entries within a limited time so that I can fix mistakes without compromising record integrity.

**Acceptance Criteria:**
```gherkin
Given I created an expense 2 hours ago
When I view the expense details
Then I see an "Edit" button

Given I tap "Edit"
When I modify and save within 24 hours of creation
Then changes are saved
And "Updated At" timestamp is recorded

Given the expense was created 25 hours ago
When I view the expense details
Then the "Edit" button is disabled
And I see "Locked - Created > 24 hours ago"

Given I need to correct an old expense
When I contact support (future)
Then I can add a reversing entry (new expense with negative amount)
```

---

### 2.5 Payroll Management (PAY)

#### PAY-01: Add Employee
**Story:**
> As a Factory Owner, I want to maintain a list of my employees so that I can track salary payments and maintain payroll records.

**Acceptance Criteria:**
```gherkin
Given I am on the Employees screen
When I tap "Add Employee"
Then I see a form with:
  - Full Name (required)
  - Designation (required)
  - Joining Date (required)
  - Monthly Salary (required)
  - Bank Account Number (optional)
  - IFSC Code (optional)
  - Phone Number (optional)

Given I fill all required fields
When I tap "Save"
Then the employee is saved
And appears in the employee list
And is marked as "Active"

Given I enter a future joining date
When I tap "Save"
Then I see error "Joining date cannot be in the future"
```

---

#### PAY-02: Mark Salary Paid
**Story:**
> As a Factory Owner, I want to record when I have paid an employee's salary so that I can track total salary expenses and payment history.

**Acceptance Criteria:**
```gherkin
Given I am viewing an employee's details
When I tap "Mark Salary Paid"
Then I see a form with:
  - Month/Year selector (default current month)
  - Amount (default: monthly salary)
  - Payment Date (default today)
  - Payment Mode (Cash/Bank/UPI)
  - Notes (optional)

Given I confirm the salary payment
When I tap "Save"
Then:
  - The payment is recorded
  - It appears in the employee's salary history
  - It is added to the Expenses (Salary category)
  - Dashboard salary total updates

Given I try to mark salary for an already-paid month
When I tap "Save"
Then I see warning "Salary already recorded for [Month Year]"
And I can choose to overwrite or cancel
```

---

#### PAY-03: View Salary History
**Story:**
> As a Factory Owner, I want to view an employee's complete salary payment history so that I can resolve any payment disputes.

**Acceptance Criteria:**
```gherkin
Given I am viewing an employee's details
When I tap "Salary History"
Then I see a chronological list of all salary payments:
  - Month/Year
  - Amount Paid
  - Payment Date
  - Payment Mode
  - Status (Paid/Pending)

Given I tap on any salary record
Then I see the complete payment details

Given I am at year-end
When I view salary history
Then I see annual total and can export to PDF/CSV
```

---

### 2.6 Dashboard and Analytics (DASH)

#### DASH-01: Financial Overview Dashboard
**Story:**
> As a Factory Owner, I want to see my business financial summary at a glance so that I can make informed decisions quickly.

**Acceptance Criteria:**
```gherkin
Given I open the app
When the Dashboard loads
Then I see cards showing:
  - Total Sales (this month)
  - Total Purchases (this month)
  - Total Expenses (this month)
  - Salary Payout (this month)
  - Net Profit (calculated)

Given I tap on any card
When I tap
Then I am taken to the detailed view of that category

Given I pull down on the Dashboard
When I refresh
Then the data updates from Firestore
And I see a "Last updated: [timestamp]" indicator

Given I am offline
When I open the Dashboard
Then I see cached data
And an "Offline Mode" indicator
```

---

#### DASH-02: GST Summary
**Story:**
> As a Factory Owner, I want to see my GST liability summary so that I can prepare for monthly GST filing.

**Acceptance Criteria:**
```gherkin
Given I navigate to GST Summary
When the screen loads
Then I see:
  - Output GST section (from sales):
    - CGST collected
    - SGST collected
    - IGST collected
  - Input GST section (from purchases):
    - CGST paid
    - SGST paid
    - IGST paid
  - Net GST Payable/Receivable

Given the net is positive (payable)
Then the amount is shown in red with "Payable" label

Given the net is negative (receivable)
Then the amount is shown in green with "Receivable" label

Given I select a different month from the dropdown
When I select
Then the GST summary updates for that month
```

---

#### DASH-03: Sales Chart
**Story:**
> As a Factory Owner, I want to see my sales trend over time so that I can identify business patterns and seasonal variations.

**Acceptance Criteria:**
```gherkin
Given I am on the Dashboard
When I scroll to the Sales Chart section
Then I see a bar/line chart showing:
  - Daily sales for current month, OR
  - Monthly sales for current year

Given I tap on the chart
When I tap
Then I can toggle between views:
  - Last 7 Days
  - This Month
  - This Quarter
  - This Year

Given I tap on a specific bar/point
When I tap
Then I see the exact amount for that period
```

---

### 2.7 Authentication and Settings (AUTH)

#### AUTH-01: User Registration
**Story:**
> As a Factory Owner, I want to create an account so that my business data is secure and accessible only to me.

**Acceptance Criteria:**
```gherkin
Given I open the app for the first time
When I navigate to Sign Up
Then I see a form with:
  - Email Address
  - Password (min 8 chars, complexity required)
  - Confirm Password
  - Business Name

Given I enter valid information
When I tap "Create Account"
Then:
  - Account is created in Firebase Auth
  - User profile is created in Firestore
  - I am taken to the Dashboard
  - Welcome tutorial begins

Given I enter an already-registered email
When I tap "Create Account"
Then I see error "Account already exists"
And I am offered to sign in instead
```

---

#### AUTH-02: User Login
**Story:**
> As a Factory Owner, I want to log in to my account so that I can access my business data securely.

**Acceptance Criteria:**
```gherkin
Given I am on the Login screen
When I enter valid email and password
And tap "Sign In"
Then I am logged in
And taken to the Dashboard

Given I enter an incorrect password
When I tap "Sign In"
Then I see error "Invalid email or password"
And the password field is cleared

Given I tap "Forgot Password"
When I enter my email
And tap "Reset"
Then a password reset email is sent
And I see confirmation "Check your email"

Given I enable "Remember Me"
When I close and reopen the app
Then I remain logged in (up to 30 days)
```

---

#### AUTH-03: Business Profile Setup
**Story:**
> As a Factory Owner, I want to configure my business details so that they appear correctly on invoices and reports.

**Acceptance Criteria:**
```gherkin
Given I navigate to Settings > Business Profile
When I view the screen
Then I see fields for:
  - Business Name
  - GSTIN (optional)
  - Address (multi-line)
  - Phone Number
  - Email
  - Logo (optional, image upload)
  - Terms & Conditions (for invoices)
  - Bank Details (for invoice footer)

Given I update any field
When I tap "Save"
Then changes are saved to Firestore
And I see success message "Profile updated"

Given I add a logo
When I upload an image
Then it is resized to max 200x200px
And stored in Firebase Storage
And appears on generated invoices
```

---

## 3. Edge Case Scenarios

### 3.1 Data Integrity Edge Cases

| Scenario | System Behavior | User Notification |
|----------|----------------|-------------------|
| Invoice save fails mid-transaction | Rollback stock changes, keep draft | "Invoice not saved. Please try again." |
| Duplicate invoice number detected | Auto-increment to next available | Silent correction with logging |
| Product deleted after invoice creation | Preserve invoice data, show "Unknown Product" | "Product no longer exists" |
| Firestore quota exceeded | Queue operations locally, retry later | "Sync paused - quota exceeded" |
| Device time incorrect (future date) | Block with error, require correction | "Please check device time" |
| Device time incorrect (past date) | Warn but allow, flag for review | "Date is in the past - please verify" |

### 3.2 Network Edge Cases

| Scenario | System Behavior | User Notification |
|----------|----------------|-------------------|
| Network drops during invoice save | Queue operation, retry when online | "Will sync when online" |
| Network drops during data load | Show cached data | "Offline - showing cached data" |
| Slow network (2G) | Show loading indicator, timeout at 30s | "Loading... slow connection" |
| Network restored after offline work | Auto-sync queued operations | "Sync complete - X items updated" |
| Conflict: local vs server data | Prefer server, backup local | "Local changes backed up" |

### 3.3 Device Edge Cases

| Scenario | System Behavior | User Notification |
|----------|----------------|-------------------|
| Low storage (<100MB) | Warn, suggest data export/cleanup | "Low storage - export old data" |
| Very low storage (<50MB) | Block new invoices, allow viewing only | "Storage critical - free up space" |
| App killed during operation | Recover state on relaunch | "Resumed previous operation" |
| Multiple rapid taps | Debounce, ignore duplicates | None (silent handling) |
| Screen rotation mid-operation | Preserve form state | None (seamless) |
| Battery saver mode active | Reduce sync frequency | "Sync delayed - battery saver on" |

---

## 4. Validation Rules Summary

### 4.1 Product Validation
| Field | Required | Min | Max | Pattern | Error Message |
|-------|----------|-----|-----|---------|---------------|
| Name | Yes | 2 | 100 | Alphanumeric + space | "Name: 2-100 characters" |
| HSN Code | Yes | 4 | 8 | Digits only | "HSN: 4-8 digits" |
| GST Rate | Yes | - | - | [0, 5, 12, 18, 28] | "Select valid GST rate" |
| Price | Yes | 0.01 | 999999.99 | Decimal | "Price: > 0" |
| Stock | Yes | 0 | 999999 | Integer | "Stock: >= 0" |
| UOM | Yes | - | - | Enum | "Select unit" |

### 4.2 Invoice Validation
| Field | Required | Validation Rule |
|-------|----------|-----------------|
| Customer Name | Yes | 2-100 characters |
| Customer Address | Yes | 10-500 characters |
| Line Items | Yes | Min 1 item |
| Product | Per item | Valid product ID, active |
| Quantity | Per item | > 0, <= available stock |
| Rate | Per item | > 0 |

### 4.3 Expense Validation
| Field | Required | Validation Rule |
|-------|----------|-----------------|
| Amount | Yes | > 0, max 9999999.99 |
| Category | Yes | From predefined list or custom |
| Date | Yes | Not in future |
| Description | No | Max 200 characters |

---

**End of Document**
