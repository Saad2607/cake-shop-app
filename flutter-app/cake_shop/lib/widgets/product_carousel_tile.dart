import 'package:flutter/material.dart';
import '../models/cake.dart';
import '../theme/app_theme.dart';
import '../utils/cake_price.dart';
import '../utils/currency_formatter.dart';
import 'cake_image_tile.dart';

/// Compact horizontal product tile for home carousels (Swiggy/Blinkit style).
class ProductCarouselTile extends StatelessWidget {
  final Cake cake;
  final VoidCallback onTap;

  const ProductCarouselTile({
    super.key,
    required this.cake,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppTheme.radiusMd,
          child: Ink(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: AppTheme.radiusMd,
              border: Border.all(color: AppTheme.cardBorder),
              boxShadow: [AppTheme.softShadow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: SizedBox(
                    height: 88,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CakeImageTile(cake: cake, iconSize: 32),
                        if (!cake.inStock)
                          Container(
                            color: Colors.black.withValues(alpha: 0.55),
                            alignment: Alignment.center,
                            child: Text(
                              'Sold out',
                              style: AppTheme.labelBold.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cake.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.titleMedium.copyWith(fontSize: 12, height: 1.25),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 12, color: AppTheme.gold),
                          const SizedBox(width: 2),
                          Text(
                            cake.rating.toStringAsFixed(1),
                            style: AppTheme.labelBold.copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${CakePriceCalculator.startingPriceLabel(cake)}${CurrencyFormatter.format(cake.basePrice)}',
                        style: AppTheme.titleMedium.copyWith(
                          fontSize: 13,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
