/// Transport details entity for sales and purchase transactions
class TransportEntity {
  final String? id;
  final String transactionId; // Links to Sale or Purchase
  final String city;
  final String transportCompanyName;
  final String vehicleNumber;
  final double transportCharges;
  final String deliveryStatus; // 'pending', 'dispatched', 'delivered'
  final DateTime dispatchDate;
  final DateTime? deliveryDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransportEntity({
    this.id,
    required this.transactionId,
    required this.city,
    required this.transportCompanyName,
    required this.vehicleNumber,
    required this.transportCharges,
    required this.deliveryStatus,
    required this.dispatchDate,
    this.deliveryDate,
    required this.createdAt,
    required this.updatedAt,
  });

  TransportEntity copyWith({
    String? id,
    String? transactionId,
    String? city,
    String? transportCompanyName,
    String? vehicleNumber,
    double? transportCharges,
    String? deliveryStatus,
    DateTime? dispatchDate,
    DateTime? deliveryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransportEntity(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      city: city ?? this.city,
      transportCompanyName: transportCompanyName ?? this.transportCompanyName,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      transportCharges: transportCharges ?? this.transportCharges,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      dispatchDate: dispatchDate ?? this.dispatchDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
