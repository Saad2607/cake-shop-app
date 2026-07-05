import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/order_status.dart';

/// Animated pipeline: Placed → Confirmed → Baking → Ready → Delivered
class OrderProgressTracker extends StatelessWidget {
  final String status;

  const OrderProgressTracker({super.key, required this.status});

  static const _steps = ['PENDING', 'CONFIRMED', 'BAKING', 'READY', 'DELIVERED'];

  static const _icons = [
    Icons.receipt_long_rounded,
    Icons.verified_rounded,
    Icons.local_fire_department_rounded,
    Icons.cake_rounded,
    Icons.delivery_dining_rounded,
  ];

  int get _activeIndex {
    if (status == 'CANCELLED') return -1;
    final i = _steps.indexOf(status);
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    if (status == 'CANCELLED') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.cancel_outlined, color: Colors.red.shade700, size: 18),
            const SizedBox(width: 8),
            Text(
              'Order cancelled',
              style: AppTheme.titleMedium.copyWith(
                fontSize: 12,
                color: Colors.red.shade700,
              ),
            ),
          ],
        ),
      );
    }

    final active = _activeIndex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(_steps.length * 2 - 1, (i) {
            if (i.isOdd) {
              final stepIndex = i ~/ 2;
              final done = stepIndex < active;
              return Expanded(
                child: Container(
                  height: 3,
                  margin: const EdgeInsets.only(bottom: 22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: done
                        ? AppTheme.ctaGradient
                        : null,
                    color: done ? null : AppTheme.cardBorder,
                  ),
                ),
              );
            }

            final stepIndex = i ~/ 2;
            final isDone = stepIndex <= active;
            final isCurrent = stepIndex == active;

            return Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  width: isCurrent ? 34 : 28,
                  height: isCurrent ? 34 : 28,
                  decoration: BoxDecoration(
                    gradient: isDone ? AppTheme.ctaGradient : null,
                    color: isDone ? null : AppTheme.cardBorder,
                    shape: BoxShape.circle,
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    _icons[stepIndex],
                    size: isCurrent ? 16 : 14,
                    color: isDone ? Colors.white : AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 58,
                  child: Text(
                    OrderStatusFlow.label(_steps[stepIndex]),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.labelBold.copyWith(
                      fontSize: 8,
                      color: isCurrent
                          ? AppTheme.primary
                          : isDone
                              ? AppTheme.textDark
                              : AppTheme.textMuted,
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}
