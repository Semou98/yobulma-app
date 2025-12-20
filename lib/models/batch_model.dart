import 'package:yoboulma_app/core/enums.dart';

class Batch {
  final String id;
  final String quartier;
  final List<String> orderIds;
  BatchStatus status;
  final String? livreurId;
  final double? totalDistanceMeter;
  final int maxOrders;
  final String vendorName;
  final double deliveryFee;
  final DateTime createdAt;
  DateTime updatedAt;

  Batch({
    required this.id,
    required this.quartier,
    required this.orderIds,
    required this.status,
    required this.vendorName,
    required this.deliveryFee,
    this.livreurId,
    this.totalDistanceMeter,
    this.maxOrders = 5,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isFull => orderIds.length >= maxOrders;
  bool get isAvailable => status == BatchStatus.DISPONIBLE && !isFull;
  int get orderCount => orderIds.length;

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      id: json['id'],
      quartier: json['quartier'],
      orderIds: List<String>.from(json['orderIds']),
      status: BatchStatus.values.byName(json['status']),
      vendorName: json['vendorName'],
      deliveryFee: json['deliveryFee'],
      livreurId: json['livreurId'],
      maxOrders: json['maxOrders'] ?? 5,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quartier': quartier,
      'orderIds': orderIds,
      'status': status.name,
      'livreurId': livreurId,
      'maxOrders': maxOrders,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Batch copyWith({
    List<String>? orderIds,
    BatchStatus? status,
    String? livreurId,
  }) {
    return Batch(
      id: id,
      quartier: quartier,
      orderIds: orderIds ?? this.orderIds,
      status: status ?? this.status,
      vendorName: vendorName,
      deliveryFee: deliveryFee,
      livreurId: livreurId ?? this.livreurId,
      maxOrders: maxOrders,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
