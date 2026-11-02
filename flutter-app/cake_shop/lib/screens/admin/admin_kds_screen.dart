import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../providers/admin_provider.dart';
import '../../services/invoice_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/currency_formatter.dart';

class AdminKdsScreen extends StatefulWidget {
  const AdminKdsScreen({super.key});

  @override
  State<AdminKdsScreen> createState() => _AdminKdsScreenState();
}

class _AdminKdsScreenState extends State<AdminKdsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // 4 Kitchen tabs: Queue, Baking, Ready, Dispatched (Rider handover)
    _tabController = TabController(length: 4, vsync: this);
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadAllOrders(status: 'ALL', search: '');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  String _getElapsedMinutes(int epochMs) {
    final diff = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(epochMs));
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else {
      return '${diff.inHours}h ${diff.inMinutes % 60}m ago';
    }
  }

  Color _getTimerUrgencyColor(int epochMs) {
    final diff = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(epochMs));
    if (diff.inMinutes < 20) {
      return const Color(0xFF2E7D32); // Green: Fresh
    } else if (diff.inMinutes < 40) {
      return const Color(0xFFEF6C00); // Amber: Warning
    } else {
      return const Color(0xFFC62828); // Red: Urgent
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final allOrders = admin.allOrders;

    final newOrders = allOrders
        .where((o) => o.status == 'PENDING' || o.status == 'CONFIRMED')
        .toList();
    final bakingOrders = allOrders.where((o) => o.status == 'BAKING').toList();
    final readyOrders = allOrders.where((o) => o.status == 'READY').toList();
    final dispatchedOrders = allOrders.where((o) => o.status == 'OUT_FOR_DELIVERY').toList();

    return Scaffold(
      backgroundColor: const Color(0xFF1B1615), // Professional dark kitchen display background
      appBar: AppBar(
        backgroundColor: const Color(0xFF261D1A),
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFE6B980).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.soup_kitchen_rounded, color: Color(0xFFE6B980), size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Kitchen Display',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    '${bakingOrders.length} baking · ${newOrders.length} queue · ${dispatchedOrders.length} out',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Color(0xFFD6C7C2)),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFFE6B980)),
            tooltip: 'Refresh queue',
            onPressed: () => admin.loadAllOrders(status: 'ALL', search: ''),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFE6B980),
          indicatorWeight: 3,
          labelColor: const Color(0xFFE6B980),
          labelPadding: const EdgeInsets.symmetric(horizontal: 2),
          unselectedLabelColor: const Color(0xFF9E8E89),
          tabs: [
            Tab(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Queue', style: TextStyle(fontSize: 11.5)),
                    const SizedBox(width: 3),
                    _countBadge(newOrders.length, const Color(0xFFEF6C00)),
                  ],
                ),
              ),
            ),
            Tab(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Baking', style: TextStyle(fontSize: 11.5)),
                    const SizedBox(width: 3),
                    _countBadge(bakingOrders.length, AppTheme.accent),
                  ],
                ),
              ),
            ),
            Tab(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Ready', style: TextStyle(fontSize: 11.5)),
                    const SizedBox(width: 3),
                    _countBadge(readyOrders.length, const Color(0xFF2E7D32)),
                  ],
                ),
              ),
            ),
            Tab(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Dispatch', style: TextStyle(fontSize: 11.5)),
                    const SizedBox(width: 3),
                    _countBadge(dispatchedOrders.length, const Color(0xFF0288D1)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: admin.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE6B980)))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(context, admin, newOrders, 'No new pending orders in kitchen queue'),
                _buildOrderList(context, admin, bakingOrders, 'No cakes currently in oven / baking'),
                _buildOrderList(context, admin, readyOrders, 'No orders currently packed and ready'),
                _buildOrderList(context, admin, dispatchedOrders, 'No orders currently out with delivery riders'),
              ],
            ),
    );
  }

  Widget _countBadge(int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOrderList(
    BuildContext context,
    AdminProvider admin,
    List<Order> orders,
    String emptyMessage,
  ) {
    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.done_all_rounded, size: 54, color: Color(0xFF5D4E4A)),
              const SizedBox(height: 14),
              const Text(
                'Queue Cleared',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
              const SizedBox(height: 6),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF9E8E89), fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFFE6B980),
      backgroundColor: const Color(0xFF261D1A),
      onRefresh: () => admin.loadAllOrders(status: 'ALL', search: ''),
      child: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: orders.length,
        itemBuilder: (ctx, i) => _buildKdsCard(context, admin, orders[i]),
      ),
    );
  }

  Widget _buildKdsCard(BuildContext context, AdminProvider admin, Order order) {
    final urgencyColor = _getTimerUrgencyColor(order.createdAt);
    final elapsedStr = _getElapsedMinutes(order.createdAt);
    final createdFormat = DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(order.createdAt));

    // Extract any custom cake messages from items
    final customMessages = (order.items ?? [])
        .where((it) => it.customMessage != null && it.customMessage!.trim().isNotEmpty)
        .map((it) => (it.cakeName, it.customMessage!.trim()))
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF271F1C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: urgencyColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF332824),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Order #${order.orderNumber}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        createdFormat,
                        style: const TextStyle(fontSize: 11, color: Color(0xFFB5A49F)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                // Urgency Elapsed Timer
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: urgencyColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: urgencyColor.withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer_outlined, size: 12, color: urgencyColor),
                      const SizedBox(width: 3),
                      Text(
                        elapsedStr,
                        style: TextStyle(
                          color: urgencyColor,
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Items Details
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (order.items != null)
                  ...order.items!.map(
                    (it) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6B980).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${it.quantity}x',
                              style: const TextStyle(
                                color: Color(0xFFE6B980),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  it.cakeName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Size: ${it.size} · Flavor: ${it.flavor}',
                                  style: const TextStyle(fontSize: 11.5, color: Color(0xFFD6C7C2)),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(it.price),
                            style: const TextStyle(
                              color: Color(0xFFE6B980),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // HIGHLIGHTED CUSTOM CAKE MESSAGE CALLOUT (Critical for bakers!)
                if (customMessages.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3E1F29),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE25574), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.brush_rounded, size: 14, color: Color(0xFFFF8DA1)),
                            SizedBox(width: 6),
                            Text(
                              'CHEF PIPING & CUSTOM MESSAGE:',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF8DA1),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ...customMessages.map(
                          (msg) => Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              '✍️ "${msg.$2}"',
                              style: const TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // DELIVERY PARTNER DETAILS & OTP (Visible when assigned or out for delivery)
                if (order.deliveryPartnerName != null && order.deliveryPartnerName!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0288D1).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF0288D1).withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.delivery_dining_rounded, size: 20, color: Color(0xFF29B6F6)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ASSIGNED DELIVERY PARTNER',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: Color(0xFF81D4FA),
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                '${order.deliveryPartnerName}${order.deliveryPartnerPhone != null && order.deliveryPartnerPhone!.isNotEmpty ? ' · ${order.deliveryPartnerPhone}' : ''}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (order.deliveryOtp != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32).withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF81C784)),
                            ),
                            child: Column(
                              children: [
                                const Text('OTP PIN', style: TextStyle(color: Color(0xFF81C784), fontSize: 8, fontWeight: FontWeight.bold)),
                                Text(
                                  order.deliveryOtp!,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 10),
                // Customer destination note
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF9E8E89)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        order.deliveryAddress,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF9E8E89)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Action Buttons Row
                Row(
                  children: [
                    // Thermal Ticket Print Button
                    Flexible(
                      flex: 4,
                      child: OutlinedButton.icon(
                        onPressed: () => InvoiceService.printOrDownloadInvoice(order),
                        icon: const Icon(Icons.receipt_long_rounded, size: 14),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('Ticket', style: TextStyle(fontSize: 12)),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFE6B980),
                          side: const BorderSide(color: Color(0xFF5D4E4A)),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Primary Status Advance Button
                    Flexible(
                      flex: 6,
                      child: _buildAdvanceButton(context, admin, order),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvanceButton(BuildContext context, AdminProvider admin, Order order) {
    if (order.status == 'PENDING' || order.status == 'CONFIRMED') {
      return ElevatedButton.icon(
        onPressed: () async {
          final ok = await admin.updateOrderStatus(order.id, 'BAKING');
          if (!context.mounted) return;
          if (ok) {
            AppSnackBar.success(context, 'Order #${order.orderNumber} moved to Baking!');
          } else {
            AppSnackBar.error(context, admin.error ?? 'Failed to update order status');
          }
        },
        icon: const Icon(Icons.outdoor_grill_rounded, size: 15),
        label: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('Start Baking', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC2185B),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else if (order.status == 'BAKING') {
      return ElevatedButton.icon(
        onPressed: () async {
          final ok = await admin.updateOrderStatus(order.id, 'READY');
          if (!context.mounted) return;
          if (ok) {
            AppSnackBar.success(context, 'Cake baked & marked Ready!');
          } else {
            AppSnackBar.error(context, admin.error ?? 'Failed to update order status');
          }
        },
        icon: const Icon(Icons.check_circle_outline_rounded, size: 15),
        label: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('Mark Ready', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else if (order.status == 'READY') {
      return ElevatedButton.icon(
        onPressed: () async {
          final ok = await admin.updateOrderStatus(order.id, 'OUT_FOR_DELIVERY');
          if (!context.mounted) return;
          if (ok) {
            AppSnackBar.success(context, 'Order handed to Delivery Partner!');
            _tabController.animateTo(3); // Smoothly transition to Dispatch tab!
          } else {
            AppSnackBar.error(context, admin.error ?? 'Failed to update order status');
          }
        },
        icon: const Icon(Icons.delivery_dining_rounded, size: 16),
        label: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('Hand to Rider', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1565C0),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else if (order.status == 'OUT_FOR_DELIVERY') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0288D1).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF0288D1).withValues(alpha: 0.5)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_bike_rounded, size: 16, color: Color(0xFF29B6F6)),
            SizedBox(width: 6),
            Text(
              'Out for Delivery',
              style: TextStyle(color: Color(0xFF29B6F6), fontSize: 11.5, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
