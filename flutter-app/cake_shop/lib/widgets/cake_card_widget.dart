import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cake.dart';
import '../providers/wishlist_provider.dart';
import '../theme/app_theme.dart';
import '../utils/cake_price.dart';
import '../utils/currency_formatter.dart';
import 'cake_image_tile.dart';
import 'quick_add_sheet.dart';

class CakeCardWidget extends StatelessWidget {
  final Cake cake;
  final VoidCallback onTap;

  const CakeCardWidget({
    super.key,
    required this.cake,
    required this.onTap,
  });

  bool get _isBestseller => cake.rating >= 4.7;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTheme.radiusLg,
        child: Ink(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: AppTheme.radiusLg,
            boxShadow: [AppTheme.cardShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1.0,
                child: Stack(
                  children: [
                    CakeImageTile(
                      cake: cake,
                      iconSize: 44,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    if (_isBestseller)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: _Badge(
                          label: 'Chef\'s Pick',
                          gradient: AppTheme.goldGradient,
                          textColor: const Color(0xFF4A3520),
                        ),
                      ),
                    if (!cake.inStock)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Sold Out',
                                style: AppTheme.labelBold.copyWith(
                                  color: AppTheme.textMuted,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.goldLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 12,
                                  color: AppTheme.gold,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  cake.rating.toStringAsFixed(1),
                                  style: AppTheme.labelBold.copyWith(
                                    color: const Color(0xFF6B5030),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Consumer<WishlistProvider>(
                            builder: (context, wishlist, _) {
                              final fav = wishlist.isFavorite(cake.id);
                              return GestureDetector(
                                onTap: () => wishlist.toggle(cake.id),
                                child: Icon(
                                  fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  size: 16,
                                  color: fav ? AppTheme.primary : AppTheme.textMuted.withValues(alpha: 0.6),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cake.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.titleMedium.copyWith(
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${CakePriceCalculator.startingPriceLabel(cake)}${CurrencyFormatter.format(cake.basePrice)}',
                                  style: AppTheme.titleLarge.copyWith(
                                    fontSize: 15,
                                  ),
                                ),
                                if (cake.sizes.isNotEmpty)
                                  Text(
                                    'from ${cake.sizes.first}',
                                    style: AppTheme.bodySmall.copyWith(
                                      fontSize: 10,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (cake.inStock)
                            _AddButton(
                              onTap: () => showQuickAddSheet(context, cake),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Gradient gradient;
  final Color textColor;

  const _Badge({
    required this.label,
    required this.gradient,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppTheme.gold.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: AppTheme.labelBold.copyWith(color: textColor, fontSize: 9),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: 52,
          height: 32,
          decoration: BoxDecoration(
            gradient: AppTheme.ctaGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'Add',
              style: AppTheme.labelBold.copyWith(
                color: Colors.white,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
