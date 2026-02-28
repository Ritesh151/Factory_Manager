# SmartERP System Design (Free Tier Optimized)

## 1. System Overview

SmartERP is a single-user,
client-heavy,
free-tier optimized ERP system.

---

## 2. Design Principles

- Minimal backend usage
- All calculations client-side
- Firestore as storage only
- Free-tier safe architecture

---

## 3. Component Flow

Flutter UI
  ↓
Riverpod State
  ↓
Business Logic (Local)
  ↓
Repository
  ↓
Firestore Storage

---

## 4. Data Flow (Invoice Example)

1. User selects product
2. Product fetched once
3. GST calculated locally
4. Total computed locally
5. Save invoice
6. Batch update:
   - Save invoice
   - Reduce stock

Single write operation.

---

## 5. Database Design

users/{uid}/
    products/
    sales/
    expenses/
    employees/
    purchases/

Simple nested structure.
Low query complexity.

---

## 6. Invoice Lock Strategy

On Save:
- priceAtSale stored
- invoiceLocked = true
- UI prevents editing

No server validation required.

---

## 7. Security Design

Firestore Rules:

allow read, write: if request.auth.uid == userId;

Ensures:
- User sees only own data
- No cross access

---

## 8. Free Tier Optimization

- Avoid heavy real-time listeners
- Avoid deep queries
- Fetch once → filter locally
- Enable offline persistence
- Batch writes

---

## 9. Performance

- Cached product list
- Local filtering
- Local aggregation
- Paginated history
- Minimal Firestore reads

---

## 10. Cost Structure

Firebase Spark Plan:
₹0 cost

No:
- Cloud Functions
- Paid APIs
- Payment gateway
- Third-party services

Project is 100% free.