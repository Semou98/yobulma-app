import 'package:flutter/material.dart';
import '../models/batch_model.dart';
import '../utils/constants.dart';
import '../utils/enums.dart';
import 'package:intl/intl.dart';

class BatchCard extends StatelessWidget {
  final BatchModel batch;
  final int orderCount;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;

  const BatchCard({
    super.key,
    required this.batch,
    required this.orderCount,
    this.onTap,
    this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.inventory_2, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '$orderCount livraison${orderCount > 1 ? 's' : ''}',
                        style: AppTextStyles.heading3,
                      ),
                    ],
                  ),
                  if (batch.status == BatchStatus.pending && onAccept != null)
                    ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Accepter'),
                    ),
                ],
              ),
              if (batch.estimatedDistance != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(Icons.route, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${batch.estimatedDistance!.toStringAsFixed(1)} km',
                      style: AppTextStyles.bodySmall,
                    ),
                    if (batch.estimatedDuration != null) ...[
                      const SizedBox(width: AppSpacing.md),
                      const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '${batch.estimatedDuration!.toStringAsFixed(0)} min',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Text(
                DateFormat('dd/MM/yyyy HH:mm').format(batch.createdAt),
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

