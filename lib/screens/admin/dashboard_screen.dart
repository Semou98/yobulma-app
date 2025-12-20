import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../models/order_model.dart';
import '../../models/batch_model.dart';
import '../../models/user_model.dart';
import '../../utils/enums.dart';
import '../../app_state.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final currentUser = appState.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard ${currentUser?.role == UserRole.admin ? 'Admin' : currentUser?.role.name}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.secondary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              // Déconnexion
              appState.logout();
              FirebaseAuth.instance.signOut();
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
            // Bienvenue
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        currentUser?.displayName?.substring(0, 1) ?? 'U',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bonjour, ${currentUser?.displayName ?? 'Utilisateur'}!',
                            style: AppTextStyles.heading3.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rôle: ${currentUser?.role?.name.toUpperCase() ?? 'N/A'}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (currentUser?.email != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              currentUser!.email!,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            Text(
              'Statistiques',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Stats cards
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
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
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('isActive', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
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
                final clients = users.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['role'] == UserRole.client.toString().split('.').last;
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
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _StatCard(
                        title: 'Clients',
                        value: clients.toString(),
                        icon: Icons.people,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            // Batches en cours
            Text(
              'Batches en cours',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.secondary,
              ),
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
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        children: [
                          Icon(
                            Icons.inventory,
                            size: 48,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Aucun batch en cours',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final batches = snapshot.data!.docs;
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: batches.length,
                  itemBuilder: (context, index) {
                    try {
                      final batch = BatchModel.fromFirestore(batches[index]);
                      return Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: ListTile(
                          leading: const Icon(Icons.inventory_2, color: AppColors.primary),
                          title: Text('Batch ${batch.id.substring(0, 8)}'),
                          subtitle: Text('${batch.orderIds.length} livraisons'),
                          trailing: Chip(
                            label: Text(
                              batch.status == BatchStatus.priseEnCharge
                                  ? 'Prise en charge'
                                  : 'En cours',
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: batch.status == BatchStatus.priseEnCharge
                                ? AppColors.warning.withOpacity(0.2)
                                : AppColors.success.withOpacity(0.2),
                          ),
                          onTap: () {
                            // Navigation vers le détail du batch
                            if (currentUser?.role == UserRole.livreur) {
                              context.go('/livreur/tour/${batch.id}');
                            }
                          },
                        ),
                      );
                    } catch (e) {
                      return const ListTile(
                        title: Text('Erreur de chargement'),
                        leading: Icon(Icons.error, color: Colors.red),
                      );
                    }
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
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