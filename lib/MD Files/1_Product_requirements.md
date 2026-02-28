# SmartERP Product Requirements Document

**Version:** 1.0  
**Date:** February 2026  
**Status:** Production  
**Classification:** Internal

---

## 1. Executive Summary

### 1.1 Product Vision
SmartERP is a zero-cost, cloud-based, single-user factory ERP system designed specifically for small manufacturers and factory owners. The system provides comprehensive business management capabilities including inventory tracking, GST-compliant invoicing, expense management, payroll processing, and financial analytics — all while maintaining zero operational costs through strategic use of Firebase Spark Plan and client-side processing architecture.

### 1.2 Value Proposition
| Aspect | Traditional ERP | SmartERP |
|--------|----------------|------------|
| Cost | ₹15,000 - ₹50,000/year | ₹0 |
| Setup Time | 2-4 weeks | Same day |
| Infrastructure | Server maintenance required | Zero maintenance |
| Accessibility | Desktop-bound | Mobile-first |
| Data Control | Vendor-dependent | User-controlled |

### 1.3 Success Criteria
| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| Invoice Generation Speed | < 2 seconds | Stopwatch timing |
| Stock Accuracy | 99.9% | Audit reconciliation |
| Data Integrity | Zero corruption | Automated validation |
| Firebase Usage | < 50% free tier | Firebase console |
| Offline Capability | 100% core features | Feature matrix testing |

---

## 2. Functional Requirements

### 2.1 Product Management Module

#### 2.1.1 Product Lifecycle Management
| ID | Requirement | Priority | Acceptance Criteria |
|----|-------------|----------|---------------------|
| PROD-001 | Create new product | P0 | Product saved with all mandatory fields |
| PROD-002 | Edit existing product | P0 | Changes persisted with history tracking |
| PROD-003 | Delete product (soft) | P1 | Product marked inactive, references preserved |
| PROD-004 | View product details | P0 | All product information accessible |

#### 2.1.2 Product Attributes
| Attribute | Type | Required | Constraints |
|-----------|------|----------|-------------|
| Product ID | String | Auto-generated | Unique, non-editable |
| Product Name | String | Yes | 2-100 characters |
| HSN Code | String | Yes | Valid 4-8 digit format |
| GST Rate | Decimal | Yes | 0%, 5%, 12%, 18%, 28% |
| Base Price | Decimal | Yes | > 0, 2 decimal precision |
| Current Stock | Integer | Yes | >= 0 |
| Unit of Measurement | String | Yes | PCS, KG, LTR, MTR, BOX |
| Description | String | No | Max 500 characters |
| Created At | Timestamp | Auto | ISO 8601 format |
| Updated At | Timestamp | Auto | ISO 8601 format |
| Is Active | Boolean | Auto | Default true |

### 2.2 Invoice System Module

#### 2.2.1 Invoice Generation
| ID | Requirement | Priority | Business Logic |
|----|-------------|----------|----------------|
| INV-001 | Create sales invoice | P0 | Auto-calculate GST, generate PDF |
| INV-002 | Auto invoice numbering | P0 | Format: INV-YYYY-XXXXX (sequential) |
| INV-003 | GST calculation | P0 | Formula: (Price × GST%) / 100 |
| INV-004 | Invoice immutability | P0 | Post-save: locked, no modifications |
| INV-005 | PDF generation | P0 | Offline capable, GST-compliant format |

#### 2.2.2 Invoice Structure
| Field | Type | Calculation Method |
|-------|------|-------------------|
| Invoice Number | String | Auto-increment per fiscal year |
| Invoice Date | Date | User selected, default today |
| Customer Name | String | Free text, required |
| Customer GSTIN | String | Optional, validated format |
| Customer Address | String | Required, multi-line |
| Line Items | Array | Product reference, quantity, rate |
| Subtotal | Decimal | Sum of (quantity × rate) |
| CGST | Decimal | Subtotal × (GST%/2) / 100 |
| SGST | Decimal | Subtotal × (GST%/2) / 100 |
| IGST | Decimal | Subtotal × GST% / 100 (inter-state) |
| Total Amount | Decimal | Subtotal + Tax |
| Amount in Words | String | Auto-generated |

### 2.3 Inventory Management Module

#### 2.3.1 Stock Operations
| ID | Requirement | Trigger | Impact |
|----|-------------|---------|--------|
| STOCK-001 | Automatic stock reduction | Invoice creation | stock = stock - quantity |
| STOCK-002 | Automatic stock increase | Purchase entry | stock = stock + quantity |
| STOCK-003 | Manual stock adjustment | User action | With reason logging |
| STOCK-004 | Low stock alert | Stock <= threshold | Visual indicator, list filter |

#### 2.3.2 Stock Validation Rules
| Rule | Validation | Error Action |
|------|------------|------------|
| Negative Stock Prevention | quantity <= available stock | Block invoice, show error |
| Zero Stock Block | stock > 0 for sale | Disable product selection |
| Decimal Precision | 0 decimals for PCS, 2 for others | Input formatting |

### 2.4 Expense Management Module

#### 2.4.1 Expense Tracking
| ID | Requirement | Category Support |
|----|-------------|-----------------|
| EXP-001 | Record expense | Salary, Rent, Utilities, Raw Material, Transport, Other |
| EXP-002 | Date filtering | Preset: Today, Week, Month, Custom range |
| EXP-003 | Monthly summary | Aggregated by category |
| EXP-004 | Expense editing | Allowed within 24 hours, then locked |

#### 2.4.2 Expense Categories
| Category | Sub-categories | Default VAT Applicability |
|----------|---------------|--------------------------|
| Salary | Employee wages | No |
| Rent | Factory, Office, Godown | No |
| Utilities | Electricity, Water, Internet | Yes (18%) |
| Raw Material | Purchase | Yes (as per HSN) |
| Transport | Logistics, Delivery | Yes (12%) |
| Maintenance | Repairs, Service | Yes (18%) |
| Other | Miscellaneous | User defined |

### 2.5 Payroll Management Module

#### 2.5.1 Employee Management
| ID | Requirement | Data Captured |
|----|-------------|---------------|
| PAY-001 | Add employee | Name, Designation, Joining Date, Monthly Salary |
| PAY-002 | Mark salary paid | Month, Amount, Payment Date, Mode |
| PAY-003 | Salary history | Per employee, chronological |
| PAY-004 | Employee status | Active, On Leave, Resigned |

#### 2.5.2 Payroll Attributes
| Attribute | Type | Validation |
|-----------|------|------------|
| Employee ID | String | Auto-generated |
| Full Name | String | 3-50 characters |
| Designation | String | Required |
| Monthly Salary | Decimal | > 0 |
| Joining Date | Date | Not future date |
| Bank Details | String | Optional, encrypted |

### 2.6 Dashboard & Analytics Module

#### 2.6.1 Financial Dashboard
| Widget | Calculation | Refresh Rate |
|--------|-------------|--------------|
| Total Sales | Sum of all invoices (current month) | Real-time |
| Total Purchases | Sum of all purchases (current month) | Real-time |
| Total Expenses | Sum of all expenses (current month) | Real-time |
| Salary Payout | Sum of salaries paid (current month) | Real-time |
| Net Profit | Sales - Purchases - Expenses - Salary | Real-time |
| GST Payable | Output GST - Input GST | Monthly |

#### 2.6.2 GST Summary
| Component | Source | Display Format |
|-----------|--------|----------------|
| Output CGST | Sales invoices CGST | Separate row |
| Output SGST | Sales invoices SGST | Separate row |
| Output IGST | Sales invoices IGST | Separate row |
| Input CGST | Purchase CGST | Separate row |
| Input SGST | Purchase SGST | Separate row |
| Input IGST | Purchase IGST | Separate row |
| Net Payable | Output - Input | Color-coded (red/green) |

### 2.7 Reporting Module

#### 2.7.1 Available Reports
| Report ID | Name | Filters | Export Format |
|-----------|------|---------|---------------|
| RPT-001 | Sales Register | Date range, Product, Customer | PDF, CSV |
| RPT-002 | Purchase Register | Date range, Product, Vendor | PDF, CSV |
| RPT-003 | Expense Statement | Date range, Category | PDF, CSV |
| RPT-004 | GST Return Summary | Month, Quarter | PDF |
| RPT-005 | Stock Statement | As of date | PDF, CSV |
| RPT-006 | Profit & Loss | Fiscal year | PDF |

---

## 3. Non-Functional Requirements

### 3.1 Performance Requirements
| Metric | Requirement | Test Condition |
|--------|-------------|----------------|
| App Launch Time | < 3 seconds | Cold start, 1000 products |
| Invoice Generation | < 2 seconds | 10 line items, PDF included |
| Dashboard Load | < 1 second | 12 months data cached |
| Search Response | < 500ms | Product search, 1000 records |
| PDF Generation | < 3 seconds | Full invoice with logo |

### 3.2 Availability Requirements
| Scenario | Requirement | Implementation |
|----------|-------------|--------------|
| Online Mode | 100% functionality | Full Firestore access |
| Offline Mode | Core functionality | Local persistence, queue |
| Sync Recovery | Automatic | Background sync when online |
| Graceful Degradation | Error states handled | User-friendly messages |

### 3.3 Security Requirements
| Requirement | Implementation | Verification |
|-------------|----------------|------------|
| Authentication | Firebase Auth (Email/Password) | Secure token handling |
| Data Encryption | TLS 1.3 in transit | Certificate pinning |
| Local Data | Encrypted SharedPreferences | Android Keystore |
| Backup | Firebase managed | Automatic daily |
| Session Timeout | 30 minutes idle | Auto-logout, data clear |

### 3.4 Scalability Requirements
| Aspect | Current | Future-Proof |
|--------|---------|--------------|
| Products | 1,000 | 10,000 |
| Monthly Invoices | 500 | 5,000 |
| Historical Data | 2 years | 5 years |
| Concurrent Operations | N/A (single user) | N/A |
| Storage | < 500MB | < 1GB (free tier limit) |

### 3.5 Usability Requirements
| Criterion | Requirement |
|-----------|-------------|
| Platform | Android 7.0+ (API 24), iOS 13+ |
| Screen Sizes | 4" - 12" responsive |
| Navigation | Maximum 3 taps to any feature |
| Onboarding | < 5 minutes to first invoice |
| Accessibility | WCAG 2.1 Level AA compliance |
| Language | English (MVP), Hindi (Phase 2) |

---

## 4. Business Constraints

### 4.1 Technical Constraints
| Constraint | Impact | Mitigation |
|------------|--------|------------|
| Single User Only | No multi-device sync | Cloud Firestore real-time |
| Firebase Spark Plan | 50K reads/day limit | Aggressive local caching |
| No Cloud Functions | Business logic in client | Optimized Flutter code |
| No Backend API | Limited complex operations | Offline-first architecture |

### 4.2 Operational Constraints
| Constraint | Description |
|------------|-------------|
| Invoice Locking | Post-save invoices immutable |
| Stock Accuracy | Manual adjustments only via dedicated flow |
| GST Compliance | Fixed GST rates per government notification |
| Fiscal Year | April - March (India standard) |

### 4.3 Compliance Requirements
| Regulation | Compliance Level | Implementation |
|------------|-----------------|---------------|
| GST Act 2017 | Full | HSN codes, GST rates, invoice format |
| Data Privacy | Basic | Local data, no third-party sharing |
| Backup Retention | 5 years | Firebase retention, local export |

---

## 5. Assumptions

| ID | Assumption | Risk Level | Mitigation |
|----|------------|------------|------------|
| A-001 | Single user per device | Low | Auth binding |
| A-002 | User has basic smartphone literacy | Medium | In-app tutorials |
| A-003 | Internet available at least once daily | Medium | Offline queue |
| A-004 | Firebase Spark Plan remains free | Low | Migration plan ready |
| A-005 | User maintains device security | Medium | App-level encryption |
| A-006 | GST rates remain stable | Low | Admin update capability |

---

## 6. Risks and Mitigation

### 6.1 Technical Risks
| Risk | Probability | Impact | Mitigation Strategy |
|------|-------------|--------|---------------------|
| Firebase quota exhaustion | Medium | High | Usage monitoring, alerts |
| Large dataset performance | Medium | Medium | Pagination, lazy loading |
| PDF generation failure | Low | High | Fallback to share as text |
| Data corruption on sync | Low | High | Transaction-based writes |
| Device loss | Medium | High | Cloud backup, encrypted local |

### 6.2 Business Risks
| Risk | Probability | Impact | Mitigation Strategy |
|------|-------------|--------|---------------------|
| User expects multi-user | Medium | Medium | Clear documentation |
| Feature scope creep | High | High | Strict MVP adherence |
| Compliance changes | Medium | High | Modular GST handling |
| Free tier discontinuation | Low | Critical | Paid plan migration path |

### 6.3 Risk Register
| ID | Risk | Owner | Status | Review Date |
|----|------|-------|--------|-------------|
| R-001 | Firebase limits exceeded | Tech Lead | Monitoring | Weekly |
| R-002 | Offline sync conflicts | Architect | Mitigated | Monthly |
| R-003 | GST rate changes | Product | Tracking | Quarterly |

---

## 7. Out of Scope

### 7.1 Explicitly Excluded Features
| Feature | Reason | Future Consideration |
|---------|--------|---------------------|
| Multi-user support | Architecture constraint | Version 2.0 (paid tier) |
| Real-time collaboration | Single-user design | Not applicable |
| Payment gateway integration | Cost constraint | Manual entry sufficient |
| WhatsApp API integration | Paid API cost | Future premium feature |
| Cloud Functions | Free tier constraint | N/A |
| Subscription management | No revenue model | N/A |
| Multi-currency support | Indian market focus | Export module |
| Purchase order workflow | Complexity | V2 consideration |
| Barcode/QR scanning | Hardware dependency | Mobile camera feature |
| Biometric authentication | Device dependency | Security enhancement |

### 7.2 Phase 2 Candidates (Post-MVP)
| Feature | Business Value | Technical Complexity |
|---------|---------------|---------------------|
| Multi-device sync | High | Medium |
| Bank integration | Medium | High |
| Advanced analytics | Medium | Low |
| Customer portal | Medium | High |
| Inventory forecasting | High | Medium |

---

## 8. Future Scope

### 8.1 Version 2.0 Roadmap (Tentative)
| Phase | Timeline | Key Features |
|-------|----------|--------------|
| 2.0-Alpha | Q3 2026 | Multi-device support, Firebase Blaze |
| 2.0-Beta | Q4 2026 | Role-based access, 3 users max |
| 2.0-GA | Q1 2027 | Production multi-user release |

### 8.2 Enhancement Pipeline
| Priority | Feature | Estimated Effort |
|----------|---------|------------------|
| P1 | Backup/Restore to local storage | 2 weeks |
| P1 | Custom invoice template | 3 weeks |
| P2 | Supplier management module | 4 weeks |
| P2 | Purchase order tracking | 3 weeks |
| P3 | Mobile printer support | 2 weeks |
| P3 | GST e-filing export | 1 week |

---

## 9. Document Control

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 0.1 | 2026-01-15 | Product Team | Initial draft |
| 0.2 | 2026-01-28 | Tech Lead | Technical review |
| 0.3 | 2026-02-10 | QA Lead | Test scenarios added |
| 1.0 | 2026-02-28 | Product Team | Production release |

### 9.1 Approval
| Role | Name | Date | Signature |
|------|------|------|-----------|
| Product Owner | TBD | | |
| Tech Lead | TBD | | |
| QA Lead | TBD | | |

---

**End of Document**
