import '../entities/payroll_entity.dart';

/// Abstract repository for payroll operations
abstract class PayrollRepository {
  /// Get a stream of all payroll records
  Stream<List<PayrollEntity>> getAllPayrollsStream();

  /// Get payroll records for a specific month
  Future<List<PayrollEntity>> getPayrollByMonth(String month);

  /// Create a new payroll record
  Future<PayrollEntity> createPayroll(PayrollEntity payroll);

  /// Update a payroll record
  Future<PayrollEntity> updatePayroll(PayrollEntity payroll);

  /// Delete a payroll record
  Future<void> deletePayroll(String payrollId);

  /// Update payroll status (pending → approved → paid)
  Future<void> updatePayrollStatus(String payrollId, String status);

  /// Get payroll for a specific employee and month
  Future<PayrollEntity?> getEmployeePayroll({
    required String employeeId,
    required String month,
  });

  /// Calculate monthly payroll totals
  Future<Map<String, double>> calculateMonthlyTotals(String month);

  /// Export payroll as report
  Future<String> exportPayrollReport({
    required String month,
    required String format, // pdf or csv
  });
}
