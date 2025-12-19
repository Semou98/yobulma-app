import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../models/order_model.dart';
import '../../models/batch_model.dart';
import '../../models/user_model.dart';
import '../../utils/enums.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // TODO: Implement logout
              context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistiques',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: AppSpacing.md),
            // Stats cards
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final orders = snapshot.data!.docs;
                final totalOrders = orders.length;
                final deliveredOrders = orders.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['status'] == OrderStatus.livre.toString().split('.').last;
                }).length;
                final pendingOrders = orders.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['status'] == OrderStatus.enAttenteDeLivreur.toString().split('.').last;
                }).length;

                return Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total commandes',
                        value: totalOrders.toString(),
                        icon: Icons.shopping_cart,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _StatCard(
                        title: 'Livrées',
                        value: deliveredOrders.toString(),
                        icon: Icons.check_circle,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _StatCard(
                        title: 'En attente',
                        value: pendingOrders.toString(),
                        icon: Icons.pending,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            // Active users
            Text(
              'Utilisateurs actifs',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSpacing.md),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('isActive', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final users = snapshot.data!.docs;
                final vendeurs = users.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['role'] == UserRole.vendeur.toString().split('.').last;
                }).length;
                final livreurs = users.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['role'] == UserRole.livreur.toString().split('.').last;
                }).length;

                return Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Vendeurs',
                        value: vendeurs.toString(),
                        icon: Icons.store,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _StatCard(
                        title: 'Livreurs',
                        value: livreurs.toString(),
                        icon: Icons.delivery_dining,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            // Batches in progress
            Text(
              'Batches en cours',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSpacing.md),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('batches')
                  .where('status', whereIn: [
                    BatchStatus.priseEnCharge.toString().split('.').last,
                    BatchStatus.enCours.toString().split('.').last,
                  ])
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final batches = snapshot.data!.docs;
                if (batches.isEmpty) {
                  return const Text('Aucun batch en cours');
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: batches.length,
                  itemBuilder: (context, index) {
                    final batch = BatchModel.fromFirestore(batches[index]);
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.inventory_2),
                        title: Text('Batch ${batch.id.substring(0, 8)}'),
                        subtitle: Text('${batch.orderIds.length} livraisons'),
                        trailing: Text(
                          batch.status == BatchStatus.priseEnCharge
                              ? 'Prise en charge'
                              : 'En cours',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: AppTextStyles.heading2.copyWith(color: color),
            ),
            Text(
              title,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

