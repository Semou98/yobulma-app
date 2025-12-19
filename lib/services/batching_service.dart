import '../models/order_model.dart';
import '../models/batch_model.dart';
import '../services/firestore_service.dart';
import '../services/routing_service.dart';
import '../services/otp_service.dart';
import '../utils/enums.dart';
import '../utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class BatchingService {
  final FirestoreService _firestoreService = FirestoreService();
  final _uuid = const Uuid();

  // Create batches from pending orders - Groupage par quartier
  Future<List<String>> createBatchesFromPendingOrders() async {
    try {
      // Get all pending orders
      final pendingOrders = await _firestoreService.getPendingOrders();
      
      if (pendingOrders.isEmpty) {
        return [];
      }

      // Group orders by quartier
      final Map<String, List<OrderModel>> ordersByQuartier = {};
      for (final order in pendingOrders) {
        if (!ordersByQuartier.containsKey(order.quartier)) {
          ordersByQuartier[order.quartier] = [];
        }
        ordersByQuartier[order.quartier]!.add(order);
      }

      final List<String> batchIds = [];

      // Create batches for each quartier
      for (final quartier in ordersByQuartier.keys) {
        final quartierOrders = ordersByQuartier[quartier]!;
        
        // Split into batches of max size
        for (int i = 0; i < quartierOrders.length; i += AppConstants.maxOrdersPerBatch) {
          final orderGroup = quartierOrders.skip(i).take(AppConstants.maxOrdersPerBatch).toList();
          if (orderGroup.isEmpty) continue;

          // Extract delivery locations (only if available)
          final deliveryLocations = orderGroup
              .where((order) => order.deliveryLocation != null)
              .map((order) => order.deliveryLocation!)
              .toList();

          // Optimize route if we have locations
          List<GeoPoint> optimizedRoute = [];
          double? distance;
          double? duration;
          
          if (deliveryLocations.isNotEmpty) {
            optimizedRoute = RoutingService.optimizeRoute(deliveryLocations);
            distance = RoutingService.calculateRouteDistance(optimizedRoute);
            duration = RoutingService.estimateDuration(distance);
          }

          // Create batch
          final batch = BatchModel(
            id: _uuid.v4(),
            orderIds: orderGroup.map((order) => order.id).toList(),
            status: BatchStatus.pending,
            startLocation: deliveryLocations.isNotEmpty ? deliveryLocations.first : null,
            deliveryLocations: deliveryLocations,
            optimizedRoute: optimizedRoute,
            estimatedDistance: distance,
            estimatedDuration: duration,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          // Save batch to Firestore
          final batchId = await _firestoreService.createBatch(batch);
          if (batchId != null) {
            batchIds.add(batchId);

            // Update orders with batch ID, OTP, and tracking link
            for (final order in orderGroup) {
              // Generate OTP for each order
              final otpCode = OTPService.generateOTP();
              final otpExpiresAt = OTPService.getOTPExpiration();

              // Generate tracking code and link if not exists
              final trackingCode = order.trackingCode ?? _generateTrackingCode();
              final trackingLink = order.trackingLink ?? _generateTrackingLink(trackingCode);

              await _firestoreService.updateOrder(
                order.copyWith(
                  batchId: batchId,
                  status: OrderStatus.enAttenteDeLivreur, // Reste en attente jusqu'à acceptation par livreur
                  otpCode: otpCode,
                  otpExpiresAt: otpExpiresAt,
                  trackingCode: trackingCode,
                  trackingLink: trackingLink,
                  updatedAt: DateTime.now(),
                ),
              );
            }
          }
        }
      }

      return batchIds;
    } catch (e) {
      print('Error creating batches: $e');
      return [];
    }
  }

  // Assign batch to livreur
  Future<bool> assignBatchToLivreur({
    required String batchId,
    required String livreurId,
  }) async {
    try {
      final batch = await _firestoreService.getBatch(batchId);
      if (batch == null) return false;

      // Update batch - PRISE_EN_CHARGE quand livreur accepte
      await _firestoreService.updateBatch(
        batch.copyWith(
          livreurId: livreurId,
          status: BatchStatus.priseEnCharge,
          updatedAt: DateTime.now(),
        ),
      );

      // Update all orders in batch - PRISE_EN_CHARGE
      for (final orderId in batch.orderIds) {
        final order = await _firestoreService.getOrder(orderId);
        if (order != null) {
          await _firestoreService.updateOrder(
            order.copyWith(
              livreurId: livreurId,
              status: OrderStatus.priseEnCharge,
              updatedAt: DateTime.now(),
            ),
          );
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Start batch delivery
  Future<bool> startBatchDelivery(String batchId) async {
    try {
      final batch = await _firestoreService.getBatch(batchId);
      if (batch == null) return false;

      await _firestoreService.updateBatch(
        batch.copyWith(
          status: BatchStatus.enCours,
          startedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      // Update orders status - EN_ROUTE
      for (final orderId in batch.orderIds) {
        final order = await _firestoreService.getOrder(orderId);
        if (order != null) {
          await _firestoreService.updateOrder(
            order.copyWith(
              status: OrderStatus.enRoute,
              updatedAt: DateTime.now(),
            ),
          );
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Complete batch delivery
  Future<bool> completeBatchDelivery(String batchId) async {
    try {
      final batch = await _firestoreService.getBatch(batchId);
      if (batch == null) return false;

      await _firestoreService.updateBatch(
        batch.copyWith(
          status: BatchStatus.completed,
          completedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  // Generate unique tracking code
  String _generateTrackingCode() {
    return 'YB${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
  }

  // Generate tracking link (web externe sécurisé)
  String _generateTrackingLink(String trackingCode) {
    // TODO: Replace with actual web app URL when deployed
    return 'https://yoboulma.app/track/$trackingCode';
  }
}

