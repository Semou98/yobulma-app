import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:yoboulma_app/models/order_model.dart';

import '../../repositories/order_repository.dart';
import '../../utils/constants.dart';
import '../../utils/enums.dart';

class TrackingScreen extends StatefulWidget {
  final String trackingCode;

  const TrackingScreen({
    super.key,
    required this.trackingCode,
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  @override
  Widget build(BuildContext context) {
    final orderRepo = Provider.of<OrderRepository>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi de commande'),
      ),
      body: FutureBuilder<OrderModel?>(
        future: orderRepo.getOrderByTrackingCode(widget.trackingCode),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Commande introuvable',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Le code de suivi est invalide',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            );
          }

          final order = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Commande ${order.trackingCode ?? "N/A"}',
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: AppSpacing.lg),
                // Timeline
                _buildTimeline(order),
                const SizedBox(height: AppSpacing.lg),
                // Order details
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Détails de la commande',
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _DetailRow(
                          icon: Icons.person,
                          label: 'Client',
                          value: order.clientName ?? 'N/A',
                        ),
                        _DetailRow(
                          icon: Icons.phone,
                          label: 'Téléphone',
                          value: order.clientPhone ?? 'N/A',
                        ),
                        _DetailRow(
                          icon: Icons.location_city,
                          label: 'Quartier',
                          value: order.quartier ?? 'N/A',
                        ),
                        _DetailRow(
                          icon: Icons.location_on,
                          label: 'Adresse',
                          value: order.deliveryAddress ?? 'N/A',
                        ),
                        _DetailRow(
                          icon: Icons.description,
                          label: 'Description',
                          value: order.description ?? 'N/A',
                        ),
                        _DetailRow(
                          icon: Icons.money,
                          label: 'Prix de livraison',
                          value: '${order.deliveryPrice?.toStringAsFixed(2) ?? "0.00"} FCFA',
                        ),
                        _DetailRow(
                          icon: Icons.calendar_today,
                          label: 'Date de création',
                          value: DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt),
                        ),
                        if (order.deliveredAt != null)
                          _DetailRow(
                            icon: Icons.check_circle,
                            label: 'Date de livraison',
                            value: DateFormat('dd/MM/yyyy HH:mm').format(order.deliveredAt!),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeline(OrderModel order) {
    // Convertir le string status en OrderStatus enum
    OrderStatus currentStatus;
    try {
      currentStatus = OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == order.status,
        orElse: () => OrderStatus.enAttenteDeLivreur,
      );
    } catch (e) {
      currentStatus = OrderStatus.enAttenteDeLivreur;
    }

    final steps = [
      {
        'status': OrderStatus.enAttenteDeLivreur,
        'label': 'En attente de livreur',
        'icon': Icons.pending,
      },
      {
        'status': OrderStatus.priseEnCharge,
        'label': 'Prise en charge',
        'icon': Icons.check_circle_outline,
      },
      {
        'status': OrderStatus.enRoute,
        'label': 'En route',
        'icon': Icons.local_shipping,
      },
      {
        'status': OrderStatus.arriveADestination,
        'label': 'Arrivé à destination',
        'icon': Icons.location_on,
      },
      {
        'status': OrderStatus.livre,
        'label': 'Livré',
        'icon': Icons.check_circle,
      },
    ];

    final currentIndex = steps.indexWhere(
      (step) => step['status'] == currentStatus,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: List.generate(steps.length, (index) {
            final step = steps[index];
            final isCompleted = index <= currentIndex;
            final isCurrent = index == currentIndex;

            return Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? (isCurrent ? AppColors.primary : AppColors.success)
                            : AppColors.textSecondary.withOpacity(0.3),
                      ),
                      child: Icon(
                        step['icon'] as IconData,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step['label'] as String,
                            style: TextStyle(
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                              color: isCompleted ? AppColors.textPrimary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (index < steps.length - 1)
                  Container(
                    margin: const EdgeInsets.only(left: 20),
                    width: 2,
                    height: 30,
                    color: isCompleted
                        ? AppColors.success
                        : AppColors.textSecondary.withOpacity(0.3),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall,
                ),
                Text(
                  value,
                  style: AppTextStyles.body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}