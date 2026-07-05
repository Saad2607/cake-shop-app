import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cake.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../utils/cake_price.dart';
import '../utils/currency_formatter.dart';
import 'cake_image_tile.dart';

void showQuickAddSheet(BuildContext context, Cake cake) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _QuickAddSheet(cake: cake),
  );
}

class _QuickAddSheet extends StatefulWidget {
  final Cake cake;

  const _QuickAddSheet({required this.cake});

  @override
  State<_QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<_QuickAddSheet> {
  late String _size;
  late String _flavor;
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    _size = widget.cake.sizes.first;
    _flavor = widget.cake.flavors.first;
  }

  Future<void> _add() async {
    final price = CakePriceCalculator.priceForSize(widget.cake, _size);
    await context.read<CartProvider>().addItem(
          cakeId: widget.cake.id,
          cakeName: widget.cake.name,
          quantity: _qty,
          selectedSize: _size,
          selectedFlavor: _flavor,
          unitPrice: price,
        );
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${widget.cake.name} added',
                style: AppTheme.bodyMedium.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cake = widget.cake;
    final unitPrice = CakePriceCalculator.priceForSize(cake, _size);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDark.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        24 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: CakeImageTile(cake: cake, iconSize: 36),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cake.name, style: AppTheme.titleLarge, maxLines: 2),
                    const SizedBox(height: 6),
                    Text(
                      CurrencyFormatter.format(unitPrice),
                      style: AppTheme.displayMedium.copyWith(
                        fontSize: 22,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Size', style: AppTheme.titleMedium.copyWith(fontSize: 13)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: cake.sizes.map((s) {
              final sel = _size == s;
              return _Chip(
                label: s,
                selected: sel,
                onTap: () => setState(() => _size = s),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          Text('Flavor', style: AppTheme.titleMedium.copyWith(fontSize: 13)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: cake.flavors.map((f) {
              final sel = _flavor == f;
              return _Chip(
                label: f,
                selected: sel,
                onTap: () => setState(() => _flavor = f),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.cardBorder),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    _qtyBtn(Icons.remove, _qty > 1 ? () => setState(() => _qty--) : null),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('$_qty', style: AppTheme.titleLarge),
                    ),
                    _qtyBtn(Icons.add, () => setState(() => _qty++)),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: cake.inStock ? _add : null,
                    borderRadius: BorderRadius.circular(16),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: cake.inStock ? AppTheme.ctaGradient : null,
                        color: cake.inStock ? null : AppTheme.cardBorder,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'Add · ${CurrencyFormatter.format(unitPrice * _qty)}',
                          style: AppTheme.titleMedium.copyWith(
                            color: cake.inStock ? Colors.white : AppTheme.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback? onTap) {
    return Material(
      color: onTap != null
          ? AppTheme.primaryLight.withValues(alpha: 0.3)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            size: 18,
            color: onTap != null ? AppTheme.primary : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: selected ? AppTheme.ctaGradient : null,
            color: selected ? null : AppTheme.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? Colors.transparent : AppTheme.cardBorder,
            ),
          ),
          child: Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              fontSize: 12,
              color: selected ? Colors.white : AppTheme.textDark,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
