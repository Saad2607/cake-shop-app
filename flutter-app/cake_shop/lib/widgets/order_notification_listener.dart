import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/order_provider.dart';

/// Polls orders while logged in and triggers local push alerts for customers and admins.
class OrderNotificationListener extends StatefulWidget {
  final Widget child;

  const OrderNotificationListener({super.key, required this.child});

  @override
  State<OrderNotificationListener> createState() =>
      _OrderNotificationListenerState();
}

class _OrderNotificationListenerState extends State<OrderNotificationListener>
    with WidgetsBindingObserver {
  Timer? _timer;
  AuthProvider? _auth;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _auth = context.read<AuthProvider>();
      _auth!.addListener(_handleAuth);
      _handleAuth();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _auth?.removeListener(_handleAuth);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _poll();
    }
  }

  void _handleAuth() {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      _timer?.cancel();
      return;
    }

    _poll();
    _timer?.cancel();
    final interval = auth.user?.role == 'ADMIN'
        ? const Duration(seconds: 15)
        : const Duration(seconds: 30);
    _timer = Timer.periodic(interval, (_) => _poll());
  }

  Future<void> _poll() async {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) return;

    final notifications = context.read<NotificationProvider>();
    if (!notifications.isInitialized) {
      await notifications.load();
    }
    if (!notifications.enabled) return;

    if (auth.user?.role == 'ADMIN') {
      final admin = context.read<AdminProvider>();
      final orders = await admin.fetchOrdersForNotifications();
      if (!mounted) return;

      if (!notifications.adminOrdersSeeded) {
        await notifications.seedAdminOrders(orders);
      } else {
        await notifications.processAdminOrders(orders);
      }
      return;
    }

    final orders = context.read<OrderProvider>();
    await orders.loadOrders();
    if (!mounted) return;

    if (notifications.hasSnapshots) {
      await notifications.processOrders(orders.orders);
    } else {
      await notifications.seedStatuses(orders.orders);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
