import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/enums.dart';

class BatchModel {
  final String id;
  final List<String> orderIds; // IDs des commandes groupées
  final String? livreurId; // Livreur assigné
  final BatchStatus status;
  final GeoPoint? startLocation; // Point de départ (pickup du premier colis)
  final List<GeoPoint> deliveryLocations; // Tous les points de livraison
  final List<GeoPoint> optimizedRoute; // Route optimisée (plus court chemin)
  final double? estimatedDistance; // Distance totale estimée en km
  final double? estimatedDuration; // Durée estimée en minutes
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;

  BatchModel({
    required this.id,
    required this.orderIds,
    this.livreurId,
    this.status = BatchStatus.pending,
    this.startLocation,
    this.deliveryLocations = const [],
    this.optimizedRoute = const [],
    this.estimatedDistance,
    this.estimatedDuration,
    this.startedAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
  });

  factory BatchModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BatchModel(
      id: doc.id,
      orderIds: List<String>.from(data['orderIds'] as List),
      livreurId: data['livreurId'] as String?,
      status: BatchStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => BatchStatus.pending,
      ),
      startLocation: data['startLocation'] as GeoPoint?,
      deliveryLocations: (data['deliveryLocations'] as List?)
              ?.map((e) => e as GeoPoint)
              .toList() ??
          [],
      optimizedRoute: (data['optimizedRoute'] as List?)
              ?.map((e) => e as GeoPoint)
              .toList() ??
          [],
      estimatedDistance: (data['estimatedDistance'] as num?)?.toDouble(),
      estimatedDuration: (data['estimatedDuration'] as num?)?.toDouble(),
      startedAt: data['startedAt'] != null
          ? (data['startedAt'] as Timestamp).toDate()
          : null,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      notes: data['notes'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'orderIds': orderIds,
      'livreurId': livreurId,
      'status': status.toString().split('.').last,
      'startLocation': startLocation,
      'deliveryLocations': deliveryLocations,
      'optimizedRoute': optimizedRoute,
      'estimatedDistance': estimatedDistance,
      'estimatedDuration': estimatedDuration,
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'notes': notes,
    };
  }

  BatchModel copyWith({
    String? id,
    List<String>? orderIds,
    String? livreurId,
    BatchStatus? status,
    GeoPoint? startLocation,
    List<GeoPoint>? deliveryLocations,
    List<GeoPoint>? optimizedRoute,
    double? estimatedDistance,
    double? estimatedDuration,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
  }) {
    return BatchModel(
      id: id ?? this.id,
      orderIds: orderIds ?? this.orderIds,
      livreurId: livreurId ?? this.livreurId,
      status: status ?? this.status,
      startLocation: startLocation ?? this.startLocation,
      deliveryLocations: deliveryLocations ?? this.deliveryLocations,
      optimizedRoute: optimizedRoute ?? this.optimizedRoute,
      estimatedDistance: estimatedDistance ?? this.estimatedDistance,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
    );
  }
}

