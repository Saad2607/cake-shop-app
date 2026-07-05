import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order.dart';
import '../../theme/admin_theme.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/payment_labels.dart';
import '../../utils/order_status.dart';

Color adminStatusColor(String status) => AdminTheme.statusColor(status);

class AdminOrderCard extends StatefulWidget {
  final Order order;
  final ValueChanged<String> onStatusChanged;
  final bool compact;

  const AdminOrderCard({
    super.key,
    required this.order,
    required this.onStatusChanged,
    this.compact = false,
  });

  @override
  State<AdminOrderCard> createState() => _AdminOrderCardState();
}

class _AdminOrderCardState extends State<AdminOrderCard> {
  bool _expanded = false;

  Order get order => widget.order;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM, hh:mm a');
    final statusColor = AdminTheme.statusColor(order.status);
    final isNew = order.status == 'PENDING';
    final showQuickActions = widget.compact &&
        order.status != 'CANCELLED' &&
        !OrderStatusFlow.isTerminal(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AdminTheme.surface,
        borderRadius: AdminTheme.radiusMd,
        border: Border.all(
          color: isNew ? statusColor.withValues(alpha: 0.35) : AdminTheme.border,
          width: isNew ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: AdminTheme.radiusMd,
              child: Padding(
                padding: EdgeInsets.fromLTRB(widget.compact ? 12 : 14, 12, 12, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!widget.compact) ...[
                      Container(
                        width: 4,
                        height: 52,
                        margin: const EdgeInsets.only(right: 10, top: 2),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  order.orderNumber,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              if (isNew)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AdminTheme.warning.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'NEW',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: AdminTheme.warning,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          if (order.customerName != null)
                            Text(
                              order.customerName!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          Text(
                            dateFormat.format(
                              DateTime.fromMillisecondsSinceEpoch(order.createdAt),
                            ),
                            style: const TextStyle(
                              color: AdminTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _statusBadge(order.status, statusColor),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(
                          _expanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: AdminTheme.textSecondary,
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.format(order.totalAmount),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AdminTheme.accent,
                            fontSize: 15,
                          ),
                        ),
                        if (order.discountAmount > 0) ...[
                          const SizedBox(height: 2),
                          Text(
                            '${order.promoCode ?? 'Promo'} · -${CurrencyFormatter.format(order.discountAmount)}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AdminTheme.online,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (showQuickActions && !_expanded) ...[
            const Divider(height: 1, color: AdminTheme.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: OrderStatusFlow.allowedNext(order.status).map((s) {
                    final isCancel = s == 'CANCELLED';
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ActionChip(
                        label: Text(OrderStatusFlow.label(s)),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isCancel ? const Color(0xFFDC2626) : AdminTheme.accent,
                        ),
                        backgroundColor: isCancel
                            ? const Color(0xFFDC2626).withValues(alpha: 0.08)
                            : AdminTheme.accent.withValues(alpha: 0.08),
                        onPressed: () => widget.onStatusChanged(s),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
              child: _expandedContent(),
            ),
        ],
      ),
    );
  }

  Widget _expandedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 1, color: AdminTheme.border),
        const SizedBox(height: 12),
        if (order.customerEmail != null && order.customerEmail!.isNotEmpty) ...[
          _infoRow(Icons.person_outline, 'Customer', order.customerName ?? ''),
          _infoRow(Icons.email_outlined, 'Email', order.customerEmail!),
          if (order.customerPhone != null && order.customerPhone!.isNotEmpty)
            _infoRow(Icons.phone_outlined, 'Phone', order.customerPhone!),
        ],
        _infoRow(Icons.location_on_outlined, 'Address', order.deliveryAddress),
        _infoRow(
          Icons.calendar_today_outlined,
          'Delivery',
          DateFormat('dd MMM yyyy').format(
            DateTime.fromMillisecondsSinceEpoch(order.deliveryDate),
          ),
        ),
        _infoRow(Icons.payment_outlined, 'Payment', PaymentLabels.format(order.paymentMethod)),
        if (order.items != null && order.items!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Order items', style: AdminTheme.sectionTitle.copyWith(fontSize: 13)),
          const SizedBox(height: 8),
          ...order.items!.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AdminTheme.scaffold,
                  borderRadius: AdminTheme.radiusSm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.cakeName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(
                            '${item.quantity}× ${item.size} · ${item.flavor}',
                            style: const TextStyle(fontSize: 11, color: AdminTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(item.price),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
              )),
        ],
        const SizedBox(height: 14),
        if (order.status == 'CANCELLED' || OrderStatusFlow.isTerminal(order.status))
          _terminalHint(order.status)
        else if (!widget.compact) ...[
          Text('Order progress', style: AdminTheme.sectionTitle.copyWith(fontSize: 13)),
          const SizedBox(height: 10),
          AdminStatusPipeline(current: order.status),
          const SizedBox(height: 12),
          Text('Next action', style: AdminTheme.sectionTitle.copyWith(fontSize: 13)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: OrderStatusFlow.allowedNext(order.status).map((s) {
              final isCancel = s == 'CANCELLED';
              return ActionChip(
                label: Text(OrderStatusFlow.label(s)),
                backgroundColor: isCancel
                    ? const Color(0xFFDC2626).withValues(alpha: 0.08)
                    : AdminTheme.accent.withValues(alpha: 0.1),
                labelStyle: TextStyle(
                  color: isCancel ? const Color(0xFFDC2626) : AdminTheme.accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                onPressed: () => widget.onStatusChanged(s),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _statusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AdminTheme.radiusSm,
      ),
      child: Text(
        OrderStatusFlow.label(status),
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 11),
      ),
    );
  }

  Widget _terminalHint(String status) {
    final isCancel = status == 'CANCELLED';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isCancel ? const Color(0xFFDC2626) : AdminTheme.online).withValues(alpha: 0.08),
        borderRadius: AdminTheme.radiusSm,
      ),
      child: Text(
        OrderStatusFlow.hint(status),
        style: TextStyle(
          color: isCancel ? const Color(0xFFDC2626) : AdminTheme.online,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AdminTheme.textSecondary),
          const SizedBox(width: 10),
          SizedBox(
            width: 72,
            child: Text(label, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class AdminStatusPipeline extends StatelessWidget {
  final String current;
  const AdminStatusPipeline({super.key, required this.current});

  static const _steps = ['PENDING', 'CONFIRMED', 'BAKING', 'READY', 'DELIVERED'];

  @override
  Widget build(BuildContext context) {
    if (current == 'CANCELLED') return const SizedBox.shrink();
    final currentIndex = _steps.indexOf(current);
    return Row(
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final stepIndex = i ~/ 2;
          return Expanded(
            child: Container(
              height: 2,
              color: currentIndex > stepIndex ? AdminTheme.accent : AdminTheme.border,
            ),
          );
        }
        final stepIndex = i ~/ 2;
        final step = _steps[stepIndex];
        final isDone = currentIndex > stepIndex;
        final isCurrent = step == current;
        return Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isDone || isCurrent ? AdminTheme.accent : AdminTheme.border,
                shape: BoxShape.circle,
              ),
              child: isDone ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
            ),
            const SizedBox(height: 4),
            Text(
              OrderStatusFlow.label(step),
              style: TextStyle(
                fontSize: 7,
                color: isCurrent ? AdminTheme.accent : AdminTheme.textSecondary,
              ),
            ),
          ],
        );
      }),
    );
  }
}

void showAdminOrderSnackBar(BuildContext context, {required bool ok, required String message}) {
  if (ok) {
    AppSnackBar.success(context, message);
  } else {
    AppSnackBar.error(context, message);
  }
}
