import '../../domain/entities/transport_entity.dart';

/// Transport data model with JSON serialization
class TransportModel extends TransportEntity {
  TransportModel({
    super.id,
    required super.transactionId,
    required super.city,
    required super.transportCompanyName,
    required super.vehicleNumber,
    required super.transportCharges,
    required super.deliveryStatus,
    required super.dispatchDate,
    super.deliveryDate,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TransportModel.fromJson(Map<String, dynamic> json) {
    return TransportModel(
      id: json['id'],
      transactionId: json['transactionId'],
      city: json['city'],
      transportCompanyName: json['transportCompanyName'],
      vehicleNumber: json['vehicleNumber'],
      transportCharges: (json['transportCharges'] as num).toDouble(),
      deliveryStatus: json['deliveryStatus'],
      dispatchDate: DateTime.parse(json['dispatchDate']),
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  factory TransportModel.fromEntity(TransportEntity entity) {
    return TransportModel(
      id: entity.id,
      transactionId: entity.transactionId,
      city: entity.city,
      transportCompanyName: entity.transportCompanyName,
      vehicleNumber: entity.vehicleNumber,
      transportCharges: entity.transportCharges,
      deliveryStatus: entity.deliveryStatus,
      dispatchDate: entity.dispatchDate,
      deliveryDate: entity.deliveryDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transactionId': transactionId,
      'city': city,
      'transportCompanyName': transportCompanyName,
      'vehicleNumber': vehicleNumber,
      'transportCharges': transportCharges,
      'deliveryStatus': deliveryStatus,
      'dispatchDate': dispatchDate.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
