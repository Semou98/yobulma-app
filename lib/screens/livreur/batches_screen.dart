import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../repositories/batch_repository.dart';
import '../../widgets/batch_card.dart';
import '../../utils/constants.dart';

class LivreurBatchesScreen extends StatelessWidget {
  const LivreurBatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final batchRepo = Provider.of<BatchRepository>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Batches disponibles'),
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
      body: StreamBuilder(
        stream: batchRepo.getAvailableBatches(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final batches = snapshot.data ?? [];

          if (batches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Aucun batch disponible',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Les nouveaux batches apparaîtront ici',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: batches.length,
            itemBuilder: (context, index) {
              final batch = batches[index];
              return BatchCard(
                batch: batch,
                orderCount: batch.orderIds.length,
                onTap: () {
                  context.go('/livreur/tour/${batch.id}');
                },
                onAccept: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vous devez être connecté'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                    return;
                  }
                  
                  final success = await batchRepo.acceptBatch(
                    batchId: batch.id,
                    livreurId: user.uid,
                  );

                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Batch accepté avec succès'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    context.go('/livreur/tour/${batch.id}');
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Erreur lors de l\'acceptation'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

