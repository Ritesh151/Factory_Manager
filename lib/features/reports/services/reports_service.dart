import 'package:flutter/foundation.dart';

import '../../../core/services/firebase_service.dart';
import '../../expense/services/expense_service.dart';
import '../../payroll/services/payroll_service.dart';
import '../../purchase/services/purchase_service.dart';
import '../../sales/services/sales_service.dart';

/// Service for generating business reports and analytics
class ReportsService {
  static final ReportsService _instance = ReportsService._internal();
  
  factory ReportsService() => _instance;
  ReportsService._internal();

  late final SalesService _salesService;
  late final PurchaseService _purchaseService;
  late final ExpenseService _expenseService;
  late final PayrollService _payrollService;

  /// Initialize with FirebaseService
  void initialize(FirebaseService firebaseService) {
    _salesService = SalesService();
    _salesService.initialize(firebaseService);
    _purchaseService = PurchaseService();
    _purchaseService.initialize(firebaseService);
    _expenseService = ExpenseService();
    _expenseService.initialize(firebaseService);
    _payrollService = PayrollService();
    _payrollService.initialize(firebaseService);
  }

  /// Get comprehensive dashboard summary
  Future<DashboardSummary> getDashboardSummary() async {
    try {
      final now = DateTime.now();
      
      // Get current month data
      final sales = await _salesService.getMonthlySalesTotal(now.year, now.month);
      final purchases = await _purchaseService.getMonthlyPurchaseTotal(now.year, now.month);
      final expenses = await _expenseService.getMonthlyExpenseTotal(now.year, now.month);
      final payroll = await _payrollService.getMonthlyPayrollTotal(now.year, now.month);

      // Calculate net profit
      final netProfit = sales - purchases - expenses - payroll;

      // Get GST collected (from sales)
      final gstCollected = await _getMonthlyGstCollected(now.year, now.month);

      return DashboardSummary(
        totalSales: sales,
        totalPurchases: purchases,
        totalExpenses: expenses,
        totalPayroll: payroll,
        netProfit: netProfit,
        gstCollected: gstCollected,
      );
    } catch (e) {
      debugPrint('ReportsService: Error getting dashboard summary: $e');
      return DashboardSummary.zero();
    }
  }

  /// Get GST collected for a month
  Future<double> _getMonthlyGstCollected(int year, int month) async {
    try {
      final start = DateTime(year, month, 1);
      final end = DateTime(year, month + 1, 0, 23, 59, 59);

      final sales = await _salesService.getSalesByDateRange(start, end);
      
      double totalGst = 0.0;
      for (final sale in sales) {
        totalGst += sale.totalCgst + sale.totalSgst;
      }

      return totalGst;
    } catch (e) {
      debugPrint('ReportsService: Error getting GST collected: $e');
      return 0.0;
    }
  }

  /// Get yearly data for charts
  Future<List<MonthlyData>> getYearlyData(int year) async {
    try {
      final List<MonthlyData> data = [];

      for (int month = 1; month <= 12; month++) {
        final sales = await _salesService.getMonthlySalesTotal(year, month);
        final purchases = await _purchaseService.getMonthlyPurchaseTotal(year, month);
        final expenses = await _expenseService.getMonthlyExpenseTotal(year, month);
        final payroll = await _payrollService.getMonthlyPayrollTotal(year, month);

        data.add(MonthlyData(
          month: month,
          monthName: _getMonthName(month),
          sales: sales,
          purchases: purchases,
          expenses: expenses,
          payroll: payroll,
          profit: sales - purchases - expenses - payroll,
        ));
      }

      return data;
    } catch (e) {
      debugPrint('ReportsService: Error getting yearly data: $e');
      return [];
    }
  }

  /// Get expense breakdown by category for current month
  Future<Map<String, double>> getExpenseBreakdown() async {
    try {
      final now = DateTime.now();
      return await _expenseService.getExpensesByCategoryForMonth(now.year, now.month);
    } catch (e) {
      debugPrint('ReportsService: Error getting expense breakdown: $e');
      return {};
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

/// Dashboard summary data
class DashboardSummary {
  final double totalSales;
  final double totalPurchases;
  final double totalExpenses;
  final double totalPayroll;
  final double netProfit;
  final double gstCollected;

  DashboardSummary({
    required this.totalSales,
    required this.totalPurchases,
    required this.totalExpenses,
    required this.totalPayroll,
    required this.netProfit,
    required this.gstCollected,
  });

  factory DashboardSummary.zero() {
    return DashboardSummary(
      totalSales: 0,
      totalPurchases: 0,
      totalExpenses: 0,
      totalPayroll: 0,
      netProfit: 0,
      gstCollected: 0,
    );
  }
}

/// Monthly data for charts
class MonthlyData {
  final int month;
  final String monthName;
  final double sales;
  final double purchases;
  final double expenses;
  final double payroll;
  final double profit;

  MonthlyData({
    required this.month,
    required this.monthName,
    required this.sales,
    required this.purchases,
    required this.expenses,
    required this.payroll,
    required this.profit,
  });
}
