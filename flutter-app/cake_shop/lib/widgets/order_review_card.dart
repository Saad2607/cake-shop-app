import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_snackbar.dart';

class OrderReviewCard extends StatefulWidget {
  final Order order;

  const OrderReviewCard({super.key, required this.order});

  @override
  State<OrderReviewCard> createState() => _OrderReviewCardState();
}

class _OrderReviewCardState extends State<OrderReviewCard> {
  int _rating = 0;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    if (order.status != 'DELIVERED') return const SizedBox.shrink();

    if (order.rating != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.radiusLg,
          border: Border.all(color: Colors.white, width: 1.2),
          boxShadow: [AppTheme.softShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star_rounded, color: AppTheme.gold, size: 20),
                const SizedBox(width: 8),
                Text('Your Experience Rating', style: AppTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: List.generate(5, (i) {
                return Icon(
                  i < order.rating! ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: AppTheme.gold,
                  size: 26,
                );
              }),
            ),
            if (order.reviewComment != null && order.reviewComment!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(order.reviewComment!, style: AppTheme.bodySmall),
            ],
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.goldLight.withValues(alpha: 0.45),
        borderRadius: AppTheme.radiusLg,
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.35)),
        boxShadow: [AppTheme.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rate_review_outlined, color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              Text('Rate your confection', style: AppTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'How was your sweet delight experience?',
            style: AppTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(5, (i) {
              final star = i + 1;
              return IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
                onPressed: () => setState(() => _rating = star),
                icon: Icon(
                  star <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: AppTheme.gold,
                  size: 32,
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: _rating > 0 && !_submitting ? AppTheme.ctaGradient : null,
              color: _rating == 0 || _submitting ? AppTheme.cardBorder : null,
              borderRadius: AppTheme.radiusMd,
              boxShadow: _rating > 0 && !_submitting
                  ? [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: ElevatedButton(
              onPressed: _rating == 0 || _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Submit rating'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final updated = await context.read<OrderProvider>().submitReview(
          widget.order.id,
          _rating,
        );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (updated != null) {
      AppSnackBar.success(context, 'Thanks for your feedback!');
    } else {
      AppSnackBar.error(context, 'Could not submit rating');
    }
  }
}
