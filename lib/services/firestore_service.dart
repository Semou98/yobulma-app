import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../models/batch_model.dart';
import '../models/user_model.dart';
import '../utils/enums.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Orders Collection
  CollectionReference get _orders => _firestore.collection('orders');
  CollectionReference get _batches => _firestore.collection('batches');
  CollectionReference get _users => _firestore.collection('users');

  // ========== ORDERS ==========

  // Create order
  Future<String?> createOrder(OrderModel order) async {
    try {
      final docRef = await _orders.add(order.toFirestore());
      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  // Get order by ID
  Future<OrderModel?> getOrder(String orderId) async {
    try {
      final doc = await _orders.doc(orderId).get();
      if (doc.exists) {
        return OrderModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get order by tracking code
  Future<OrderModel?> getOrderByTrackingCode(String trackingCode) async {
    try {
      final query = await _orders
          .where('trackingCode', isEqualTo: trackingCode)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        return OrderModel.fromFirestore(query.docs.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get orders by vendeur
  Stream<List<OrderModel>> getOrdersByVendeur(String vendeurId) {
    return _orders
        .where('vendeurId', isEqualTo: vendeurId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc))
            .toList());
  }

  // Get pending orders (for batching) - EN_ATTENTE_DE_LIVREUR
  Future<List<OrderModel>> getPendingOrders() async {
    try {
      final query = await _orders
          .where('status', isEqualTo: OrderStatus.enAttenteDeLivreur.toString().split('.').last)
          .get();
      return query.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Update order
  Future<bool> updateOrder(OrderModel order) async {
    try {
      await _orders.doc(order.id).update(order.toFirestore());
      return true;
    } catch (e) {
      return false;
    }
  }

  // ========== BATCHES ==========

  // Create batch
  Future<String?> createBatch(BatchModel batch) async {
    try {
      final docRef = await _batches.add(batch.toFirestore());
      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  // Get batch by ID
  Future<BatchModel?> getBatch(String batchId) async {
    try {
      final doc = await _batches.doc(batchId).get();
      if (doc.exists) {
        return BatchModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get available batches for livreur
  Stream<List<BatchModel>> getAvailableBatches() {
    return _batches
        .where('status', isEqualTo: BatchStatus.pending.toString().split('.').last)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BatchModel.fromFirestore(doc))
            .toList());
  }

  // Get batches by livreur
  Stream<List<BatchModel>> getBatchesByLivreur(String livreurId) {
    return _batches
        .where('livreurId', isEqualTo: livreurId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BatchModel.fromFirestore(doc))
            .toList());
  }

  // Update batch
  Future<bool> updateBatch(BatchModel batch) async {
    try {
      await _batches.doc(batch.id).update(batch.toFirestore());
      return true;
    } catch (e) {
      return false;
    }
  }

  // ========== USERS ==========

  // Get active livreurs
  Future<List<UserModel>> getActiveLivreurs() async {
    try {
      final query = await _users
          .where('role', isEqualTo: UserRole.livreur.toString().split('.').last)
          .where('isActive', isEqualTo: true)
          .get();
      return query.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Get user by ID
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _users.doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

