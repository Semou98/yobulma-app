import 'package:flutter/material.dart';
import 'package:yoboulma_app/models/batch_model.dart';
import '../../data/mock_data.dart';
import '../../core/enums.dart';
import 'batch_detail_screen.dart'; // Prochaine étape

class LivreurBatchesListScreen extends StatefulWidget {
  const LivreurBatchesListScreen({super.key});

  @override
  State<LivreurBatchesListScreen> createState() =>
      _LivreurBatchesListScreenState();
}

class _LivreurBatchesListScreenState extends State<LivreurBatchesListScreen> {
  @override
  Widget build(BuildContext context) {
    final availableBatches = MockData.batches
        .where((b) => b.status == BatchStatus.DISPONIBLE)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Lots de livraisons Disponibles",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: availableBatches.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: availableBatches.length,
              itemBuilder: (context, index) {
                final batch = availableBatches[index];
                return _buildBatchCard(batch);
              },
            ),
    );
  }

  Widget _buildBatchCard(Batch batch) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: Color(0xFFFF9800), width: 5)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Quartier : ${batch.quartier}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  // Affichage du GAIN en évidence
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "${batch.deliveryFee.toInt()} FCFA",
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.store, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    "Vendeur : ${batch.vendorName}",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 18,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${batch.orderCount} colis à livrer",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
              const Divider(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BatchDetailScreen(batch: batch),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "VOIR LES DÉTAILS",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.moped, size: 80, color: Colors.grey[300]),
          const Text(
            "Aucun lot disponible pour le moment",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
