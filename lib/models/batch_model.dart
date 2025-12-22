import 'package:yoboulma_app/core/enums.dart'; // Assurez-vous que BatchStatus est défini ici
import 'package:yoboulma_app/data/mock_data.dart';
import 'package:yoboulma_app/models/order_model.dart';
import 'package:yoboulma_app/models/route_step.dart';

class Batch {
  final String id;
  final String quartier;
  final List<String> orderIds;
  BatchStatus status; // Utilise l'enum BatchStatus (DISPONIBLE, EN_COURS, TERMINE, etc.)
  final String? livreurId;
  final List<RouteStep>? optimizedSteps;
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
    this.optimizedSteps,
    this.maxOrders = 5,
    required this.createdAt,
    required this.updatedAt,
  });

  // --- GETTERS ---
  
  bool get isFull => orderIds.length >= maxOrders;
  
  // Le lot est disponible s'il n'est pas déjà pris et pas plein
  bool get isAvailable => status == BatchStatus.DISPONIBLE && !isFull;
  
  int get orderCount => orderIds.length;

  // Récupère les objets Order complets à partir des IDs stockés
  List<Order> get deliveries =>
      MockData.orders.where((order) => orderIds.contains(order.id)).toList();

  // --- MÉTHODES ---

  Batch copyWithSteps(List<RouteStep> steps) {
    double totalDist = steps.fold(0, (sum, step) => sum + step.distanceMeters);
    return copyWith(optimizedSteps: steps, totalDistanceMeter: totalDist);
  }

  Batch copyWith({
    String? id,
    String? quartier,
    List<String>? orderIds,
    BatchStatus? status,
    String? livreurId,
    List<RouteStep>? optimizedSteps,
    double? totalDistanceMeter,
    String? vendorName,
    double? deliveryFee,
  }) {
    return Batch(
      id: id ?? this.id,
      quartier: quartier ?? this.quartier,
      orderIds: orderIds ?? this.orderIds,
      status: status ?? this.status,
      vendorName: vendorName ?? this.vendorName,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      livreurId: livreurId ?? this.livreurId,
      totalDistanceMeter: totalDistanceMeter ?? this.totalDistanceMeter,
      optimizedSteps: optimizedSteps ?? this.optimizedSteps,
      maxOrders: this.maxOrders,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(), // On met à jour la date de modification
    );
  }

  // --- JSON SERIALIZATION ---

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      id: json['id'],
      quartier: json['quartier'],
      orderIds: List<String>.from(json['orderIds']),
      // Conversion string vers enum
      status: BatchStatus.values.byName(json['status']),
      vendorName: json['vendorName'],
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
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
      'status': status.name, // On stocke le nom de l'enum en string
      'vendorName': vendorName,
      'deliveryFee': deliveryFee,
      'livreurId': livreurId,
      'maxOrders': maxOrders,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}