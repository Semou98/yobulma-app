import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/enums.dart';
import './location_model.dart';

class OrderModel {
  final String id;
  final String vendeurId;
  final String? clientId;
  final String clientName;
  final String clientPhone;
  final String quartier;
  final String? trackingCode;
  final String? trackingLink;
  final String? otpCode;
  final DateTime? otpExpiresAt;
  final String deliveryAddress;
  final GeoPoint? deliveryLocation;
  final LocationPoint? deliveryLocationPoint;
  final String description;
  final OrderStatus status;
  final double deliveryPrice;
  final double amount;
  final String? livreurId;
  final String? batchId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deliveredAt;

  const OrderModel({
    required this.id,
    required this.vendeurId,
    this.clientId,
    required this.clientName,
    required this.clientPhone,
    required this.quartier,
    this.trackingCode,
    this.trackingLink,
    this.otpCode,
    this.otpExpiresAt,
    required this.deliveryAddress,
    this.deliveryLocation,
    this.deliveryLocationPoint,
    required this.description,
    required this.status,
    required this.deliveryPrice,
    required this.amount,
    this.livreurId,
    this.batchId,
    required this.createdAt,
    required this.updatedAt,
    this.deliveredAt,
  });

  // Convertir vers Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'vendeurId': vendeurId,
      'clientId': clientId,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'quartier': quartier,
      'trackingCode': trackingCode,
      'trackingLink': trackingLink,
      'otpCode': otpCode,
      'otpExpiresAt': otpExpiresAt?.toIso8601String(),
      'deliveryAddress': deliveryAddress,
      'deliveryLocation': deliveryLocation,
      'deliveryLocationPoint': deliveryLocationPoint?.toMap(),
      'description': description,
      'status': status.name,
      'deliveryPrice': deliveryPrice,
      'amount': amount,
      'livreurId': livreurId,
      'batchId': batchId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
    };
  }

  // Créer depuis Firestore
  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return OrderModel(
      id: data['id'] ?? doc.id,
      vendeurId: data['vendeurId'] ?? '',
      clientId: data['clientId'],
      clientName: data['clientName'] ?? '',
      clientPhone: data['clientPhone'] ?? '',
      quartier: data['quartier'] ?? '',
      trackingCode: data['trackingCode'],
      trackingLink: data['trackingLink'],
      otpCode: data['otpCode'],
      otpExpiresAt: data['otpExpiresAt'] != null 
          ? DateTime.parse(data['otpExpiresAt']) 
          : null,
      deliveryAddress: data['deliveryAddress'] ?? '',
      deliveryLocation: data['deliveryLocation'],
      deliveryLocationPoint: data['deliveryLocationPoint'] != null
          ? LocationPoint.fromMap(data['deliveryLocationPoint'])
          : null,
      description: data['description'] ?? '',
      status: _parseOrderStatus(data['status']),
      deliveryPrice: (data['deliveryPrice'] ?? 0.0).toDouble(),
      amount: (data['amount'] ?? 0.0).toDouble(),
      livreurId: data['livreurId'],
      batchId: data['batchId'],
      createdAt: data['createdAt'] != null 
          ? DateTime.parse(data['createdAt']) 
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? DateTime.parse(data['updatedAt']) 
          : DateTime.now(),
      deliveredAt: data['deliveredAt'] != null
          ? DateTime.parse(data['deliveredAt'])
          : null,
    );
  }

  static OrderStatus _parseOrderStatus(String? statusStr) {
    if (statusStr == null) return OrderStatus.enAttenteDeLivreur;
    
    try {
      return OrderStatus.values.firstWhere(
        (status) => status.name == statusStr,
        orElse: () => OrderStatus.enAttenteDeLivreur,
      );
    } catch (e) {
      return OrderStatus.enAttenteDeLivreur;
    }
  }

  // Méthode copyWith
  OrderModel copyWith({
    String? id,
    String? vendeurId,
    String? clientId,
    String? clientName,
    String? clientPhone,
    String? quartier,
    String? trackingCode,
    String? trackingLink,
    String? otpCode,
    DateTime? otpExpiresAt,
    String? deliveryAddress,
    GeoPoint? deliveryLocation,
    LocationPoint? deliveryLocationPoint,
    String? description,
    OrderStatus? status,
    double? deliveryPrice,
    double? amount,
    String? livreurId,
    String? batchId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deliveredAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      vendeurId: vendeurId ?? this.vendeurId,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      quartier: quartier ?? this.quartier,
      trackingCode: trackingCode ?? this.trackingCode,
      trackingLink: trackingLink ?? this.trackingLink,
      otpCode: otpCode ?? this.otpCode,
      otpExpiresAt: otpExpiresAt ?? this.otpExpiresAt,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      deliveryLocationPoint: deliveryLocationPoint ?? this.deliveryLocationPoint,
      description: description ?? this.description,
      status: status ?? this.status,
      deliveryPrice: deliveryPrice ?? this.deliveryPrice,
      amount: amount ?? this.amount,
      livreurId: livreurId ?? this.livreurId,
      batchId: batchId ?? this.batchId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }
}