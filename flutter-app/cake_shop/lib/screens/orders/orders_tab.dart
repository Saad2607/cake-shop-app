import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/order_progress_tracker.dart';
import '../../utils/delivery_eta.dart';
import '../../utils/order_status.dart';
import '../auth/login_screen.dart';
import 'order_detail_screen.dart';

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  int _filter = 0; // 0 active, 1 all

  List<Order> _filtered(List<Order> orders) {
    if (_filter == 0) {
      return orders
          .where((o) => o.status != 'DELIVERED' && o.status != 'CANCELLED')
          .toList();
    }
    return orders;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orders = context.watch<OrderProvider>();

    if (!auth.isLoggedIn) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: const GradientHeader(title: 'My Orders'),
        body: EmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'Sign in to view orders',
          subtitle: 'Track your cake deliveries and order history after signing in.',
          actionLabel: 'Sign In',
          onAction: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          ),
        ),
      );
    }

    final list = _filtered(orders.orders);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const GradientHeader(title: 'My Orders', subtitle: 'Track your deliveries'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                _filterChip('Active', 0),
                const SizedBox(width: 8),
                _filterChip('All orders', 1),
              ],
            ),
          ),
          Expanded(
            child: orders.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : list.isEmpty
                    ? EmptyState(
                        icon: _filter == 0
                            ? Icons.local_shipping_outlined
                            : Icons.shopping_bag_outlined,
                        title: _filter == 0 ? 'No active orders' : 'No orders yet',
                        subtitle: _filter == 0
                            ? 'Delivered and cancelled orders appear under All orders.'
                            : 'Your order history will appear here once you place an order.',
                      )
                    : RefreshIndicator(
                        color: AppTheme.primary,
                        onRefresh: orders.loadOrders,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: list.length,
                          itemBuilder: (context, i) => _OrderCard(order: list[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, int index) {
    final selected = _filter == index;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filter = index),
      selectedColor: AppTheme.primaryLight.withValues(alpha: 0.5),
      checkmarkColor: AppTheme.primary,
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: selected ? AppTheme.primary : AppTheme.textMuted,
      ),
      side: BorderSide(color: selected ? AppTheme.primary : AppTheme.cardBorder),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final statusColor = AppTheme.orderStatusColor(order.status);
    final date = DateFormat('dd MMM yyyy, HH:mm')
        .format(DateTime.fromMillisecondsSinceEpoch(order.createdAt));
    final itemPreview = order.items?.isNotEmpty == true
        ? order.items!.map((e) => e.cakeName).take(2).join(', ')
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: AppTheme.radiusLg,
        boxShadow: [AppTheme.softShadow],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppTheme.radiusLg,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(order.orderNumber, style: AppTheme.titleLarge),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        OrderStatusFlow.label(order.status),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted.withValues(alpha: 0.5)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(date, style: AppTheme.bodySmall),
                if (itemPreview != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    itemPreview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.bodySmall.copyWith(fontSize: 11),
                  ),
                ],
                const SizedBox(height: 14),
                OrderProgressTracker(
                  status: order.status,
                  etaMessage: DeliveryEta.trackerSubtitle(order.status),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (order.discountAmount > 0)
                          Text(
                            CurrencyFormatter.format(order.subtotalAmount),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        Text(
                          CurrencyFormatter.format(order.totalAmount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'View details',
                      style: TextStyle(
                        color: AppTheme.primary.withValues(alpha: 0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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

