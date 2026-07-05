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
        backgroundColor: AppTheme.primaryDark,
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppTheme.goldLight,
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
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.surface,
            foregroundColor: AppTheme.textDark,
            elevation: 0,
            title: Text('Your Cart', style: AppTheme.displayMedium.copyWith(fontSize: 22)),
            bottom: cart.items.isNotEmpty
                ? PreferredSize(
                    preferredSize: const Size.fromHeight(60),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.successLight,
                              AppTheme.goldLight.withValues(alpha: 0.5),
                            ],
                          ),
                          borderRadius: AppTheme.radiusMd,
                          border: Border.all(
                            color: AppTheme.success.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.success.withValues(alpha: 0.15),
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
                                    style: AppTheme.titleMedium.copyWith(fontSize: 13),
                                  ),
                                  Text(
                                    '${cart.itemCount} item(s) · Complimentary delivery',
                                    style: AppTheme.bodySmall.copyWith(fontSize: 11),
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
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _DeliveryAddressChip(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: OutlinedButton.icon(
                  onPressed: widget.onBrowseCakes,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add more items'),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 200),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final item = cart.items[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: AppTheme.radiusLg,
                        boxShadow: [AppTheme.softShadow],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
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
                                    style: AppTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.selectedSize} · ${item.selectedFlavor}',
                                    style: AppTheme.bodySmall,
                                  ),
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
                                            fontSize: 16,
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
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline_rounded,
                                    color: AppTheme.textMuted.withValues(alpha: 0.6),
                                    size: 20,
                                  ),
                                  onPressed: () => _removeWithUndo(context, item),
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
          ],
        ],
      ),
      bottomNavigationBar: cart.items.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryDark.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _billRow('Item total', CurrencyFormatter.format(cart.total)),
                    const SizedBox(height: 8),
                    _billRow('Delivery', 'FREE', valueColor: AppTheme.success),
                    const SizedBox(height: 8),
                    _billRow('Service fee', 'FREE', valueColor: AppTheme.success),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1, color: AppTheme.cardBorder),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total', style: AppTheme.titleLarge),
                        Text(
                          CurrencyFormatter.format(cart.total),
                          style: AppTheme.displayMedium.copyWith(fontSize: 24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _checkout(context),
                        borderRadius: BorderRadius.circular(16),
                        child: Ink(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: AppTheme.ctaGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              'Proceed to checkout · ${CurrencyFormatter.format(cart.total)}',
                              style: AppTheme.titleMedium.copyWith(
                                color: Colors.white,
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
    );
  }

  Widget _qtyButton({required IconData icon, VoidCallback? onTap}) {
    return Material(
      color: onTap != null
          ? AppTheme.primaryLight.withValues(alpha: 0.4)
          : AppTheme.cardBorder,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(
            icon,
            size: 18,
            color: onTap != null ? AppTheme.primary : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _billRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTheme.bodyMedium.copyWith(color: AppTheme.textMuted)),
        Text(
          value,
          style: AppTheme.titleMedium.copyWith(
            fontSize: 14,
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
    return Material(
      color: AppTheme.surface,
      borderRadius: AppTheme.radiusMd,
      child: InkWell(
        onTap: () => showDeliveryAddressSheet(context),
        borderRadius: AppTheme.radiusMd,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: AppTheme.radiusMd,
            border: Border.all(color: AppTheme.cardBorder),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on_outlined, color: AppTheme.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Deliver to', style: AppTheme.bodySmall.copyWith(fontSize: 10)),
                    Text(
                      delivery.hasAddress ? delivery.displayLine : 'Add delivery address',
                      style: AppTheme.titleMedium.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
