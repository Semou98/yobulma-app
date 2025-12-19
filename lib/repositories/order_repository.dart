import '../models/order_model.dart';
import '../services/firestore_service.dart';
import '../services/batching_service.dart';
import '../services/otp_service.dart';
import '../utils/enums.dart';
import 'package:uuid/uuid.dart';
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
    required String quartier,
    required String deliveryAddress,
    GeoPoint? deliveryLocation,
    required String description,
    double deliveryPrice = 0.0,
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
        description: description,
        status: OrderStatus.enAttenteDeLivreur,
        deliveryPrice: deliveryPrice,
        createdAt: now,
        updatedAt: now,
      );

      final orderId = await _firestoreService.createOrder(order);
      
      // Trigger batching after order creation
      if (orderId != null) {
        _batchingService.createBatchesFromPendingOrders();
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

  // Update order status
  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    final order = await getOrderById(orderId);
    if (order == null) return false;

    return await _firestoreService.updateOrder(
      order.copyWith(
        status: status,
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
        deliveredAt: DateTime.now(),
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
}

