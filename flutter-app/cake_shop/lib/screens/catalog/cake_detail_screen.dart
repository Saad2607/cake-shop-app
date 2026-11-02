import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cake.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/cake_price.dart';
import '../../services/server_settings_service.dart';
import '../../utils/cake_share.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/cake_image_tile.dart';

class CakeDetailScreen extends StatefulWidget {
  final String cakeId;

  const CakeDetailScreen({super.key, required this.cakeId});

  @override
  State<CakeDetailScreen> createState() => _CakeDetailScreenState();
}

class _CakeDetailScreenState extends State<CakeDetailScreen> {
  int _quantity = 1;
  String? _selectedSize;
  String? _selectedFlavor;
  final _messageController = TextEditingController();
  late final Future<Cake> _cakeFuture;

  @override
  void initState() {
    super.initState();
    _cakeFuture = context.read<ApiService>().getCakeById(widget.cakeId);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _shareCake(Cake cake) {
    final settings = context.read<ServerSettingsService>();
    return CakeShare.shareCake(
      cake,
      shareBaseUrl: settings.shareBaseUrl,
    );
  }

  Future<void> _addToCart(Cake cake) async {
    if (_selectedSize == null || _selectedFlavor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select size and flavor'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final unitPrice = CakePriceCalculator.priceForSize(cake, _selectedSize!);

    await context.read<CartProvider>().addItem(
          cakeId: widget.cakeId,
          cakeName: cake.name,
          quantity: _quantity,
          selectedSize: _selectedSize!,
          selectedFlavor: _selectedFlavor!,
          customMessage:
              _messageController.text.isEmpty ? null : _messageController.text,
          unitPrice: unitPrice,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              const Text('Added to your cart'),
            ],
          ),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Cake>(
      future: _cakeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppTheme.background,
            body: Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary.withValues(alpha: 0.7),
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: AppTheme.background,
            appBar: AppBar(
              backgroundColor: AppTheme.surface,
              foregroundColor: AppTheme.textDark,
              title: const Text('Not Found'),
            ),
            body: const Center(child: Text('Cake not found')),
          );
        }

        final cake = snapshot.data!;
        _selectedSize ??= cake.sizes.isNotEmpty ? cake.sizes.first : null;
        _selectedFlavor ??= cake.flavors.isNotEmpty ? cake.flavors.first : null;
        final selectedSize = _selectedSize ?? cake.sizes.first;
        final unitPrice = CakePriceCalculator.priceForSize(cake, selectedSize);
        final lineTotal = unitPrice * _quantity;

        return Scaffold(
          backgroundColor: AppTheme.background,
          body: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 320,
                      pinned: true,
                      backgroundColor: AppTheme.surface,
                      foregroundColor: AppTheme.textDark,
                      leading: Padding(
                        padding: const EdgeInsets.all(8),
                        child: _GlassCircularButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          iconSize: 16,
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                      actions: [
                        _GlassCircularButton(
                          icon: Icons.share_outlined,
                          onTap: () => _shareCake(cake),
                        ),
                        const SizedBox(width: 8),
                        Consumer<WishlistProvider>(
                          builder: (context, wishlist, _) {
                            final fav = wishlist.isFavorite(cake.id);
                            return _GlassCircularButton(
                              icon: fav
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              iconColor: fav ? AppTheme.primary : AppTheme.textDark,
                              onTap: () => wishlist.toggle(cake.id),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            CakeImageTile(
                              cake: cake,
                              iconSize: 88,
                              borderRadius: BorderRadius.zero,
                            ),
                            // Top subtle shadow for app bar readability
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              height: 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.35),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: AppTheme.background,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(32),
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.goldLight,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        size: 16,
                                        color: AppTheme.gold,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${cake.rating.toStringAsFixed(1)} rating',
                                        style: AppTheme.labelBold.copyWith(
                                          color: const Color(0xFF6B5030),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryLight.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    cake.category,
                                    style: AppTheme.labelBold.copyWith(
                                      color: AppTheme.primary,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              cake.name,
                              style: AppTheme.displayLarge.copyWith(fontSize: 27),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  CurrencyFormatter.format(unitPrice),
                                  style: AppTheme.displayLarge.copyWith(
                                    fontSize: 30,
                                    color: AppTheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (cake.sizes.length > 1)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Text(
                                      'for $selectedSize',
                                      style: AppTheme.bodySmall,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            _trustRow(),
                            const SizedBox(height: 18),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: AppTheme.radiusMd,
                                border: Border.all(color: AppTheme.cardBorder),
                                boxShadow: [AppTheme.softShadow],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.successLight,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.local_shipping_outlined,
                                      color: AppTheme.success,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Express Delivery Available',
                                          style: AppTheme.titleMedium.copyWith(
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          'Freshly baked and delivered in 2–4 hours',
                                          style: AppTheme.bodySmall.copyWith(
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              cake.description,
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textMuted,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 26),
                            Text(
                              'SELECT SIZE',
                              style: AppTheme.labelBold.copyWith(
                                color: AppTheme.textMuted,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: cake.sizes.map((s) {
                                final selected = _selectedSize == s;
                                final sizePrice =
                                    CakePriceCalculator.priceForSize(cake, s);
                                return _DetailOptionChip(
                                  label: '$s · ${CurrencyFormatter.format(sizePrice)}',
                                  selected: selected,
                                  onTap: () => setState(() => _selectedSize = s),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 22),
                            Text(
                              'SELECT FLAVOR',
                              style: AppTheme.labelBold.copyWith(
                                color: AppTheme.textMuted,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: cake.flavors.map((f) {
                                final selected = _selectedFlavor == f;
                                return _DetailOptionChip(
                                  label: f,
                                  selected: selected,
                                  onTap: () => setState(() => _selectedFlavor = f),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),
                            TextField(
                              controller: _messageController,
                              maxLength: 50,
                              decoration: const InputDecoration(
                                labelText: 'Custom message on cake (optional)',
                                hintText: 'e.g. Happy Birthday, Sarah! 🎂',
                                prefixIcon: Icon(Icons.edit_note_rounded),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildBottomBar(cake, lineTotal),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(Cake cake, double lineTotal) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.8),
                width: 1.2,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2B1D19).withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 52,
              child: Row(
                children: [
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppTheme.cardBorder),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _qtyBtn(
                          icon: Icons.remove,
                          enabled: _quantity > 1,
                          onTap: () => setState(() => _quantity--),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text('$_quantity', style: AppTheme.titleLarge.copyWith(fontSize: 16)),
                        ),
                        _qtyBtn(
                          icon: Icons.add,
                          enabled: true,
                          onTap: () => setState(() => _quantity++),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: cake.inStock ? () => _addToCart(cake) : null,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: cake.inStock ? AppTheme.ctaGradient : null,
                          color: cake.inStock ? null : AppTheme.cardBorder,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: cake.inStock
                              ? [
                                  BoxShadow(
                                    color: AppTheme.primary.withValues(alpha: 0.32),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            cake.inStock
                                ? 'Add to Cart · ${CurrencyFormatter.format(lineTotal)}'
                                : 'Out of Stock',
                            style: AppTheme.titleMedium.copyWith(
                              color: cake.inStock
                                  ? Colors.white
                                  : AppTheme.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _trustRow() {
    return Row(
      children: [
        _trustChip(Icons.eco_outlined, 'Freshly\nBaked'),
        const SizedBox(width: 10),
        _trustChip(Icons.workspace_premium_outlined, 'Premium\nIngredients'),
        const SizedBox(width: 10),
        _trustChip(Icons.favorite_outline_rounded, 'Handcrafted\nWith Love'),
      ],
    );
  }

  Widget _trustChip(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.cardBorder),
          boxShadow: [AppTheme.softShadow],
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: AppTheme.primary),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTheme.labelBold.copyWith(
                fontSize: 9.5,
                color: AppTheme.textMuted,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyBtn({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppTheme.primary : AppTheme.textMuted.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

class _GlassCircularButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final double iconSize;

  const _GlassCircularButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.82),
            border: Border.all(color: Colors.white.withValues(alpha: 0.95)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Center(
                child: Icon(
                  icon,
                  size: iconSize,
                  color: iconColor ?? AppTheme.textDark,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailOptionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DetailOptionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? AppTheme.ctaGradient : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? Colors.transparent : AppTheme.cardBorder,
            width: 1.2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [AppTheme.softShadow],
        ),
        child: Text(
          label,
          style: AppTheme.bodyMedium.copyWith(
            fontSize: 12.5,
            color: selected ? Colors.white : AppTheme.textDark,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
