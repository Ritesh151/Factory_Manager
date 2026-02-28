import '../entities/salary_payment.dart';

abstract class SalaryPaymentRepository {
  Stream<List<SalaryPayment>> watchByEmployee(
    String userId,
    String employeeId,
  );
  Future<List<SalaryPayment>> getByEmployee(
    String userId,
    String employeeId, {
    int limit = 24,
  });
  Future<SalaryPayment?> getById(String userId, String paymentId);
  Future<SalaryPayment> create(String userId, SalaryPayment payment);
  Future<bool> isSalaryPaid(
    String userId,
    String employeeId,
    int month,
    int year,
  );
  Future<double> getMonthlyTotal(String userId, DateTime month);
  Future<List<SalaryPayment>> getByMonth(
    String userId,
    int month,
    int year,
  );
}
