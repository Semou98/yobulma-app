import 'package:flutter/material.dart';
import 'package:yoboulma_app/models/batch_model.dart';
import '../../data/mock_data.dart';
import 'delivery_map_screen.dart';

class LivreurBatchesListScreen extends StatefulWidget {
  const LivreurBatchesListScreen({super.key});

  @override
  State<LivreurBatchesListScreen> createState() =>
      _LivreurBatchesListScreenState();
}

class _LivreurBatchesListScreenState extends State<LivreurBatchesListScreen> {
  // En situation réelle, cela viendrait d'un service API
  List<Batch> activeBatches = MockData.batches;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mes Tournées (Groupage)",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: activeBatches.isEmpty
          ? const Center(child: Text("Aucune tournée disponible"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: activeBatches.length,
              itemBuilder: (context, index) {
                final batch = activeBatches[index];
                final deliveryCount = batch.orderIds.length;

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        color: Colors.blue,
                      ),
                    ),
                    title: Text(
                      "Groupage ${batch.quartier}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          "${batch.vendorName} • $deliveryCount commandes",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // VÉRIFICATION ET NAVIGATION
                      if (deliveryCount > 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DeliveryMapScreen(batch: batch),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Ce batch ne contient aucune commande.",
                            ),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
