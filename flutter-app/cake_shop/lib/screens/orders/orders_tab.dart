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
  final bool showBack;
  final VoidCallback? onBack;

  const OrdersTab({
    super.key,
    this.showBack = false,
    this.onBack,
  });

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  int _filter = 1;
  bool _autoFilterApplied = false;

  List<Order> _filtered(List<Order> orders) {
    if (_filter == 0) {
      return orders
          .where((o) => o.status != 'DELIVERED' && o.status != 'CANCELLED')
          .toList();
    }
    return orders;
  }

  void _applyAutoFilter(List<Order> orders) {
    if (_autoFilterApplied) return;
    final hasActive = orders.any(
      (o) => o.status != 'DELIVERED' && o.status != 'CANCELLED',
    );
    _filter = hasActive ? 0 : 1;
    _autoFilterApplied = true;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final orderProvider = context.read<OrderProvider>();
      if (orderProvider.orders.isEmpty) {
        await orderProvider.loadOrders();
      }
      if (!mounted) return;
      setState(() => _applyAutoFilter(orderProvider.orders));
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orders = context.watch<OrderProvider>();

    if (!auth.isLoggedIn) {
      _autoFilterApplied = false;
      _filter = 1;
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: GradientHeader(
          title: 'My Orders',
          showBack: widget.showBack || widget.onBack != null,
          onBack: widget.onBack,
        ),
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

    if (!_autoFilterApplied && !orders.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _applyAutoFilter(orders.orders));
      });
    }

    final list = _filtered(orders.orders);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: GradientHeader(
        title: 'My Orders',
        subtitle: 'Track your deliveries & order history',
        showBack: widget.showBack || widget.onBack != null,
        onBack: widget.onBack,
      ),
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
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
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
    return GestureDetector(
      onTap: () => setState(() => _filter = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected ? AppTheme.ctaGradient : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Colors.transparent : AppTheme.cardBorder,
            width: 1.2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [AppTheme.softShadow],
        ),
        child: Text(
          label,
          style: AppTheme.labelBold.copyWith(
            color: selected ? Colors.white : AppTheme.textDark,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final statusColor = AppTheme.orderStatusColor(order.status);
    final date = DateFormat('dd MMM yyyy, hh:mm a')
        .format(DateTime.fromMillisecondsSinceEpoch(order.createdAt));
    final itemPreview = order.items?.isNotEmpty == true
        ? order.items!.map((e) => e.cakeName).take(2).join(', ')
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.radiusLg,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.95),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2B1D19).withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
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
                      child: Text(order.orderNumber, style: AppTheme.titleLarge.copyWith(fontSize: 16)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        OrderStatusFlow.label(order.status),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.textMuted, size: 13),
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
                              fontSize: 11,
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
                        fontWeight: FontWeight.w700,
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
