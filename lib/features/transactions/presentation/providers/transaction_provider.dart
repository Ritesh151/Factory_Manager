import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../data/models/transaction_model.dart';

// Mock data for demo - replace with Firestore in production
final List<TransactionEntity> _mockTransactions = [
  TransactionModel(
    id: '1',
    date: DateTime.now().subtract(const Duration(days: 5)),
    billNo: 'BL001',
    customerVendorName: 'Acme Corp',
    productName: 'Product A',
    quantity: 100,
    amount: 5000,
    paymentStatus: 'completed',
    type: 'sale',
    gst: 900,
    subtotal: 5000,
    grandTotal: 5900,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  TransactionModel(
    id: '2',
    date: DateTime.now().subtract(const Duration(days: 3)),
    billNo: 'BL002',
    customerVendorName: 'Tech Inc',
    productName: 'Product B',
    quantity: 50,
    amount: 2500,
    paymentStatus: 'pending',
    type: 'purchase',
    gst: 450,
    subtotal: 2500,
    grandTotal: 2950,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  TransactionModel(
    id: '3',
    date: DateTime.now().subtract(const Duration(days: 1)),
    billNo: 'BL003',
    customerVendorName: 'Global Traders',
    productName: 'Product C',
    quantity: 75,
    amount: 3750,
    paymentStatus: 'completed',
    type: 'sale',
    gst: 675,
    subtotal: 3750,
    grandTotal: 4425,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
];

/// Transactions list provider
final transactionsProvider = StateNotifierProvider<TransactionsNotifier, List<TransactionEntity>>(
  (ref) => TransactionsNotifier(),
);

class TransactionsNotifier extends StateNotifier<List<TransactionEntity>> {
  TransactionsNotifier() : super(_mockTransactions);

  void addTransaction(TransactionEntity transaction) {
    state = [...state, transaction];
  }

  void updateTransaction(TransactionEntity transaction) {
    state = [
      for (final t in state)
        if (t.id == transaction.id) transaction else t,
    ];
  }

  void deleteTransaction(String id) {
    state = state.where((t) => t.id != id).toList();
  }
}

/// Filtered transactions provider
final transactionSearchProvider = StateProvider<String>((ref) => '');
final transactionTypeFilterProvider = StateProvider<String?>((ref) => null);
final transactionDateFromProvider = StateProvider<DateTime?>((ref) => null);
final transactionDateToProvider = StateProvider<DateTime?>((ref) => null);

final filteredTransactionsProvider = Provider<List<TransactionEntity>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final search = ref.watch(transactionSearchProvider);
  final typeFilter = ref.watch(transactionTypeFilterProvider);
  final dateFrom = ref.watch(transactionDateFromProvider);
  final dateTo = ref.watch(transactionDateToProvider);

  return transactions.where((transaction) {
    // Search filter
    if (search.isNotEmpty) {
      final searchLower = search.toLowerCase();
      if (!transaction.billNo.toLowerCase().contains(searchLower) &&
          !transaction.customerVendorName.toLowerCase().contains(searchLower) &&
          !transaction.productName.toLowerCase().contains(searchLower)) {
        return false;
      }
    }

    // Type filter
    if (typeFilter != null && transaction.type != typeFilter) {
      return false;
    }

    // Date range filter
    if (dateFrom != null && transaction.date.isBefore(dateFrom)) {
      return false;
    }
    if (dateTo != null && transaction.date.isAfter(dateTo)) {
      return false;
    }

    return true;
  }).toList();
});

/// Summary statistics provider
final transactionStatsProvider = Provider<TransactionStats>((ref) {
  final transactions = ref.watch(filteredTransactionsProvider);

  double totalSales = 0;
  double totalPurchases = 0;

  for (final t in transactions) {
    if (t.type == 'sale') {
      totalSales += t.grandTotal;
    } else {
      totalPurchases += t.grandTotal;
    }
  }

  return TransactionStats(
    totalSales: totalSales,
    totalPurchases: totalPurchases,
    netProfit: totalSales - totalPurchases,
   transactionCount: transactions.length,
  );
});

class TransactionStats {
  final double totalSales;
  final double totalPurchases;
  final double netProfit;
  final int transactionCount;

  TransactionStats({
    required this.totalSales,
    required this.totalPurchases,
    required this.netProfit,
    required this.transactionCount,
  });
}
