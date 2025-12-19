import 'package:flutter/material.dart';
import '../utils/enums.dart';
import '../utils/constants.dart';

class StatusChip extends StatelessWidget {
  final OrderStatus status;
  final BatchStatus? batchStatus;

  const StatusChip({
    super.key,
    required this.status,
    this.batchStatus,
  });

  @override
  Widget build(BuildContext context) {
    final statusData = _getStatusData(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: statusData['color'] as Color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusData['label'] as String,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusData(OrderStatus status) {
    switch (status) {
      case OrderStatus.enAttenteDeLivreur:
        return {
          'label': 'En attente de livreur',
          'color': AppColors.warning,
        };
      case OrderStatus.priseEnCharge:
        return {
          'label': 'Prise en charge',
          'color': AppColors.secondary,
        };
      case OrderStatus.enRoute:
        return {
          'label': 'En route',
          'color': AppColors.primary,
        };
      case OrderStatus.arriveADestination:
        return {
          'label': 'Arrivé à destination',
          'color': AppColors.accent,
        };
      case OrderStatus.livre:
        return {
          'label': 'Livré',
          'color': AppColors.success,
        };
      case OrderStatus.cancelled:
        return {
          'label': 'Annulé',
          'color': AppColors.error,
        };
    }
  }
}

