import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/enums.dart';

class OrderModel {
  final String id;
  final String vendeurId;
  final String? clientId; // Optionnel si client non inscrit
  final String clientName;
  final String clientPhone;
  final String quartier; // Quartier de livraison (liste prédéfinie)
  final String? trackingCode; // Code unique pour tracking
  final String? trackingLink; // Lien web externe sécurisé pour suivi
  final String? otpCode; // Code OTP pour validation livraison
  final DateTime? otpExpiresAt;
  
  // Adresses
  final String deliveryAddress; // Adresse textuelle
  final GeoPoint? deliveryLocation; // Optionnel (peut être null si pas de GPS)
  
  // Détails du colis
  final String description;
  final String? photoUrl;
  final double? weight; // En kg
  final double? estimatedPrice;
  
  // Statut et livraison
  final OrderStatus status;
  final String? batchId; // ID du batch si groupé
  final String? livreurId;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  
  // Paiement
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final double deliveryPrice;
  
  // Métadonnées
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;

  OrderModel({
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
    required this.description,
    this.photoUrl,
    this.weight,
    this.estimatedPrice,
    this.status = OrderStatus.enAttenteDeLivreur,
    this.batchId,
    this.livreurId,
    this.pickedUpAt,
    this.deliveredAt,
    this.paymentMethod = PaymentMethod.cash,
    this.paymentStatus = PaymentStatus.pending,
    required this.deliveryPrice,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      vendeurId: data['vendeurId'] as String,
      clientId: data['clientId'] as String?,
      clientName: data['clientName'] as String,
      clientPhone: data['clientPhone'] as String,
      quartier: data['quartier'] as String,
      trackingCode: data['trackingCode'] as String?,
      trackingLink: data['trackingLink'] as String?,
      otpCode: data['otpCode'] as String?,
      otpExpiresAt: data['otpExpiresAt'] != null
          ? (data['otpExpiresAt'] as Timestamp).toDate()
          : null,
      deliveryAddress: data['deliveryAddress'] as String,
      deliveryLocation: data['deliveryLocation'] as GeoPoint?,
      description: data['description'] as String,
      photoUrl: data['photoUrl'] as String?,
      weight: (data['weight'] as num?)?.toDouble(),
      estimatedPrice: (data['estimatedPrice'] as num?)?.toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => OrderStatus.enAttenteDeLivreur,
      ),
      batchId: data['batchId'] as String?,
      livreurId: data['livreurId'] as String?,
      pickedUpAt: data['pickedUpAt'] != null
          ? (data['pickedUpAt'] as Timestamp).toDate()
          : null,
      deliveredAt: data['deliveredAt'] != null
          ? (data['deliveredAt'] as Timestamp).toDate()
          : null,
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString().split('.').last == data['paymentMethod'],
        orElse: () => PaymentMethod.cash,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      deliveryPrice: (data['deliveryPrice'] as num).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      notes: data['notes'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'vendeurId': vendeurId,
      'clientId': clientId,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'quartier': quartier,
      'trackingCode': trackingCode,
      'trackingLink': trackingLink,
      'otpCode': otpCode,
      'otpExpiresAt': otpExpiresAt != null
          ? Timestamp.fromDate(otpExpiresAt!)
          : null,
      'deliveryAddress': deliveryAddress,
      'deliveryLocation': deliveryLocation,
      'description': description,
      'photoUrl': photoUrl,
      'weight': weight,
      'estimatedPrice': estimatedPrice,
      'status': status.toString().split('.').last,
      'batchId': batchId,
      'livreurId': livreurId,
      'pickedUpAt': pickedUpAt != null
          ? Timestamp.fromDate(pickedUpAt!)
          : null,
      'deliveredAt': deliveredAt != null
          ? Timestamp.fromDate(deliveredAt!)
          : null,
      'paymentMethod': paymentMethod.toString().split('.').last,
      'paymentStatus': paymentStatus.toString().split('.').last,
      'deliveryPrice': deliveryPrice,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'notes': notes,
    };
  }

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
    String? description,
    String? photoUrl,
    double? weight,
    double? estimatedPrice,
    OrderStatus? status,
    String? batchId,
    String? livreurId,
    DateTime? pickedUpAt,
    DateTime? deliveredAt,
    PaymentMethod? paymentMethod,
    PaymentStatus? paymentStatus,
    double? deliveryPrice,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
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
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      weight: weight ?? this.weight,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      status: status ?? this.status,
      batchId: batchId ?? this.batchId,
      livreurId: livreurId ?? this.livreurId,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      deliveryPrice: deliveryPrice ?? this.deliveryPrice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
    );
  }
}

