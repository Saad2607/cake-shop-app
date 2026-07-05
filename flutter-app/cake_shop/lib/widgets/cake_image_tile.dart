import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/cake.dart';
import '../theme/app_theme.dart';
import '../utils/cake_visuals.dart';

/// Product visual — gradient art by default; network image when API provides URL.
class CakeImageTile extends StatelessWidget {
  final Cake cake;
  final double iconSize;
  final BorderRadius? borderRadius;

  const CakeImageTile({
    super.key,
    required this.cake,
    this.iconSize = 52,
    this.borderRadius,
  });

  static List<Color> gradientFor(String category) {
    switch (category) {
      case 'WEDDING':
        return [const Color(0xFFFFF8F0), const Color(0xFFF5E6D3)];
      case 'CUPCAKE':
        return [const Color(0xFFFDF0F5), const Color(0xFFF2C4D0)];
      case 'CUSTOM':
        return [const Color(0xFFF5F0FF), const Color(0xFFE8D5F5)];
      case 'SEASONAL':
        return [const Color(0xFFF0F8F4), const Color(0xFFD4E8DC)];
      default:
        return [const Color(0xFFFFF5F7), const Color(0xFFF8D4DC)];
    }
  }

  static IconData iconFor(String category) {
    switch (category) {
      case 'WEDDING':
        return Icons.favorite_rounded;
      case 'CUPCAKE':
        return Icons.cake_outlined;
      case 'CUSTOM':
        return Icons.brush_rounded;
      case 'SEASONAL':
        return Icons.ac_unit_rounded;
      default:
        return Icons.celebration_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(16);
    final url = CakeVisuals.networkUrlFor(cake);
    final colors = gradientFor(cake.category);

    return ClipRRect(
      borderRadius: radius,
      child: url == null
          ? _GradientFallback(cake: cake, iconSize: iconSize, colors: colors)
          : Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => _GradientFallback(
                    cake: cake,
                    iconSize: iconSize,
                    colors: colors,
                  ),
                  errorWidget: (_, __, ___) => _GradientFallback(
                    cake: cake,
                    iconSize: iconSize,
                    colors: colors,
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.03),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _GradientFallback extends StatelessWidget {
  final Cake cake;
  final double iconSize;
  final List<Color> colors;

  const _GradientFallback({
    required this.cake,
    required this.iconSize,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              CakeImageTile.iconFor(cake.category),
              size: iconSize * 1.8,
              color: colors.last.withValues(alpha: 0.4),
            ),
          ),
          Center(
            child: Icon(
              CakeImageTile.iconFor(cake.category),
              size: iconSize,
              color: AppTheme.primary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
