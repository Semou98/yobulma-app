import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../repositories/order_repository.dart';
import '../../widgets/order_card.dart';
import '../../utils/constants.dart';

class VendeurOrdersScreen extends StatelessWidget {
  const VendeurOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Non connecté')),
      );
    }

    final orderRepo = Provider.of<OrderRepository>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes commandes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/vendeur/create-order'),
          ),
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
        stream: orderRepo.getOrdersByVendeur(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Aucune commande',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ElevatedButton(
                    onPressed: () => context.go('/vendeur/create-order'),
                    child: const Text('Créer une commande'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return OrderCard(
                order: order,
                onTap: () {
                  // TODO: Show order details
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(order.clientName),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Téléphone: ${order.clientPhone}'),
                          Text('Quartier: ${order.quartier}'),
                          Text('Adresse: ${order.deliveryAddress}'),
                          Text('Description: ${order.description}'),
                          if (order.trackingLink != null) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text('Lien de suivi: ${order.trackingLink}'),
                          ],
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Fermer'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/vendeur/create-order'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

