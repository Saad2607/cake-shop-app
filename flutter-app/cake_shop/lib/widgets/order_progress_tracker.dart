import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/delivery_eta.dart';
import '../utils/order_status.dart';

/// Animated Liquid Glass Pipeline: Placed → Confirmed → Baking → Ready → Out for Delivery → Delivered
class OrderProgressTracker extends StatelessWidget {
  final String status;
  final String? etaMessage;

  const OrderProgressTracker({
    super.key,
    required this.status,
    this.etaMessage,
  });

  static const _steps = [
    'PENDING',
    'CONFIRMED',
    'BAKING',
    'READY',
    'OUT_FOR_DELIVERY',
    'DELIVERED',
  ];

  static const _icons = [
    Icons.receipt_long_rounded,
    Icons.verified_rounded,
    Icons.outdoor_grill_rounded,
    Icons.inventory_2_rounded,
    Icons.delivery_dining_rounded,
    Icons.celebration_rounded,
  ];

  int get _activeIndex {
    if (status == 'CANCELLED') return -1;
    final i = _steps.indexOf(status);
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    if (status == 'CANCELLED') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.cancel_outlined, color: Colors.red.shade700, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Order cancelled',
                  style: AppTheme.titleMedium.copyWith(
                    fontSize: 13,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final active = _activeIndex;
    final subtitle = etaMessage ?? DeliveryEta.trackerSubtitle(status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (subtitle.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.goldLight.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.gold.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        subtitle,
                        style: AppTheme.labelBold.copyWith(
                          fontSize: 11,
                          color: const Color(0xFF6B5030),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Row(
          children: List.generate(_steps.length * 2 - 1, (i) {
            if (i.isOdd) {
              final stepIndex = i ~/ 2;
              final done = stepIndex < active;
              return Expanded(
                child: Container(
                  height: 3.5,
                  margin: const EdgeInsets.only(bottom: 22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: done ? AppTheme.ctaGradient : null,
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
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  width: isCurrent ? 34 : 26,
                  height: isCurrent ? 34 : 26,
                  decoration: BoxDecoration(
                    gradient: isDone ? AppTheme.ctaGradient : null,
                    color: isDone ? null : Colors.white.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDone
                          ? Colors.white.withValues(alpha: 0.9)
                          : AppTheme.cardBorder,
                      width: isCurrent ? 2 : 1,
                    ),
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.38),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    _icons[stepIndex],
                    size: isCurrent ? 16 : 13,
                    color: isDone ? Colors.white : AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 50,
                  child: Text(
                    OrderStatusFlow.label(_steps[stepIndex]),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.labelBold.copyWith(
                      fontSize: 8,
                      height: 1.1,
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
