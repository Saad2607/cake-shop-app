import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cake_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/cake_image_tile.dart';
import '../../widgets/empty_state.dart';
import '../catalog/cake_detail_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    final cakes = context.watch<CakeProvider>();
    final saved = cakes.cakes.where((c) => wishlist.isFavorite(c.id)).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Wishlist'),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
      ),
      body: cakes.isLoading && cakes.cakes.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : saved.isEmpty
              ? const EmptyState(
                  icon: Icons.favorite_border_rounded,
                  title: 'No favourites yet',
                  subtitle: 'Tap the heart on any cake to save it here.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: saved.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final cake = saved[i];
                    return Material(
                      color: AppTheme.surface,
                      borderRadius: AppTheme.radiusLg,
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CakeDetailScreen(cakeId: cake.id),
                          ),
                        ),
                        borderRadius: AppTheme.radiusLg,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  width: 72,
                                  height: 72,
                                  child: CakeImageTile(cake: cake, iconSize: 28),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(cake.name, style: AppTheme.titleMedium),
                                    const SizedBox(height: 4),
                                    Text(
                                      CurrencyFormatter.format(cake.basePrice),
                                      style: AppTheme.titleMedium.copyWith(
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => wishlist.toggle(cake.id),
                                icon: const Icon(Icons.favorite_rounded, color: AppTheme.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
