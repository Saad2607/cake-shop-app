import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../providers/cake_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/order_status.dart';
import '../../utils/payment_labels.dart';
import '../../utils/delivery_eta.dart';
import '../../widgets/cancel_order_dialog.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/order_progress_tracker.dart';
import '../../widgets/order_review_card.dart';
import '../../utils/reorder_helper.dart';
import '../home/main_screen.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>().orders;
    Order liveOrder = order;
    for (final o in orders) {
      if (o.id == order.id) {
        liveOrder = o;
        break;
      }
    }

    final statusColor = AppTheme.orderStatusColor(liveOrder.status);
    final created = DateTime.fromMillisecondsSinceEpoch(liveOrder.createdAt);
    final delivery = DateTime.fromMillisecondsSinceEpoch(liveOrder.deliveryDate);
    final isActive = liveOrder.status != 'DELIVERED' && liveOrder.status != 'CANCELLED';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const GradientHeader(
        title: 'Order details',
        subtitle: 'Track delivery & view bill',
        showBack: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          if (isActive) _liveTrackingCard(statusColor, liveOrder),
          _sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(liveOrder.orderNumber, style: AppTheme.titleLarge),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        OrderStatusFlow.label(liveOrder.status),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Placed ${DateFormat('dd MMM yyyy, hh:mm a').format(created)}',
                  style: AppTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                OrderProgressTracker(
                  status: liveOrder.status,
                  etaMessage: DeliveryEta.trackerSubtitle(liveOrder.status),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          OrderReviewCard(order: liveOrder),
          _sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Items', style: AppTheme.titleMedium),
                const SizedBox(height: 12),
                if (liveOrder.items == null || liveOrder.items!.isEmpty)
                  Text('No item details', style: AppTheme.bodySmall)
                else
                  ...liveOrder.items!.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLight.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.cake_rounded, color: AppTheme.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.cakeName, style: AppTheme.titleMedium.copyWith(fontSize: 14)),
                                  Text(
                                    '${item.quantity}× ${item.size} · ${item.flavor}',
                                    style: AppTheme.bodySmall.copyWith(fontSize: 11),
                                  ),
                                  if (item.customMessage != null &&
                                      item.customMessage!.trim().isNotEmpty)
                                    Text(
                                      '"${item.customMessage}"',
                                      style: AppTheme.bodySmall.copyWith(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 11,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              CurrencyFormatter.format(item.price),
                              style: AppTheme.titleMedium.copyWith(fontSize: 13),
                            ),
                          ],
                        ),
                      )),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _sectionCard(
            child: Column(
              children: [
                _infoRow(Icons.location_on_outlined, 'Deliver to', liveOrder.deliveryAddress),
                _infoRow(
                  Icons.calendar_today_outlined,
                  'Delivery date',
                  DateFormat('EEEE, dd MMM yyyy').format(delivery),
                ),
                _infoRow(
                  Icons.payment_outlined,
                  'Payment',
                  PaymentLabels.format(liveOrder.paymentMethod),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _sectionCard(
            child: Column(
              children: [
                _billRow('Item total', CurrencyFormatter.format(liveOrder.subtotalAmount)),
                if (liveOrder.discountAmount > 0)
                  _billRow(
                    'Discount${liveOrder.promoCode != null ? ' (${liveOrder.promoCode})' : ''}',
                    '-${CurrencyFormatter.format(liveOrder.discountAmount)}',
                    valueColor: AppTheme.success,
                  ),
                _billRow('Delivery', 'FREE', valueColor: AppTheme.success),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: AppTheme.cardBorder),
                ),
                _billRow(
                  'Total paid',
                  CurrencyFormatter.format(liveOrder.totalAmount),
                  bold: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (liveOrder.status == 'DELIVERED' || liveOrder.status == 'CANCELLED')
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _reorder(context),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Order again'),
              ),
            ),
          if (liveOrder.status == 'PENDING') ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _cancel(context),
                icon: const Icon(Icons.cancel_outlined, color: Color(0xFFC62828)),
                label: const Text('Cancel order', style: TextStyle(color: Color(0xFFC62828))),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: const Color(0xFFC62828).withValues(alpha: 0.45)),
                ),
              ),
            ),
          ],
          if (isActive) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MainScreen(initialTab: 2)),
                    (_) => false,
                  );
                },
                child: const Text('Back to orders'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _liveTrackingCard(Color statusColor, Order liveOrder) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withValues(alpha: 0.12),
            AppTheme.goldLight.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: AppTheme.radiusLg,
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.delivery_dining_rounded, color: statusColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Live status', style: AppTheme.labelBold.copyWith(fontSize: 10)),
                const SizedBox(height: 2),
                Text(
                  DeliveryEta.forOrderStatus(liveOrder.status),
                  style: AppTheme.titleMedium.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  DeliveryEta.trackerSubtitle(liveOrder.status),
                  style: AppTheme.bodySmall.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: AppTheme.radiusLg,
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [AppTheme.softShadow],
      ),
      child: child,
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppTheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTheme.bodySmall.copyWith(fontSize: 11)),
                const SizedBox(height: 2),
                Text(value, style: AppTheme.bodyMedium.copyWith(height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _billRow(String label, String value, {Color? valueColor, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.bodyMedium.copyWith(color: AppTheme.textMuted)),
          Text(
            value,
            style: (bold ? AppTheme.titleLarge : AppTheme.titleMedium).copyWith(
              fontSize: bold ? 18 : 14,
              color: valueColor ?? AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _reorder(BuildContext context) async {
    final ok = await reorderItems(
      context,
      order: order,
      cart: context.read<CartProvider>(),
      cakes: context.read<CakeProvider>(),
    );
    if (ok && context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen(initialTab: 1)),
        (_) => false,
      );
    }
  }

  Future<void> _cancel(BuildContext context) async {
    final confirm = await showCancelOrderDialog(
      context,
      orderNumber: order.orderNumber,
      total: order.totalAmount,
    );
    if (!confirm || !context.mounted) return;
    final ok = await context.read<OrderProvider>().cancelOrder(order.id);
    if (!context.mounted) return;
    if (ok) {
      AppSnackBar.success(context, 'Order cancelled');
      Navigator.pop(context);
    } else {
      AppSnackBar.error(context, 'Could not cancel order');
    }
  }
}
