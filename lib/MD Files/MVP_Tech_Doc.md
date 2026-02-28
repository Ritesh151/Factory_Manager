# SmartERP MVP Technical Doc (100% Free)

## 1. MVP Goal

Deliver a fully functional ERP system:

- Single User
- 100% Free
- Client-heavy logic
- Firebase Free Tier

---

## 2. Free Tier Limits Consideration

Firestore Free:
- 50K reads/day
- 20K writes/day
- 1GB storage

App designed to stay well below limits.

---

## 3. Modules Included

✔ Product Management  
✔ GST Billing  
✔ Inventory  
✔ Expense Tracking  
✔ Payroll  
✔ Dashboard  
✔ Reports  
✔ PDF Invoice  

Excluded:
✖ Multi-user  
✖ Subscription  
✖ Payment Gateway  
✖ WhatsApp API  

---

## 4. Invoice Logic (Client Side)

GST Formula:

GST Amount = (Price × GST%) / 100  
Final Price = Price + GST  

All calculations done in Flutter.

Firestore only stores final invoice snapshot.

---

## 5. Stock Logic

On Sale:
stock = stock - quantity

On Purchase:
stock = stock + quantity

Processed locally → then updated in Firestore.

---

## 6. Dashboard Logic

All totals computed in Flutter:

Net Profit = Sales - Purchases - Expenses - Salary

No backend aggregation queries used.

---

## 7. Expense Filtering

Filtering done locally after fetching data once.

Avoid multiple Firestore where queries.

---

## 8. PDF Generation

Generated fully offline using Flutter PDF library.

No API cost.

---

## 9. Testing Strategy

Unit Test:
- GST
- Profit calculation
- Stock logic

Edge Case:
- Zero stock
- Negative value block
- Duplicate invoice prevention

---

## 10. Deployment Strategy

No paid infrastructure required.

App works fully on Firebase Spark plan.