# SmartERP Architecture (Free Tier + Client Heavy)

## 1. Architecture Goal

- 100% Free Cost
- Single User System
- Maximum Client-Side Logic
- Minimal Backend Usage
- Firebase Spark Plan Only

---

## 2. Technology Stack

Frontend:
- Flutter 3.x
- Dart
- Riverpod
- GoRouter
- Flutter PDF
- Syncfusion Charts (Community License)

Backend (Free Tier Only):
- Firebase Authentication (Email/Password)
- Cloud Firestore (Spark Plan)
- Firebase Storage (Free Tier)
- Firebase Hosting (Optional Web)

No:
- Cloud Functions
- Paid APIs
- Razorpay
- Paid WhatsApp APIs

---

## 3. Updated Architecture Design

Flutter App (Client Side)
    ↓
Riverpod State
    ↓
Local Business Logic (100% Calculation)
    ↓
Repository Layer
    ↓
Firestore (Storage Only)

IMPORTANT:
Firestore is used ONLY for data storage.
All calculations happen inside Flutter.

---

## 4. Client-Side Processing

Handled on Device:

✔ GST Calculation  
✔ Invoice Total Calculation  
✔ Stock Updates  
✔ Profit Calculation  
✔ Dashboard Aggregation  
✔ Date Filtering  
✔ Reports  
✔ CSV Export  
✔ PDF Generation  

Firestore only stores final data.

---

## 5. Database Structure (Optimized for Free Tier)

users/{userId}/products/{productId}
users/{userId}/sales/{saleId}
users/{userId}/expenses/{expenseId}
users/{userId}/employees/{employeeId}
users/{userId}/purchases/{purchaseId}

Why this structure?

- Data isolated per user
- Simple queries
- Lower read cost
- Free tier friendly

---

## 6. Real-Time Strategy (Free Optimized)

Instead of multiple listeners:

- Use single collection listeners
- Cache product list in memory
- Recalculate invoice locally
- Avoid excessive Firestore reads

---

## 7. Invoice Locking (Client Controlled)

When invoice saved:
- priceAtSale stored
- Mark invoiceLocked = true
- UI blocks editing
- No backend validation required

Single user → No concurrency issues

---

## 8. Security Strategy (Free Plan)

Firestore Rules:

- User can only access own path
- Payroll access allowed (single user)
- Invoice editing blocked in UI

Since single user → simple rule structure

---

## 9. Offline Support

Enable Firestore offline persistence.

Benefits:
- Works without internet
- Sync when online
- Reduces reads
- Fully free

---

## 10. Performance Optimization

- Avoid complex queries
- Use indexed fields
- Paginate large sales history
- Avoid unnecessary streams
- Batch write for invoice + stock update

---

## 11. Deployment

Android APK (Manual Install)
OR
Play Store (Optional)

Web:
Firebase Hosting (Free tier)

No server cost involved.