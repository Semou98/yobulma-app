import 'package:yoboulma_app/core/enums.dart';
import 'package:yoboulma_app/models/location_model.dart';

class Order {
  final String id;
  final String vendeurId;
  final String clientName;
  final String clientPhone;
  final Location deliveryLocation;
  final String colisDescription;
  final String otp;
  final String trackingLink;
  OrderStatus status;
  String? batchId;     // Corrigé : Retrait de final
  String? livreurId;   // Corrigé : Retrait de final
  final DateTime createdAt;
  DateTime updatedAt;

  Order({
    required this.id,
    required this.vendeurId,
    required this.clientName,
    required this.clientPhone,
    required this.deliveryLocation,
    required this.colisDescription,
    required this.otp,
    required this.trackingLink,
    required this.status,
    this.batchId,
    this.livreurId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      vendeurId: json['vendeurId'],
      clientName: json['clientName'],
      clientPhone: json['clientPhone'],
      deliveryLocation: Location.fromJson(json['deliveryLocation']),
      colisDescription: json['colisDescription'],
      otp: json['otp'],
      trackingLink: json['trackingLink'],
      status: OrderStatus.values.byName(json['status']),
      batchId: json['batchId'],
      livreurId: json['livreurId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendeurId': vendeurId,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'deliveryLocation': deliveryLocation.toJson(),
      'colisDescription': colisDescription,
      'otp': otp,
      'trackingLink': trackingLink,
      'status': status.name,
      'batchId': batchId,
      'livreurId': livreurId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Order copyWith({OrderStatus? status, String? batchId, String? livreurId}) {
    return Order(
      id: id,
      vendeurId: vendeurId,
      clientName: clientName,
      clientPhone: clientPhone,
      deliveryLocation: deliveryLocation,
      colisDescription: colisDescription,
      otp: otp,
      trackingLink: trackingLink,
      status: status ?? this.status,
      batchId: batchId ?? this.batchId,
      livreurId: livreurId ?? this.livreurId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  void updateStatus(OrderStatus newStatus) {
    status = newStatus;
    updatedAt = DateTime.now();
  }
}