# SmartERP 2026 - Quick Reference Guide

## 🚀 Quick Start

### Access the Transactions Page
```
Click: Sidebar → Transactions (or navigate to /transactions)
```

### Generate an Invoice
```dart
// In your Sales/Purchase module, add this button:
ElevatedButton(
  onPressed: () {
    showDialog(
      context: context,
      builder: (context) => InvoiceGenerationDialog(
        transactionType: 'sale', // or 'purchase'
        onInvoiceGenerated: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invoice generated!')),
          );
        },
      ),
    );
  },
  child: const Text('Generate Invoice'),
)
```

---

## 🎨 Theme Usage

### Apply Glass Effect
```dart
// Simple glass container
Container(
  decoration: DesignSystem.glassDecoration(
    borderColor: AppColors.borderLight,
  ),
  child: YourWidget(),
)

// Or use helper method
DesignSystem.glassContainer(
  child: YourWidget(),
  blurRadius: 10.0,
  borderRadius: 16.0,
)
```

### Use Color Palette
```dart
Color primary = AppColors.primary;           // #5D5BDB
Color secondary = AppColors.secondary;       // #9B8DD8
Color success = AppColors.success;           // #16A34A
Color background = AppColors.backgroundLight; // #F8F6F3
```

### Use Gradients
```dart
gradient: DesignSystem.primaryGradient,      // Purple → Lavender
gradient: DesignSystem.backgroundGradient,   // Off-white fade
gradient: DesignSystem.accentGradient,       // Teal → Cyan
```

---

## 📊 Transactions Feature

### Watch Transactions
```dart
final transactions = ref.watch(filteredTransactionsProvider);
final stats = ref.watch(transactionStatsProvider);
```

### Filter Transactions
```dart
// Search
ref.read(transactionSearchProvider.notifier).state = 'Acme Corp';

// By type
ref.read(transactionTypeFilterProvider.notifier).state = 'sale';

// By date
ref.read(transactionDateFromProvider.notifier).state = DateTime(2024, 1, 1);
ref.read(transactionDateToProvider.notifier).state = DateTime(2024, 12, 31);

// Reset
ref.refresh(filteredTransactionsProvider);
```

### Access Statistics
```dart
final stats = ref.watch(transactionStatsProvider);
print('Total Sales: ₹${stats.totalSales}');
print('Total Purchases: ₹${stats.totalPurchases}');
print('Net Profit: ₹${stats.netProfit}');
print('Count: ${stats.transactionCount}');
```

---

## 🧾 Invoice Generation

### Create Invoice Programmatically
```dart
final invoice = await ref.read(invoiceServiceProvider).generateInvoice(
  billNo: 'BL001',
  customerVendorName: 'Acme Corp',
  customerVendorAddress: '123 Main St, Mumbai',
  customerVendorGst: '27AABCT1234H1Z0',
  productName: 'Widget A',
  productDescription: 'High quality widget',
  quantity: 100,
  unitPrice: 50,
  gstRate: 18,
  transportCharges: 500,
  transactionType: 'sale',
  paymentMethod: 'cash',
  notes: 'Delivery by Friday',
);
```

### Display Invoice Preview
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => InvoicePreviewScreen(
      invoice: invoice,
    ),
  ),
);
```

### Auto-Calculate Totals
```dart
// Service automatically handles:
double subtotal = quantity * unitPrice;
double gstAmount = invoiceService.calculateGstAmount(subtotal, 18);
double grandTotal = invoiceService.calculateGrandTotal(
  subtotal, 
  gstAmount, 
  transportCharges,
);
```

---

## 📍 Sidebar Navigation

### Available Routes
```dart
'/dashboard'    // Dashboard
'/products'     // Products
'/sales'        // Sales
'/purchases'    // Purchases
'/transactions' // ✨ NEW
'/expenses'     // Expenses
'/payroll'      // Payroll
'/reports'      // Reports
'/settings'     // Settings
```

### Programmatic Navigation
```dart
context.go('/transactions');
context.go('/dashboard');
```

---

## 🎯 Color Palette Reference

| Name | Color | Usage |
|------|-------|-------|
| Primary | #5D5BDB | Buttons, links, active states |
| Secondary | #9B8DD8 | Accents, secondary buttons |
| Success | #16A34A | Positive actions, confirmations |
| Warning | #F59E0B | Warnings, attention |
| Error | #DC2626 | Errors, deletions |
| Info | #06B6D4 | Information, hints |
| Background | #F8F6F3 | Main background |
| Surface | #FFFBFF | Card backgrounds |
| Text Dark | #2D2C3E | Primary text |
| Text Medium | #6B6B6B | Secondary text |
| Text Light | #9B9B9B | Tertiary text |

---

## 🔧 Common Code Snippets

### Summary Statistics Card
```dart
_StatCard(
  title: 'Total Sales',
  value: '₹50,000',
  icon: Icons.trending_up_rounded,
  color: AppColors.success,
)
```

### Filter Button
```dart
ElevatedButton.icon(
  onPressed: () => context.go('/transactions'),
  icon: const Icon(Icons.filter_list_rounded),
  label: const Text('Filters'),
)
```

### Invoice Button
```dart
ElevatedButton.icon(
  onPressed: () {
    showDialog(
      context: context,
      builder: (context) => InvoiceGenerationDialog(
        transactionType: 'sale',
        onInvoiceGenerated: () {},
      ),
    );
  },
  icon: const Icon(Icons.receipt_long_rounded),
  label: const Text('Create Invoice'),
)
```

### Glass Container
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        AppColors.surfaceGlass.withOpacity(0.8),
        AppColors.glassLight.withOpacity(0.5),
      ],
    ),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.borderLight),
    boxShadow: DesignSystem.subtleShadow,
  ),
  padding: const EdgeInsets.all(16),
  child: YourWidget(),
)
```

---

## ✨ UI Components Overview

### Premium Elements
- **Glassmorphism**: Blur + transparency effects
- **Gradients**: Smooth color transitions
- **Shadows**: Subtle depth perception
- **Rounded Corners**: 12px-20px for modern feel
- **Animations**: Smooth 200-500ms transitions

### Responsive Breakpoints
- **Desktop**: Full sidebar + expanded content
- **Tablet**: Sidebar with collapsible options
- **Mobile**: Drawer-based navigation

---

## 🐛 Troubleshooting

### Invoice Form Not Submitting
- Check all required fields are filled
- Verify numeric values > 0
- Ensure customer name is not empty

### Transactions Not Updating
- Check Riverpod provider states
- Verify filter providers are set correctly
- Ensure transactionsProvider is being watched

### Theme Not Applied
- Verify AppTheme is set in main.dart
- Check AppColors are imported correctly
- Ensure Material3 is enabled (useMaterial3: true)

### Glass Effect Not Visible
- Check BackdropFilter is properly wrapped
- Verify ImageFilter.blur sigma values
- Ensure background is visible behind effect

---

## 📊 Data Structure Cheat Sheet

### Transaction Structure
```dart
TransactionEntity {
  id: String?
  date: DateTime
  billNo: String (e.g., 'BL001')
  customerVendorName: String
  productName: String
  quantity: double
  amount: double
  paymentStatus: 'pending'|'completed'|'partial'
  type: 'sale'|'purchase'
  gst: double
  subtotal: double
  grandTotal: double
  transport: TransportEntity?
}
```

### Invoice Structure
```dart
InvoiceEntity {
  invoiceNumber: String (auto-generated)
  invoiceDate: DateTime
  billNo: String
  companyName: String (auto-filled)
  customerVendorName: String
  productName: String
  quantity: double
  unitPrice: double
  subtotal: double
  gstRate: double
  gstAmount: double
  transportCharges: double
  grandTotal: double
  paymentMethod: String
  paymentStatus: String
  notes: String?
}
```

### Statistics Structure
```dart
TransactionStats {
  totalSales: double
  totalPurchases: double
  netProfit: double
  transactionCount: int
}
```

---

## 🎓 Best Practices

### Do's ✅
- Use `const` constructor when possible
- Watch providers for reactive updates
- Use `copyWith()` for immutable updates
- Validate user input before submission
- Handle errors with SnackBars

### Don'ts ❌
- Modify models directly (use copyWith)
- Create providers in build methods
- Ignore error states
- Use `Future.delayed` for UI updates
- Hardcode values (use constants instead)

---

## 📚 Documentation Links

- **Full Guide**: `MODERN_REDESIGN_GUIDE.md`
- **Summary**: `REDESIGN_SUMMARY.md`
- **Code**: Check inline comments in each file

---

## 🎉 You're All Set!

Everything is ready to use. Start building amazing transactions and invoices! 

For detailed information, refer to `MODERN_REDESIGN_GUIDE.md`

**Happy Coding! 🚀**
