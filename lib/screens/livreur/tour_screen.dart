import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../repositories/batch_repository.dart';
import '../../repositories/order_repository.dart';
import '../../widgets/order_card.dart';
import '../../utils/constants.dart';
import '../../utils/enums.dart';

class LivreurTourScreen extends StatefulWidget {
  final String batchId;

  const LivreurTourScreen({
    super.key,
    required this.batchId,
  });

  @override
  State<LivreurTourScreen> createState() => _LivreurTourScreenState();
}

class _LivreurTourScreenState extends State<LivreurTourScreen> {
  final _otpController = TextEditingController();
  String? _selectedOrderId;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _validateDelivery(String orderId) async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un code OTP valide')),
      );
      return;
    }

    final orderRepo = Provider.of<OrderRepository>(context, listen: false);
    final success = await orderRepo.validateDelivery(
      orderId: orderId,
      otpCode: _otpController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Livraison validée avec succès'),
          backgroundColor: AppColors.success,
        ),
      );
      setState(() {
        _otpController.clear();
        _selectedOrderId = null;
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code OTP invalide ou expiré'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _updateOrderStatus(String orderId, OrderStatus status) async {
    final orderRepo = Provider.of<OrderRepository>(context, listen: false);
    await orderRepo.updateOrderStatus(orderId, status);
  }

  @override
  Widget build(BuildContext context) {
    final batchRepo = Provider.of<BatchRepository>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ma tournée'),
      ),
      body: FutureBuilder(
        future: batchRepo.getOrdersInBatch(widget.batchId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return const Center(child: Text('Aucune commande dans ce batch'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return OrderCard(
                      order: order,
                      onTap: () {
                        setState(() {
                          _selectedOrderId = order.id;
                        });
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => _OrderActionsSheet(
                            order: order,
                            onStatusUpdate: (status) {
                              _updateOrderStatus(order.id, status);
                              Navigator.pop(context);
                            },
                            onValidateDelivery: () {
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Valider la livraison'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('Client: ${order.clientName}'),
                                      const SizedBox(height: AppSpacing.md),
                                      TextField(
                                        controller: _otpController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: 'Code OTP',
                                          hintText: '123456',
                                        ),
                                        maxLength: 6,
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Annuler'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        _validateDelivery(order.id);
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Valider'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OrderActionsSheet extends StatelessWidget {
  final dynamic order;
  final Function(OrderStatus) onStatusUpdate;
  final VoidCallback onValidateDelivery;

  const _OrderActionsSheet({
    required this.order,
    required this.onStatusUpdate,
    required this.onValidateDelivery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            order.clientName,
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('${order.quartier} - ${order.deliveryAddress}'),
          const SizedBox(height: AppSpacing.lg),
          if (order.status == OrderStatus.priseEnCharge) ...[
            ElevatedButton(
              onPressed: () => onStatusUpdate(OrderStatus.enRoute),
              child: const Text('Marquer comme en route'),
            ),
          ],
          if (order.status == OrderStatus.enRoute) ...[
            ElevatedButton(
              onPressed: () => onStatusUpdate(OrderStatus.arriveADestination),
              child: const Text('Arrivé à destination'),
            ),
          ],
          if (order.status == OrderStatus.arriveADestination) ...[
            ElevatedButton(
              onPressed: onValidateDelivery,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
              ),
              child: const Text('Valider la livraison (OTP)'),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}

