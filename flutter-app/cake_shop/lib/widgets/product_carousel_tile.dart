import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/cake.dart';
import '../theme/app_theme.dart';
import '../utils/cake_price.dart';
import '../utils/currency_formatter.dart';
import 'cake_image_tile.dart';

/// Compact horizontal product tile with frosted styling for home carousels.
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
      width: 140,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppTheme.radiusMd,
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.white.withValues(alpha: 0.90),
                ],
              ),
              borderRadius: AppTheme.radiusMd,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.95),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2B1D19).withValues(alpha: 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: SizedBox(
                    height: 94,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CakeImageTile(cake: cake, iconSize: 32),
                        // Glass shine on top
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 30,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withValues(alpha: 0.35),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (!cake.inStock)
                          ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                              child: Container(
                                color: Colors.black.withValues(alpha: 0.45),
                                alignment: Alignment.center,
                                child: Text(
                                  'Sold out',
                                  style: AppTheme.labelBold.copyWith(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
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
