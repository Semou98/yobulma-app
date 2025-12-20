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
      await _orders.doc(order.id).set(order.toFirestore());
      return order.id;
    } catch (e) {
      print('Error creating order: $e');
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
      print('Error getting order: $e');
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
      print('Error getting order by tracking code: $e');
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
          .where('status', isEqualTo: OrderStatus.enAttenteDeLivreur.name)
          .get();
      return query.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting pending orders: $e');
      return [];
    }
  }

  // Get orders by status
  Stream<List<OrderModel>> getOrdersByStatus(OrderStatus status) {
    return _orders
        .where('status', isEqualTo: status.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc))
            .toList());
  }

  // Get orders by batch ID
  Future<List<OrderModel>> getOrdersByBatch(String batchId) async {
    try {
      final query = await _orders
          .where('batchId', isEqualTo: batchId)
          .get();
      return query.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting orders by batch: $e');
      return [];
    }
  }

  // Update order
  Future<bool> updateOrder(OrderModel order) async {
    try {
      await _orders.doc(order.id).update(order.toFirestore());
      return true;
    } catch (e) {
      print('Error updating order: $e');
      return false;
    }
  }

  // ========== BATCHES ==========

  // Create batch
  Future<String?> createBatch(BatchModel batch) async {
    try {
      await _batches.doc(batch.id).set(batch.toFirestore());
      return batch.id;
    } catch (e) {
      print('Error creating batch: $e');
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
      print('Error getting batch: $e');
      return null;
    }
  }

  // Get batches by status
  Stream<List<BatchModel>> getBatchesByStatus(BatchStatus status) {
    return _batches
        .where('status', isEqualTo: status.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BatchModel.fromFirestore(doc))
            .toList());
  }

  // Get available batches for livreur (alias pour getBatchesByStatus avec pending)
  Stream<List<BatchModel>> getAvailableBatches() {
    return getBatchesByStatus(BatchStatus.pending);
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
      print('Error updating batch: $e');
      return false;
    }
  }

  // Get all active batches
  Stream<List<BatchModel>> getActiveBatches() {
    return _batches
        .where('status', isNotEqualTo: BatchStatus.completed.name)
        .orderBy('status')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BatchModel.fromFirestore(doc))
            .toList());
  }

  // Get batches with multiple statuses
  Stream<List<BatchModel>> getBatchesWithStatuses(List<BatchStatus> statuses) {
    if (statuses.isEmpty) {
      return const Stream.empty();
    }

    // Pour plusieurs statuts, nous devons faire une requête par statut
    // ou utiliser une autre approche selon les besoins
    return _batches
        .where('status', whereIn: statuses.map((s) => s.name).toList())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BatchModel.fromFirestore(doc))
            .toList());
  }

  // ========== USERS ==========

  // Get active livreurs
  Future<List<UserModel>> getActiveLivreurs() async {
    try {
      final query = await _users
          .where('role', isEqualTo: UserRole.livreur.name)
          .where('isActive', isEqualTo: true)
          .get();
      return query.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting active livreurs: $e');
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
      print('Error getting user: $e');
      return null;
    }
  }

  // Update user
  Future<bool> updateUser(UserModel user) async {
    try {
      await _users.doc(user.id).update(user.toFirestore());
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  // Get user by phone number
  Future<UserModel?> getUserByPhone(String phone) async {
    try {
      final query = await _users
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        return UserModel.fromFirestore(query.docs.first);
      }
      return null;
    } catch (e) {
      print('Error getting user by phone: $e');
      return null;
    }
  }

  // Create user
  Future<bool> createUser(UserModel user) async {
    try {
      await _users.doc(user.id).set(user.toFirestore());
      return true;
    } catch (e) {
      print('Error creating user: $e');
      return false;
    }
  }

  // Get users by role
  Future<List<UserModel>> getUsersByRole(UserRole role) async {
    try {
      final query = await _users
          .where('role', isEqualTo: role.name)
          .get();
      return query.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting users by role: $e');
      return [];
    }
  }

  // Search users by name or phone
  Future<List<UserModel>> searchUsers(String queryText) async {
    try {
      // Note: Firestore n'a pas de recherche texte complète native
      // Ceci est une recherche basique par préfixe
      final byName = await _users
          .where('fullName', isGreaterThanOrEqualTo: queryText)
          .where('fullName', isLessThanOrEqualTo: queryText + '\uf8ff')
          .get();

      final byPhone = await _users
          .where('phone', isGreaterThanOrEqualTo: queryText)
          .where('phone', isLessThanOrEqualTo: queryText + '\uf8ff')
          .get();

      final allDocs = {...byName.docs, ...byPhone.docs};
      final uniqueDocs = allDocs.toSet().toList();

      return uniqueDocs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }
}