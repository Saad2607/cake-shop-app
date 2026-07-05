import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FloatingCartBar extends StatelessWidget {
  final int itemCount;
  final double total;
  final String totalLabel;
  final VoidCallback onTap;

  const FloatingCartBar({
    super.key,
    required this.itemCount,
    required this.total,
    required this.totalLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppTheme.ctaGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_bag_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: AppTheme.gold,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$itemCount',
                            style: AppTheme.labelBold.copyWith(
                              color: const Color(0xFF4A3520),
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View your cart',
                      style: AppTheme.labelBold.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      totalLabel,
                      style: AppTheme.titleMedium.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
