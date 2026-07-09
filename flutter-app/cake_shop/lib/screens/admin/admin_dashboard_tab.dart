import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../theme/admin_theme.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/order_status.dart';
import '../../widgets/admin/admin_dashboard_charts.dart';
import '../../widgets/admin/admin_kpi_card.dart';
import '../../widgets/admin_order_card.dart';
import '../../widgets/empty_state.dart';

class AdminDashboardTab extends StatelessWidget {
  final ValueChanged<int>? onNavigate;

  const AdminDashboardTab({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final dash = admin.dashboard;

    if (admin.isLoading && dash == null) {
      return const Center(child: CircularProgressIndicator(color: AdminTheme.accent));
    }
    if (admin.error != null && dash == null) {
      return EmptyState(
        icon: Icons.error_outline,
        title: 'Failed to load',
        subtitle: admin.error!,
        actionLabel: 'Retry',
        onAction: admin.loadDashboard,
      );
    }
    if (dash == null) return const SizedBox.shrink();

    return RefreshIndicator(
      color: AdminTheme.accent,
      onRefresh: admin.loadDashboard,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          if (dash.pendingOrders > 0)
            AdminAlertBanner(
              message: '${dash.pendingOrders} order(s) need your attention',
              icon: Icons.notifications_active_rounded,
              color: AdminTheme.warning,
              actionLabel: 'View',
              onTap: () => onNavigate?.call(1),
            ),
          if (dash.outOfStockCount > 0) ...[
            if (dash.pendingOrders > 0) const SizedBox(height: 10),
            AdminAlertBanner(
              message: '${dash.outOfStockCount} menu item(s) out of stock',
              icon: Icons.inventory_2_outlined,
              color: AdminTheme.accent,
              actionLabel: 'Menu',
              onTap: () => onNavigate?.call(2),
            ),
          ],
          const SizedBox(height: 20),
          Text("Today's performance", style: AdminTheme.sectionTitle),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                AdminKpiCard(
                  label: "Today's revenue",
                  value: CurrencyFormatter.format(dash.todayRevenue),
                  sublabel: 'Total ${CurrencyFormatter.format(dash.totalRevenue)}',
                  icon: Icons.currency_rupee_rounded,
                  color: AdminTheme.accent,
                ),
                const SizedBox(width: 10),
                AdminKpiCard(
                  label: "Today's orders",
                  value: '${dash.todayOrders}',
                  sublabel: '${dash.totalOrders} all time',
                  icon: Icons.receipt_long_rounded,
                  color: AdminTheme.info,
                  onTap: () => onNavigate?.call(1),
                ),
                const SizedBox(width: 10),
                AdminKpiCard(
                  label: 'Pending',
                  value: '${dash.pendingOrders}',
                  sublabel: 'Accept & process',
                  icon: Icons.pending_actions_rounded,
                  color: AdminTheme.warning,
                  onTap: () => onNavigate?.call(1),
                ),
                const SizedBox(width: 10),
                AdminKpiCard(
                  label: 'Customers',
                  value: '${dash.customerCount}',
                  sublabel: '${dash.cakeCount} menu items',
                  icon: Icons.people_alt_rounded,
                  color: AdminTheme.online,
                  onTap: () => onNavigate?.call(4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Quick actions', style: AdminTheme.sectionTitle),
          const SizedBox(height: 12),
          Row(
            children: [
              AdminQuickAction(
                icon: Icons.list_alt_rounded,
                label: 'All orders',
                onTap: () => onNavigate?.call(1),
              ),
              const SizedBox(width: 10),
              AdminQuickAction(
                icon: Icons.edit_note_rounded,
                label: 'Manage menu',
                onTap: () => onNavigate?.call(2),
              ),
              const SizedBox(width: 10),
              AdminQuickAction(
                icon: Icons.local_offer_rounded,
                label: 'Offers',
                onTap: () => onNavigate?.call(3),
              ),
              const SizedBox(width: 10),
              AdminQuickAction(
                icon: Icons.groups_rounded,
                label: 'Customers',
                onTap: () => onNavigate?.call(4),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AdminDashboardCharts(dash: dash),
          const SizedBox(height: 24),
          Text('Order pipeline', style: AdminTheme.sectionTitle),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: AdminTheme.cardDecoration,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: dash.statusBreakdown.entries.map((e) {
                final color = AdminTheme.statusColor(e.key);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: AdminTheme.radiusSm,
                    border: Border.all(color: color.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    '${OrderStatusFlow.label(e.key)}: ${e.value}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent orders', style: AdminTheme.sectionTitle),
              if (dash.recentOrders.isNotEmpty)
                TextButton(
                  onPressed: () => onNavigate?.call(1),
                  child: const Text('See all'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (dash.recentOrders.isEmpty)
            Text(
              'No orders yet',
              style: AdminTheme.kpiLabel.copyWith(fontWeight: FontWeight.w500),
            )
          else
            ...dash.recentOrders.take(5).map(
                  (o) => AdminOrderCard(
                    order: o,
                    compact: true,
                    onStatusChanged: (s) => admin.updateOrderStatus(o.id, s),
                  ),
                ),
        ],
      ),
    );
  }
}
