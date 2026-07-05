import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';

/// Premium confirmation dialog for cancelling an order.
/// Returns `true` if user confirms cancellation.
Future<bool> showCancelOrderDialog(
  BuildContext context, {
  required String orderNumber,
  required double total,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (ctx) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: AppTheme.radiusLg,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFC62828).withValues(alpha: 0.12),
                      AppTheme.primary.withValues(alpha: 0.06),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC62828).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFC62828).withValues(alpha: 0.25),
                        ),
                      ),
                      child: const Icon(
                        Icons.cancel_outlined,
                        color: Color(0xFFC62828),
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Cancel this order?',
                      style: AppTheme.titleLarge.copyWith(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Order $orderNumber',
                      style: AppTheme.titleMedium.copyWith(
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: AppTheme.radiusSm,
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order total',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textMuted,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(total),
                            style: AppTheme.titleMedium.copyWith(
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This action cannot be undone. Your order will be removed and any payment will be refunded according to store policy.',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textMuted,
                        height: 1.45,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Keep order'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC62828),
                              foregroundColor: Colors.white,
                              elevation: 0,
                            ),
                            child: const Text('Yes, cancel'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  return result ?? false;
}
