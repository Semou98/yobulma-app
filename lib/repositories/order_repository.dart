import '../models/order_model.dart';
import '../services/firestore_service.dart';
import '../services/batching_service.dart';
import '../services/otp_service.dart';
import '../utils/enums.dart';
import 'package:uuid/uuid.dart';
import '../models/location_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final BatchingService _batchingService = BatchingService();
  final _uuid = const Uuid();

  // Create order
  Future<String?> createOrder({
    required String vendeurId,
    String? clientId,
    required String clientName,
    required String clientPhone,
    required LocationPoint deliveryLocationPoint,
    required String quartier,
    required String deliveryAddress,
    required GeoPoint deliveryLocation,
    required String description,
    double deliveryPrice = 0.0,
    double? amount,
  }) async {
    try {
      final now = DateTime.now();
      final trackingCode = _generateTrackingCode();
      final trackingLink = _generateTrackingLink(trackingCode);
      final otpCode = OTPService.generateOTP();
      final otpExpiresAt = OTPService.getOTPExpiration();

      final order = OrderModel(
        id: _uuid.v4(),
        vendeurId: vendeurId,
        clientId: clientId,
        clientName: clientName,
        clientPhone: clientPhone,
        quartier: quartier,
        trackingCode: trackingCode,
        trackingLink: trackingLink,
        otpCode: otpCode,
        otpExpiresAt: otpExpiresAt,
        deliveryAddress: deliveryAddress,
        deliveryLocation: deliveryLocation,
        deliveryLocationPoint: deliveryLocationPoint,
        description: description,
        status: OrderStatus.enAttenteDeLivreur,
        deliveryPrice: deliveryPrice,
        amount: amount ?? 0.0,
        livreurId: null, // Initialisé à null
        batchId: null, // Initialisé à null
        createdAt: now,
        updatedAt: now,
      );

      final orderId = await _firestoreService.createOrder(order);
      
      // Trigger batching after order creation
      if (orderId != null) {
        await _batchingService.createBatchesFromPendingOrders();
      }

      return orderId;
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  // Get order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    return await _firestoreService.getOrder(orderId);
  }

  // Get order by tracking code
  Future<OrderModel?> getOrderByTrackingCode(String trackingCode) async {
    return await _firestoreService.getOrderByTrackingCode(trackingCode);
  }

  // Get orders by vendeur (stream)
  Stream<List<OrderModel>> getOrdersByVendeur(String vendeurId) {
    return _firestoreService.getOrdersByVendeur(vendeurId);
  }

  // Get orders by status
  Stream<List<OrderModel>> getOrdersByStatus(OrderStatus status) {
    return _firestoreService.getOrdersByStatus(status);
  }

  // Get orders by batch ID
  Future<List<OrderModel>> getOrdersByBatch(String batchId) async {
    return await _firestoreService.getOrdersByBatch(batchId);
  }

  // Update order status
  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    final order = await getOrderById(orderId);
    if (order == null) return false;

    return await _firestoreService.updateOrder(
      order.copyWith(
        status: status,
        livreurId: order.livreurId, // Préservé
        batchId: order.batchId, // Préservé
        updatedAt: DateTime.now(),
      ),
    );
  }

  // Assign livreur to order
  Future<bool> assignLivreurToOrder({
    required String orderId,
    required String livreurId,
  }) async {
    final order = await getOrderById(orderId);
    if (order == null) return false;

    return await _firestoreService.updateOrder(
      order.copyWith(
        livreurId: livreurId,
        status: OrderStatus.priseEnCharge,
        updatedAt: DateTime.now(),
      ),
    );
  }

  // Update order to en route
  Future<bool> startOrderDelivery(String orderId) async {
    final order = await getOrderById(orderId);
    if (order == null) return false;

    return await _firestoreService.updateOrder(
      order.copyWith(
        status: OrderStatus.enRoute,
        livreurId: order.livreurId, // Préservé
        batchId: order.batchId, // Préservé
        updatedAt: DateTime.now(),
      ),
    );
  }

  // Validate delivery with OTP
  Future<bool> validateDelivery({
    required String orderId,
    required String otpCode,
  }) async {
    final order = await getOrderById(orderId);
    if (order == null) return false;

    // Check if OTP is valid
    if (!OTPService.validateOTP(otpCode, order.otpCode ?? '')) {
      return false;
    }

    // Check if OTP is expired
    if (OTPService.isOTPExpired(order.otpExpiresAt)) {
      return false;
    }

    // Update order to LIVRÉ
    return await _firestoreService.updateOrder(
      order.copyWith(
        status: OrderStatus.livre,
        livreurId: order.livreurId, // Préservé
        batchId: order.batchId, // Préservé
        deliveredAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  // Cancel order
  Future<bool> cancelOrder(String orderId) async {
    final order = await getOrderById(orderId);
    if (order == null) return false;

    return await _firestoreService.updateOrder(
      order.copyWith(
        status: OrderStatus.annule,
        livreurId: order.livreurId, // Préservé
        batchId: order.batchId, // Préservé
        updatedAt: DateTime.now(),
      ),
    );
  }

  // Update order tracking info
  Future<bool> updateOrderTracking({
    required String orderId,
    String? trackingCode,
    String? trackingLink,
  }) async {
    final order = await getOrderById(orderId);
    if (order == null) return false;

    return await _firestoreService.updateOrder(
      order.copyWith(
        trackingCode: trackingCode ?? order.trackingCode,
        trackingLink: trackingLink ?? order.trackingLink,
        livreurId: order.livreurId, // Préservé
        batchId: order.batchId, // Préservé
        updatedAt: DateTime.now(),
      ),
    );
  }

  // Generate unique tracking code
  String _generateTrackingCode() {
    return 'YB${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
  }

  // Generate tracking link
  String _generateTrackingLink(String trackingCode) {
    // TODO: Replace with actual web app URL when deployed
    return 'https://yoboulma.app/track/$trackingCode';
  }

  // Helper method to get active orders
  Stream<List<OrderModel>> getActiveOrdersByVendeur(String vendeurId) {
    return _firestoreService.getOrdersByVendeur(vendeurId)
      .map((orders) => orders
        .where((order) => order.status != OrderStatus.livre && 
                          order.status != OrderStatus.annule)
        .toList());
  }
}