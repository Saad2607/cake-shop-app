import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cake.dart';
import '../../providers/cake_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/cake_image_tile.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/glass/glass_icon_button.dart';
import '../../widgets/quick_add_sheet.dart';
import '../catalog/cake_detail_screen.dart';

class WishlistScreen extends StatelessWidget {
  final bool isTab;
  final VoidCallback? onBrowseMenu;

  const WishlistScreen({
    super.key,
    this.isTab = false,
    this.onBrowseMenu,
  });

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    final cakes = context.watch<CakeProvider>();
    final saved = cakes.cakes.where((c) => wishlist.isFavorite(c.id)).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: isTab
          ? null
          : AppBar(
              title: Text('My Wishlist', style: AppTheme.titleLarge),
              backgroundColor: AppTheme.background,
              foregroundColor: AppTheme.textDark,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
            ),
      body: SafeArea(
        top: isTab,
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isTab)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('My Favourites', style: AppTheme.displayMedium),
                        const SizedBox(height: 2),
                        Text(
                          'Handcrafted cakes you\'ve saved for later',
                          style: AppTheme.bodySmall,
                        ),
                      ],
                    ),
                    if (saved.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '${saved.length} saved',
                          style: AppTheme.labelBold.copyWith(
                            color: AppTheme.primary,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            Expanded(
              child: cakes.isLoading && cakes.cakes.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                  : saved.isEmpty
                      ? EmptyState(
                          icon: Icons.favorite_border_rounded,
                          title: 'No favourites yet',
                          subtitle: 'Tap the heart on any artisan cake to save it to your wishlist.',
                          actionLabel: onBrowseMenu != null ? 'Browse Menu' : null,
                          onAction: onBrowseMenu,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                          itemCount: saved.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, i) {
                            final cake = saved[i];
                            return _WishlistCard(cake: cake);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WishlistCard extends StatelessWidget {
  final Cake cake;

  const _WishlistCard({required this.cake});

  @override
  Widget build(BuildContext context) {
    final wishlist = context.read<WishlistProvider>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.radiusLg,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.95),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2B1D19).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
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
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 76,
                    height: 76,
                    child: CakeImageTile(cake: cake, iconSize: 30),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cake.name,
                        style: AppTheme.titleMedium.copyWith(fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.format(cake.basePrice),
                        style: AppTheme.titleMedium.copyWith(
                          color: AppTheme.primary,
                          fontSize: 15,
                        ),
                      ),
                      if (cake.flavors.isNotEmpty)
                        Text(
                          cake.flavors.join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.bodySmall.copyWith(fontSize: 10),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GlassIconButton(
                      icon: Icons.favorite_rounded,
                      iconColor: AppTheme.primary,
                      size: 36,
                      iconSize: 18,
                      onTap: () => wishlist.toggle(cake.id),
                      tooltip: 'Remove',
                    ),
                    const SizedBox(height: 6),
                    if (cake.inStock)
                      GestureDetector(
                        onTap: () => showQuickAddSheet(context, cake),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppTheme.ctaGradient,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'Add',
                            style: AppTheme.labelBold.copyWith(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
