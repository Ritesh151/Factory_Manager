import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.userId,
    required this.email,
    required this.businessName,
    this.businessType,
    this.gstin,
    this.phone,
    this.address,
    this.bankDetails,
    this.invoiceConfig,
    required this.createdAt,
    required this.updatedAt,
  });

  final String userId;
  final String email;
  final String businessName;
  final String? businessType;
  final String? gstin;
  final String? phone;
  final Map<String, String>? address;
  final Map<String, String>? bankDetails;
  final Map<String, String>? invoiceConfig;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props =>
      [userId, email, businessName, createdAt];
}
