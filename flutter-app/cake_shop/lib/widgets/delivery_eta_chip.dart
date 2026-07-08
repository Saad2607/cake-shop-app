import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/delivery_eta.dart';

class DeliveryEtaChip extends StatelessWidget {
  final String label;
  final bool light;

  const DeliveryEtaChip({
    super.key,
    required this.label,
    this.light = false,
  });

  factory DeliveryEtaChip.home() => DeliveryEtaChip(label: DeliveryEta.homeChipLabel());

  factory DeliveryEtaChip.checkout({DateTime? scheduledDate}) =>
      DeliveryEtaChip(label: DeliveryEta.checkoutLabel(scheduledDate: scheduledDate));

  @override
  Widget build(BuildContext context) {
    if (light) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bolt_rounded, color: AppTheme.gold, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTheme.labelBold.copyWith(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.goldLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.schedule_rounded, color: AppTheme.primary, size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: AppTheme.labelBold.copyWith(
                color: const Color(0xFF6B5030),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
