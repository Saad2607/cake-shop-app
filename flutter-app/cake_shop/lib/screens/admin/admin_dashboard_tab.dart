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
import '../../widgets/glass/glass_card.dart';
import 'admin_kds_screen.dart';

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
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
        children: [
          if (dash.pendingOrders > 0)
            AdminAlertBanner(
              message: '${dash.pendingOrders} order(s) need immediate attention',
              icon: Icons.notifications_active_rounded,
              color: AdminTheme.warning,
              actionLabel: 'Review',
              onTap: () => onNavigate?.call(1),
            ),
          if (dash.outOfStockCount > 0) ...[
            if (dash.pendingOrders > 0) const SizedBox(height: 10),
            AdminAlertBanner(
              message: '${dash.outOfStockCount} cake item(s) currently out of stock',
              icon: Icons.inventory_2_outlined,
              color: AdminTheme.accent,
              actionLabel: 'Update',
              onTap: () => onNavigate?.call(2),
            ),
          ],
          const SizedBox(height: 18),
          Text("Today's Performance", style: AdminTheme.sectionTitle),
          const SizedBox(height: 12),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: AdminKpiCard(
                      label: "Today's Revenue",
                      value: CurrencyFormatter.format(dash.todayRevenue),
                      sublabel: 'Total ${CurrencyFormatter.format(dash.totalRevenue)}',
                      icon: Icons.currency_rupee_rounded,
                      color: AdminTheme.accent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AdminKpiCard(
                      label: "Today's Orders",
                      value: '${dash.todayOrders}',
                      sublabel: '${dash.totalOrders} total all-time',
                      icon: Icons.receipt_long_rounded,
                      color: AdminTheme.info,
                      onTap: () => onNavigate?.call(1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: AdminKpiCard(
                      label: 'Pending Orders',
                      value: '${dash.pendingOrders}',
                      sublabel: 'Requires action',
                      icon: Icons.pending_actions_rounded,
                      color: AdminTheme.warning,
                      onTap: () => onNavigate?.call(1),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AdminKpiCard(
                      label: 'Total Customers',
                      value: '${dash.customerCount}',
                      sublabel: '${dash.cakeCount} menu items',
                      icon: Icons.people_alt_rounded,
                      color: AdminTheme.online,
                      onTap: () => onNavigate?.call(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text('Quick Actions', style: AdminTheme.sectionTitle),
          const SizedBox(height: 10),
          Row(
            children: [
              AdminQuickAction(
                icon: Icons.list_alt_rounded,
                label: 'All Orders',
                onTap: () => onNavigate?.call(1),
              ),
              const SizedBox(width: 8),
              AdminQuickAction(
                icon: Icons.cake_rounded,
                label: 'Menu',
                onTap: () => onNavigate?.call(2),
              ),
              const SizedBox(width: 8),
              AdminQuickAction(
                icon: Icons.local_offer_rounded,
                label: 'Offers',
                onTap: () => onNavigate?.call(3),
              ),
              const SizedBox(width: 8),
              AdminQuickAction(
                icon: Icons.groups_rounded,
                label: 'Customers',
                onTap: () => onNavigate?.call(4),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminKdsScreen()),
              ),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E1C1A), Color(0xFF452422)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE6B980).withValues(alpha: 0.35)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
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
                        color: const Color(0xFFE6B980).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.soup_kitchen_rounded, color: Color(0xFFE6B980), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text(
                                'Kitchen Display System (KDS)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text('LIVE', style: TextStyle(color: Color(0xFFE6B980), fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tablet view · Order prep timers & piped messages',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFE6B980), size: 14),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          AdminDashboardCharts(dash: dash),
          const SizedBox(height: 22),
          Text('Order Pipeline Status', style: AdminTheme.sectionTitle),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.all(14),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: dash.statusBreakdown.entries.map((e) {
                final color = AdminTheme.statusColor(e.key);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${OrderStatusFlow.label(e.key)}: ${e.value}',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Orders', style: AdminTheme.sectionTitle),
              if (dash.recentOrders.isNotEmpty)
                TextButton(
                  onPressed: () => onNavigate?.call(1),
                  child: const Text('See all'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (dash.recentOrders.isEmpty)
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'No recent orders',
                  style: AdminTheme.kpiLabel.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
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
