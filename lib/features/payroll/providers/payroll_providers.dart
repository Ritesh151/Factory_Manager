import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/employee_model.dart';
import '../services/payroll_service.dart';
import '../../../core/providers/firebase_provider.dart';

/// Payroll service provider
final payrollServiceProvider = Provider((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  final service = PayrollService();
  service.initialize(firebaseService);
  return service;
});

/// Stream all employees
final employeesStreamProvider = StreamProvider((ref) {
  return ref.watch(payrollServiceProvider).streamEmployees();
});

/// Cached employees
final employeesCacheProvider = FutureProvider((ref) async {
  final service = ref.watch(payrollServiceProvider);
  try {
    final stream = service.streamEmployees();
    return await stream.first;
  } catch (e) {
    throw Exception('Failed to fetch employees: $e');
  }
});

/// Monthly payroll total
final monthlyPayrollTotalProvider = FutureProvider.family<double, (int, int)>((ref, params) async {
  final service = ref.watch(payrollServiceProvider);
  final (year, month) = params;
  try {
    return await service.getMonthlyPayrollTotal(year, month);
  } catch (e) {
    throw Exception('Failed to fetch monthly payroll: $e');
  }
});
