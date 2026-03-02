import 'package:equatable/equatable.dart';

/// Payroll entity representing employee salary information
class PayrollEntity extends Equatable {
  final String id;
  final String employeeId;
  final String employeeName;
  final double baseSalary;
  final double allowances;
  final double deductions;
  final double netSalary;
  final String month; // Format: YYYY-MM
  final String status; // pending, approved, paid
  final DateTime createdAt;
  final DateTime updatedAt;

  const PayrollEntity({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.baseSalary,
    required this.allowances,
    required this.deductions,
    required this.netSalary,
    required this.month,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  PayrollEntity copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    double? baseSalary,
    double? allowances,
    double? deductions,
    double? netSalary,
    String? month,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PayrollEntity(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      baseSalary: baseSalary ?? this.baseSalary,
      allowances: allowances ?? this.allowances,
      deductions: deductions ?? this.deductions,
      netSalary: netSalary ?? this.netSalary,
      month: month ?? this.month,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        employeeId,
        employeeName,
        baseSalary,
        allowances,
        deductions,
        netSalary,
        month,
        status,
        createdAt,
        updatedAt,
      ];
}
