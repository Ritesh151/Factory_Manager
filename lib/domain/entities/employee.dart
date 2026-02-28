import 'package:equatable/equatable.dart';

class Employee extends Equatable {
  const Employee({
    required this.id,
    required this.fullName,
    required this.designation,
    required this.joiningDate,
    required this.monthlySalary,
    this.employeeCode,
    this.department,
    this.phone,
    this.email,
    this.address,
    this.bankDetails,
    this.status = 'ACTIVE',
    this.isActive = true,
    this.resignationDate,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String fullName;
  final String designation;
  final DateTime joiningDate;
  final double monthlySalary;
  final String? employeeCode;
  final String? department;
  final String? phone;
  final String? email;
  final String? address;
  final Map<String, String>? bankDetails;
  final String status;
  final bool isActive;
  final DateTime? resignationDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props =>
      [id, fullName, designation, joiningDate, monthlySalary, status];
}
