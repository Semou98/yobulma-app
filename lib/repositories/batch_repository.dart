import '../models/batch_model.dart';
import '../models/order_model.dart';
import '../services/firestore_service.dart';
import '../services/batching_service.dart';
import '../utils/enums.dart';

class BatchRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final BatchingService _batchingService = BatchingService();

  // Get available batches (for livreur)
  Stream<List<BatchModel>> getAvailableBatches() {
    // Utilisez getBatchesByStatus avec le statut pending
    return _firestoreService.getBatchesByStatus(BatchStatus.pending);
  }

  // Get batches by status
  Stream<List<BatchModel>> getBatchesByStatus(BatchStatus status) {
    return _firestoreService.getBatchesByStatus(status);
  }

  // Get batches by livreur
  Stream<List<BatchModel>> getBatchesByLivreur(String livreurId) {
    return _firestoreService.getBatchesByLivreur(livreurId);
  }

  // Get active batches (not completed)
  Stream<List<BatchModel>> getActiveBatches() {
    return _firestoreService.getActiveBatches();
  }

  // Get batch by ID
  Future<BatchModel?> getBatchById(String batchId) async {
    return await _firestoreService.getBatch(batchId);
  }

  // Accept batch (livreur accepts)
  Future<bool> acceptBatch({
    required String batchId,
    required String livreurId,
  }) async {
    return await _batchingService.assignBatchToLivreur(
      batchId: batchId,
      livreurId: livreurId,
    );
  }

  // Start batch delivery
  Future<bool> startBatchDelivery(String batchId) async {
    return await _batchingService.startBatchDelivery(batchId);
  }

  // Complete batch delivery
  Future<bool> completeBatchDelivery(String batchId) async {
    return await _batchingService.completeBatchDelivery(batchId);
  }

  // Get orders in batch
  Future<List<OrderModel>> getOrdersInBatch(String batchId) async {
    final batch = await getBatchById(batchId);
    if (batch == null) return [];

    // Utilisez la méthode spécialisée du FirestoreService si elle existe
    try {
      return await _firestoreService.getOrdersByBatch(batchId);
    } catch (e) {
      // Fallback: récupérer chaque commande individuellement
      final List<OrderModel> orders = [];
      for (final orderId in batch.orderIds) {
        final order = await _firestoreService.getOrder(orderId);
        if (order != null) {
          orders.add(order);
        }
      }
      return orders;
    }
  }

  // Get pending batches count
  Stream<int> getPendingBatchesCount() {
    return _firestoreService.getBatchesByStatus(BatchStatus.pending)
      .map((batches) => batches.length);
  }

  // Get active batches count for livreur
  Stream<int> getActiveBatchesCountForLivreur(String livreurId) {
    return _firestoreService.getBatchesByLivreur(livreurId)
      .map((batches) => batches
        .where((batch) => batch.status != BatchStatus.completed)
        .length);
  }

  // Get batch status summary
  Future<Map<BatchStatus, int>> getBatchStatusSummary() async {
    try {
      final pending = await _firestoreService.getBatchesByStatus(BatchStatus.pending).first;
      final enCours = await _firestoreService.getBatchesByStatus(BatchStatus.enCours).first;
      final completed = await _firestoreService.getBatchesByStatus(BatchStatus.completed).first;
      
      return {
        BatchStatus.pending: pending.length,
        BatchStatus.enCours: enCours.length,
        BatchStatus.completed: completed.length,
      };
    } catch (e) {
      print('Error getting batch status summary: $e');
      return {
        BatchStatus.pending: 0,
        BatchStatus.enCours: 0,
        BatchStatus.completed: 0,
      };
    }
  }
}