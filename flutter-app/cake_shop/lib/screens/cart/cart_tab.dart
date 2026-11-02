import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cart_item.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cake_provider.dart';
import '../../providers/cart_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/auth_guard.dart';
import '../../utils/currency_formatter.dart';
import '../../providers/delivery_address_provider.dart';
import '../../widgets/cart_item_thumbnail.dart';
import '../../widgets/delivery_address_sheet.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/glass/glass_card.dart';
import '../../widgets/glass/primary_button.dart';
import 'checkout_screen.dart';

class CartTab extends StatefulWidget {
  final VoidCallback? onBrowseCakes;

  const CartTab({super.key, this.onBrowseCakes});

  @override
  State<CartTab> createState() => _CartTabState();
}

class _CartTabState extends State<CartTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cakes = context.read<CakeProvider>();
      if (cakes.cakes.isEmpty && !cakes.isLoading) {
        cakes.loadCakes();
      }
    });
  }

  Future<void> _checkout(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      final ok = await AuthGuard.requireLogin(context);
      if (!ok || !context.mounted) return;
    }
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
    );
  }

  void _removeWithUndo(BuildContext context, CartItem item) {
    final cart = context.read<CartProvider>();
    cart.removeItem(item.id);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.cakeName ?? 'Item'} removed'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.textDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppTheme.roseAccent,
          onPressed: () {
            cart.addItem(
              cakeId: item.cakeId,
              cakeName: item.cakeName ?? 'Cake',
              quantity: item.quantity,
              selectedSize: item.selectedSize,
              selectedFlavor: item.selectedFlavor,
              customMessage: item.customMessage,
              unitPrice: item.unitPrice,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.background.withValues(alpha: 0.95),
            foregroundColor: AppTheme.textDark,
            elevation: 0,
            title: Text(
              'Your Cart',
              style: AppTheme.displayMedium.copyWith(fontSize: 22),
            ),
            bottom: cart.items.isNotEmpty
                ? PreferredSize(
                    preferredSize: const Size.fromHeight(66),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.successLight,
                              Colors.white.withValues(alpha: 0.9),
                            ],
                          ),
                          borderRadius: AppTheme.radiusMd,
                          border: Border.all(
                            color: AppTheme.success.withValues(alpha: 0.25),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.success.withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.success.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.delivery_dining_rounded,
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
                                    'Express delivery · 2–4 hrs',
                                    style: AppTheme.titleMedium.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '${cart.itemCount} item(s) · Complimentary delivery',
                                    style: AppTheme.bodySmall.copyWith(
                                      fontSize: 11,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : null,
          ),
          if (cart.isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
            )
          else if (cart.items.isEmpty)
            SliverFillRemaining(
              child: EmptyState(
                icon: Icons.shopping_bag_outlined,
                title: 'Your cart awaits',
                subtitle:
                    'Discover our handcrafted collection and treat yourself to something sweet.',
                actionLabel: 'Browse cakes',
                onAction: widget.onBrowseCakes,
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                child: _DeliveryAddressChip(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Text(
                      'Cart Items (${cart.itemCount})',
                      style: AppTheme.titleMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: widget.onBrowseCakes,
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Add items'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final item = cart.items[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        borderRadius: AppTheme.radiusLg,
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CartItemThumbnail(cakeId: item.cakeId),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.cakeName ?? 'Cake',
                                    style: AppTheme.titleMedium.copyWith(
                                      fontSize: 15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryLight.withValues(alpha: 0.35),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${item.selectedSize} · ${item.selectedFlavor}',
                                      style: AppTheme.bodySmall.copyWith(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                  ),
                                  if (item.customMessage != null &&
                                      item.customMessage!.trim().isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      '"${item.customMessage}"',
                                      style: AppTheme.bodySmall.copyWith(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 11,
                                        color: AppTheme.textMuted,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      _qtyButton(
                                        icon: Icons.remove,
                                        onTap: item.quantity > 1
                                            ? () => cart.updateQuantity(
                                                  item.id,
                                                  item.quantity - 1,
                                                )
                                            : null,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                        ),
                                        child: Text(
                                          '${item.quantity}',
                                          style: AppTheme.titleLarge.copyWith(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      _qtyButton(
                                        icon: Icons.add,
                                        onTap: () => cart.updateQuantity(
                                          item.id,
                                          item.quantity + 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  CurrencyFormatter.format(item.lineTotal),
                                  style: AppTheme.titleLarge.copyWith(
                                    color: AppTheme.primary,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => _removeWithUndo(context, item),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Icon(
                                        Icons.delete_outline_rounded,
                                        color: AppTheme.textMuted.withValues(alpha: 0.65),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: cart.items.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 170),
                child: GlassCard(
                  borderRadius: AppTheme.radiusLg,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.receipt_long_rounded,
                              color: AppTheme.primary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Bill Summary',
                            style: AppTheme.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _billRow('Item total', CurrencyFormatter.format(cart.total)),
                      const SizedBox(height: 8),
                      _billRow('Delivery fee', 'FREE', valueColor: AppTheme.success),
                      const SizedBox(height: 8),
                      _billRow('Packaging & taxes', 'FREE', valueColor: AppTheme.success),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1, color: AppTheme.cardBorder),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total to Pay', style: AppTheme.titleLarge),
                          Text(
                            CurrencyFormatter.format(cart.total),
                            style: AppTheme.displayMedium.copyWith(
                              fontSize: 22,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: 'Place Order · ${CurrencyFormatter.format(cart.total)}',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: () => _checkout(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _qtyButton({required IconData icon, VoidCallback? onTap}) {
    return Material(
      color: onTap != null
          ? AppTheme.primaryLight.withValues(alpha: 0.45)
          : AppTheme.cardBorder.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            icon,
            size: 16,
            color: onTap != null ? AppTheme.primary : AppTheme.textMuted.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _billRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textMuted, fontSize: 13),
        ),
        Text(
          value,
          style: AppTheme.titleMedium.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}

class _DeliveryAddressChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final delivery = context.watch<DeliveryAddressProvider>();
    return GlassCard(
      borderRadius: AppTheme.radiusMd,
      onTap: () => showDeliveryAddressSheet(context),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on_rounded, color: AppTheme.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DELIVER TO',
                  style: AppTheme.labelBold.copyWith(
                    fontSize: 9,
                    color: AppTheme.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  delivery.hasAddress ? delivery.displayLine : 'Add delivery address',
                  style: AppTheme.titleMedium.copyWith(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.textMuted.withValues(alpha: 0.7),
            size: 20,
          ),
        ],
      ),
    );
  }
}
