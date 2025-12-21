import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/order_model.dart';
import '../../models/batch_model.dart';
import '../../core/enums.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Fonction de "Batching Automatique"
  void _runAutoBatching() {
    // 1. On récupère les commandes qui n'ont pas encore de lot
    List<Order> pendingOrders = MockData.orders
        .where(
          (o) =>
              o.status == OrderStatus.EN_ATTENTE_DE_LIVREUR &&
              (o.batchId == null),
        )
        .toList();

    if (pendingOrders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Aucune commande en attente de groupage."),
        ),
      );
      return;
    }

    // 2. Logique simplifiée : on groupe par quartier
    Map<String, List<String>> groups = {};
    for (var order in pendingOrders) {
      groups
          .putIfAbsent(order.deliveryLocation.quartier, () => [])
          .add(order.id.toString());
    }

    // 3. Création des nouveaux lots dans MockData
    int createdCount = 0;
    groups.forEach((quartier, orderIds) {
      final newBatch = Batch(
        id: "BATCH-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
        quartier: quartier,
        orderIds: orderIds,
        status: BatchStatus.DISPONIBLE,
        vendorName: "Multi-Vendeurs", // Ou le nom du vendeur principal
        deliveryFee:
            1500.0 + (orderIds.length * 500), // Calcul dynamique du gain
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      MockData.batches.add(newBatch);

      // Mettre à jour les commandes avec l'ID du batch
      for (var id in orderIds) {
        int idx = MockData.orders.indexWhere((o) => o.id == id);
        if (idx != -1) {
          MockData.orders[idx] = MockData.orders[idx].copyWith(
            batchId: newBatch.id,
          );
        }
      }
      createdCount++;
    });

    setState(() {});
    _showBatchingResult(createdCount);
  }

  void _showBatchingResult(int count) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Intelligence Logistique"),
        content: Text(
          "$count nouveaux lots (Batches) ont été générés par quartier.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalOrders = MockData.orders.length;
    int pendingBatch = MockData.orders.where((o) => o.batchId == null).length;
    int activeBatches = MockData.batches
        .where((b) => b.status == BatchStatus.EN_COURS)
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Yobulma Admin",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Vue d'ensemble",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Cartes de statistiques
            Row(
              children: [
                _buildStatCard(
                  "Commandes",
                  totalOrders.toString(),
                  Colors.blue,
                ),
                _buildStatCard(
                  "À Grouper",
                  pendingBatch.toString(),
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildStatCard(
                  "Lots Actifs",
                  activeBatches.toString(),
                  Colors.green,
                ),
                _buildStatCard(
                  "Livreurs",
                  MockData.users
                      .where((u) => u.roles.contains(Role.LIVREUR))
                      .length
                      .toString(),
                  Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Section Algorithme
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Color(0xFFFF9800)),
                      SizedBox(width: 10),
                      Text(
                        "Auto-Batching",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Regroupez automatiquement les commandes en attente par proximité géographique pour optimiser les tournées.",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _runAutoBatching,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
                      ),
                      child: const Text(
                        "LANCER L'ALGORITHME",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Text(
              "Lots Récents",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Liste des lots créés
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: MockData.batches.length,
              itemBuilder: (context, index) {
                final batch = MockData.batches[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.inventory_2,
                      color: Colors.orange,
                    ),
                    title: Text("Lot: ${batch.quartier}"),
                    subtitle: Text(
                      "${batch.orderIds.length} colis • ${batch.deliveryFee.toInt()} FCFA",
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
