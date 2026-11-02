import 'dart:ui';
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
  String? _size;
  String? _flavor;
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    if (widget.cake.sizes.isNotEmpty) {
      _size = widget.cake.sizes.first;
    }
    if (widget.cake.flavors.isNotEmpty) {
      _flavor = widget.cake.flavors.first;
    }
  }

  bool get _canAdd =>
      widget.cake.sizes.isNotEmpty && widget.cake.flavors.isNotEmpty;

  Future<void> _add() async {
    if (!_canAdd || _size == null || _flavor == null) return;
    final price = CakePriceCalculator.priceForSize(widget.cake, _size!);
    await context.read<CartProvider>().addItem(
          cakeId: widget.cake.id,
          cakeName: widget.cake.name,
          quantity: _qty,
          selectedSize: _size!,
          selectedFlavor: _flavor!,
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
                '${widget.cake.name} added to cart',
                style: AppTheme.bodyMedium.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cake = widget.cake;
    if (!_canAdd) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: const Text(
          'This cake is not available to order right now.',
          textAlign: TextAlign.center,
        ),
      );
    }
    final unitPrice = CakePriceCalculator.priceForSize(cake, _size!);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.9),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2B1D19).withValues(alpha: 0.12),
                blurRadius: 32,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(
            24,
            14,
            24,
            24 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textMuted.withValues(alpha: 0.25),
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
                        Text(
                          cake.name,
                          style: AppTheme.titleLarge.copyWith(fontSize: 17),
                          maxLines: 2,
                        ),
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
              const SizedBox(height: 22),
              Text(
                'CHOOSE SIZE',
                style: AppTheme.labelBold.copyWith(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: cake.sizes.map((s) {
                  final sel = _size == s;
                  return _GlassChip(
                    label: s,
                    selected: sel,
                    onTap: () => setState(() => _size = s),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              Text(
                'CHOOSE FLAVOR',
                style: AppTheme.labelBold.copyWith(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: cake.flavors.map((f) {
                  final sel = _flavor == f;
                  return _GlassChip(
                    label: f,
                    selected: sel,
                    onTap: () => setState(() => _flavor = f),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppTheme.cardBorder),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [AppTheme.softShadow],
                    ),
                    child: Row(
                      children: [
                        _qtyBtn(Icons.remove, _qty > 1 ? () => setState(() => _qty--) : null),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text('$_qty', style: AppTheme.titleLarge.copyWith(fontSize: 16)),
                        ),
                        _qtyBtn(Icons.add, () => setState(() => _qty++)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: GestureDetector(
                      onTap: cake.inStock ? _add : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: cake.inStock ? AppTheme.ctaGradient : null,
                          color: cake.inStock ? null : AppTheme.cardBorder,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: cake.inStock
                              ? [
                                  BoxShadow(
                                    color: AppTheme.primary.withValues(alpha: 0.35),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: onTap != null
              ? AppTheme.primaryLight.withValues(alpha: 0.35)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap != null ? AppTheme.primary : AppTheme.textMuted.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

class _GlassChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GlassChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
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
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [AppTheme.softShadow],
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
    );
  }
}
