import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cake.dart';
import '../../providers/admin_provider.dart';
import '../../theme/admin_theme.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/cake_image_tile.dart';
import '../../widgets/empty_state.dart';
import 'admin_cake_form_screen.dart';

class AdminProductsTab extends StatefulWidget {
  const AdminProductsTab({super.key});

  @override
  State<AdminProductsTab> createState() => _AdminProductsTabState();
}

class _AdminProductsTabState extends State<AdminProductsTab> {
  String _categoryFilter = 'ALL';

  static const _categories = ['ALL', 'BIRTHDAY', 'WEDDING', 'CUPCAKE', 'CUSTOM', 'SEASONAL'];

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final products = _categoryFilter == 'ALL'
        ? admin.products
        : admin.products.where((c) => c.category == _categoryFilter).toList();
    final inStock = admin.products.where((c) => c.inStock).length;
    final outStock = admin.products.length - inStock;

    return Scaffold(
      backgroundColor: AdminTheme.scaffold,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                _menuStat('$inStock', 'In stock', AdminTheme.online),
                const SizedBox(width: 10),
                _menuStat('$outStock', 'Out of stock', const Color(0xFFDC2626)),
                const SizedBox(width: 10),
                _menuStat('${admin.products.length}', 'Total items', AdminTheme.info),
              ],
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final selected = _categoryFilter == cat;
                return FilterChip(
                  label: Text(
                    cat == 'ALL' ? 'All' : cat[0] + cat.substring(1).toLowerCase(),
                    style: const TextStyle(fontSize: 12),
                  ),
                  selected: selected,
                  showCheckmark: false,
                  selectedColor: AdminTheme.accent,
                  backgroundColor: AdminTheme.surface,
                  side: BorderSide(color: selected ? AdminTheme.accent : AdminTheme.border),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AdminTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) => setState(() => _categoryFilter = cat),
                );
              },
            ),
          ),
          Expanded(
            child: admin.isLoading
                ? const Center(child: CircularProgressIndicator(color: AdminTheme.accent))
                : products.isEmpty
                    ? EmptyState(
                        icon: Icons.restaurant_menu_rounded,
                        title: admin.products.isEmpty ? 'Menu is empty' : 'No items in category',
                        subtitle: admin.products.isEmpty
                            ? 'Add cakes to your catalog like a restaurant menu.'
                            : 'Try another category filter.',
                        actionLabel: admin.products.isEmpty ? 'Add item' : null,
                        onAction: admin.products.isEmpty ? () => _openForm(context) : null,
                      )
                    : RefreshIndicator(
                        color: AdminTheme.accent,
                        onRefresh: admin.loadProducts,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: products.length,
                          itemBuilder: (_, i) => _ProductCard(cake: products[i]),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        backgroundColor: AdminTheme.accent,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add menu item'),
      ),
    );
  }

  Widget _menuStat(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: AdminTheme.cardDecoration,
        child: Column(
          children: [
            Text(value, style: AdminTheme.kpiValue.copyWith(fontSize: 18, color: color)),
            Text(label, style: AdminTheme.kpiLabel, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  void _openForm(BuildContext context, [Cake? cake]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AdminCakeFormScreen(cake: cake)),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Cake cake;

  const _ProductCard({required this.cake});

  @override
  Widget build(BuildContext context) {
    final admin = context.read<AdminProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: AdminTheme.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: AdminTheme.radiusSm,
              child: SizedBox(
                width: 64,
                height: 64,
                child: CakeImageTile(cake: cake, iconSize: 32),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cake.name,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${cake.category} · ${CurrencyFormatter.format(cake.basePrice)}',
                    style: const TextStyle(fontSize: 12, color: AdminTheme.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: (cake.inStock ? AdminTheme.online : const Color(0xFFDC2626))
                              .withValues(alpha: 0.1),
                          borderRadius: AdminTheme.radiusSm,
                        ),
                        child: Text(
                          cake.inStock ? 'Available' : 'Unavailable',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: cake.inStock ? AdminTheme.online : const Color(0xFFDC2626),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('★ ${cake.rating}', style: AdminTheme.kpiLabel),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: AdminTheme.textSecondary),
              onSelected: (action) async {
                if (action == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AdminCakeFormScreen(cake: cake)),
                  );
                } else if (action == 'stock') {
                  await admin.toggleStock(cake);
                } else if (action == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Remove from menu?'),
                      content: Text('Remove "${cake.name}" from catalog?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Remove'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    await admin.deleteProduct(cake.id);
                  }
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit item')),
                PopupMenuItem(
                  value: 'stock',
                  child: Text(cake.inStock ? 'Mark unavailable' : 'Mark available'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Remove', style: TextStyle(color: Color(0xFFDC2626))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
