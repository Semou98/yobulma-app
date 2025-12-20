import 'package:flutter/material.dart';
import '../utils/enums.dart';
import '../utils/constants.dart';

class StatusChip extends StatelessWidget {
  final OrderStatus status;
  final bool small;

  const StatusChip({
    super.key,
    required this.status,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return Container(
      padding: small
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: config.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!small)
            Icon(
              config.icon,
              size: 14,
              color: config.iconColor,
            ),
          if (!small) const SizedBox(width: 4),
          Text(
            config.label,
            style: small
                ? const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  )
                : const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
          ),
        ],
      ),
    );
  }

  StatusConfig _getStatusConfig(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return StatusConfig(
          label: 'En attente',
          backgroundColor: AppColors.warning.withOpacity(0.9),
          borderColor: AppColors.warning,
          iconColor: Colors.white,
          icon: Icons.access_time,
        );
      case OrderStatus.accepted:
        return StatusConfig(
          label: 'Acceptée',
          backgroundColor: const Color(0xFF10B981).withOpacity(0.9),
          borderColor: const Color(0xFF10B981),
          iconColor: Colors.white,
          icon: Icons.check_circle,
        );
      case OrderStatus.preparing:
        return StatusConfig(
          label: 'En préparation',
          backgroundColor: const Color(0xFF6366F1).withOpacity(0.9),
          borderColor: const Color(0xFF6366F1),
          iconColor: Colors.white,
          icon: Icons.restaurant,
        );
      case OrderStatus.ready:
        return StatusConfig(
          label: 'Prête',
          backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.9),
          borderColor: const Color(0xFF8B5CF6),
          iconColor: Colors.white,
          icon: Icons.check_box,
        );
      case OrderStatus.onDelivery:
        return StatusConfig(
          label: 'En livraison',
          backgroundColor: AppColors.info.withOpacity(0.9),
          borderColor: AppColors.info,
          iconColor: Colors.white,
          icon: Icons.delivery_dining,
        );
      case OrderStatus.delivered:
        return StatusConfig(
          label: 'Livrée',
          backgroundColor: AppColors.success.withOpacity(0.9),
          borderColor: AppColors.success,
          iconColor: Colors.white,
          icon: Icons.check_circle_outline,
        );
      case OrderStatus.cancelled:
        return StatusConfig(
          label: 'Annulée',
          backgroundColor: AppColors.error.withOpacity(0.9),
          borderColor: AppColors.error,
          iconColor: Colors.white,
          icon: Icons.cancel,
        );
      case OrderStatus.enAttenteDeLivreur:  // NOUVEAU CAS
        return StatusConfig(
          label: 'Attente livreur',
          backgroundColor: AppColors.warning.withOpacity(0.9),
          borderColor: AppColors.warning,
          iconColor: Colors.white,
          icon: Icons.person_outline,
        );
      case OrderStatus.enCoursDeLivraison:  // NOUVEAU CAS
        return StatusConfig(
          label: 'En cours',
          backgroundColor: AppColors.info.withOpacity(0.9),
          borderColor: AppColors.info,
          iconColor: Colors.white,
          icon: Icons.directions_bike,
        );
      case OrderStatus.livre:  // NOUVEAU CAS
        return StatusConfig(
          label: 'Livrée',
          backgroundColor: AppColors.success.withOpacity(0.9),
          borderColor: AppColors.success,
          iconColor: Colors.white,
          icon: Icons.check_circle,
        );
      // CAS PAR DÉFAUT (au cas où)
      default:
        return StatusConfig(
          label: 'Inconnu',
          backgroundColor: AppColors.textSecondary.withOpacity(0.9),
          borderColor: AppColors.textSecondary,
          iconColor: Colors.white,
          icon: Icons.help_outline,
        );
    }
  }
}

class StatusConfig {
  final String label;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final IconData icon;

  StatusConfig({
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.icon,
  });
}