import '../entities/report_entity.dart';

/// Abstract repository for report generation
abstract class ReportRepository {
  /// Generate sales report for date range
  Future<ReportEntity> generateSalesReport({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Generate expense report
  Future<ReportEntity> generateExpenseReport({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Generate revenue report (total sales - expenses)
  Future<ReportEntity> generateRevenueReport({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Generate inventory report
  Future<ReportEntity> generateInventoryReport();

  /// Get all generated reports
  Stream<List<ReportEntity>> getAllReportsStream();

  /// Export report as PDF
  Future<String> exportReportAsPdf(ReportEntity report);

  /// Export report as CSV
  Future<String> exportReportAsCsv(ReportEntity report);

  /// Get dashboard summary (quick metrics)
  Future<Map<String, dynamic>> getDashboardSummary({
    required DateTime startDate,
    required DateTime endDate,
  });
}
