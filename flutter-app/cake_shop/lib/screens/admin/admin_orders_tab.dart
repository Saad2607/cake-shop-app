import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../theme/admin_theme.dart';
import '../../utils/order_status.dart';
import '../../widgets/admin_order_card.dart';
import '../../widgets/empty_state.dart';

class AdminOrdersTab extends StatefulWidget {
  const AdminOrdersTab({super.key});

  @override
  State<AdminOrdersTab> createState() => _AdminOrdersTabState();
}

class _AdminOrdersTabState extends State<AdminOrdersTab> {
  final _searchController = TextEditingController();

  static const _filters = ['ALL', 'PENDING', 'CONFIRMED', 'BAKING', 'READY', 'DELIVERED', 'CANCELLED'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search order ID, customer, address…',
              hintStyle: const TextStyle(color: AdminTheme.textSecondary, fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded, color: AdminTheme.textSecondary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        admin.loadAllOrders(search: '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AdminTheme.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: AdminTheme.radiusMd,
                borderSide: const BorderSide(color: AdminTheme.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AdminTheme.radiusMd,
                borderSide: const BorderSide(color: AdminTheme.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AdminTheme.radiusMd,
                borderSide: const BorderSide(color: AdminTheme.accent, width: 1.5),
              ),
            ),
            onSubmitted: (v) => admin.loadAllOrders(search: v),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            itemCount: _filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final f = _filters[i];
              final selected = admin.orderStatusFilter == f;
              final label = f == 'ALL' ? 'All' : OrderStatusFlow.label(f);
              return FilterChip(
                label: Text(label, style: const TextStyle(fontSize: 12)),
                selected: selected,
                showCheckmark: false,
                backgroundColor: AdminTheme.surface,
                selectedColor: AdminTheme.accent,
                side: BorderSide(
                  color: selected ? AdminTheme.accent : AdminTheme.border,
                ),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : AdminTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (_) => admin.loadAllOrders(status: f),
              );
            },
          ),
        ),
        if (!admin.isLoading && admin.allOrders.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              '${admin.allOrders.length} order(s)',
              style: AdminTheme.kpiLabel,
            ),
          ),
        Expanded(
          child: admin.isLoading
              ? const Center(child: CircularProgressIndicator(color: AdminTheme.accent))
              : admin.allOrders.isEmpty
                  ? const EmptyState(
                      icon: Icons.inbox_outlined,
                      title: 'No orders found',
                      subtitle: 'Try changing filters or search.',
                    )
                  : RefreshIndicator(
                      color: AdminTheme.accent,
                      onRefresh: () => admin.loadAllOrders(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: admin.allOrders.length,
                        itemBuilder: (_, i) {
                          final order = admin.allOrders[i];
                          return AdminOrderCard(
                            order: order,
                            onStatusChanged: (status) async {
                              final ok = await admin.updateOrderStatus(order.id, status);
                              if (!context.mounted) return;
                              showAdminOrderSnackBar(
                                context,
                                ok: ok,
                                message: ok
                                    ? '${order.orderNumber} → ${OrderStatusFlow.label(status)}'
                                    : admin.error ?? 'Update failed',
                              );
                            },
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}
