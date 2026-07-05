import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/order_provider.dart';

/// Polls order status while the customer is logged in and triggers local push alerts.
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
      _pollOrders();
    }
  }

  void _handleAuth() {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn || auth.user?.role == 'ADMIN') {
      _timer?.cancel();
      return;
    }

    _pollOrders();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _pollOrders());
  }

  Future<void> _pollOrders() async {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn || auth.user?.role == 'ADMIN') return;

    final orders = context.read<OrderProvider>();
    final notifications = context.read<NotificationProvider>();
    if (!notifications.enabled) return;

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
