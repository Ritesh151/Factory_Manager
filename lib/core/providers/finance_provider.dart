import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/invoice/providers/gst_invoice_provider.dart';

class FinanceState {
  final double totalSales;
  final double totalPurchases;
  final double totalExpenses;
  final double totalSalaryPaid;

  FinanceState({
    this.totalSales = 0,
    this.totalPurchases = 0,
    this.totalExpenses = 0,
    this.totalSalaryPaid = 0,
  });

  double get totalProfit => totalSales - totalPurchases - totalExpenses - totalSalaryPaid;

  FinanceState copyWith({
    double? totalSales,
    double? totalPurchases,
    double? totalExpenses,
    double? totalSalaryPaid,
  }) {
    return FinanceState(
      totalSales: totalSales ?? this.totalSales,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      totalSalaryPaid: totalSalaryPaid ?? this.totalSalaryPaid,
    );
  }
}

class FinanceNotifier extends StateNotifier<FinanceState> {
  final Ref ref;

  FinanceNotifier(this.ref) : super(FinanceState()) {
    _initListeners();
  }

  void _initListeners() {
    ref.listen(allInvoicesProvider, (previous, next) {
      if (next.hasValue) {
        final total = next.value!.fold(0.0, (sum, inv) => sum + inv.grandTotal);
        state = state.copyWith(totalSales: total);
      }
    });
  }

  void updateTotals({
    double? sales,
    double? purchases,
    double? expenses,
    double? salary,
  }) {
    state = state.copyWith(
      totalSales: sales,
      totalPurchases: purchases,
      totalExpenses: expenses,
      totalSalaryPaid: salary,
    );
  }
}

final financeProvider = StateNotifierProvider<FinanceNotifier, FinanceState>((ref) {
  return FinanceNotifier(ref);
});
