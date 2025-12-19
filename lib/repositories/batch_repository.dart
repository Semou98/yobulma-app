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
    return _firestoreService.getAvailableBatches();
  }

  // Get batches by livreur
  Stream<List<BatchModel>> getBatchesByLivreur(String livreurId) {
    return _firestoreService.getBatchesByLivreur(livreurId);
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

