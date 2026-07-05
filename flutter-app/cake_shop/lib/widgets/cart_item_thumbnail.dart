import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cake.dart';
import '../providers/cake_provider.dart';
import '../theme/app_theme.dart';
import 'cake_image_tile.dart';

/// Compact cake visual for cart line items.
class CartItemThumbnail extends StatelessWidget {
  final String cakeId;
  final double size;

  const CartItemThumbnail({
    super.key,
    required this.cakeId,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    final cakes = context.watch<CakeProvider>().cakes;
    Cake? cake;
    for (final c in cakes) {
      if (c.id == cakeId) {
        cake = c;
        break;
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: size,
        height: size,
        child: cake != null
            ? CakeImageTile(
                cake: cake,
                iconSize: size * 0.42,
                borderRadius: BorderRadius.circular(14),
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryLight.withValues(alpha: 0.5),
                      AppTheme.goldLight,
                    ],
                  ),
                ),
                child: Icon(
                  Icons.cake_rounded,
                  color: AppTheme.primary.withValues(alpha: 0.7),
                  size: size * 0.45,
                ),
              ),
      ),
    );
  }
}
