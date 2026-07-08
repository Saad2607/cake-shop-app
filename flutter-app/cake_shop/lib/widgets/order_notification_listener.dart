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
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _poll());
  }

  Future<void> _poll() async {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) return;

    final notifications = context.read<NotificationProvider>();
    if (!notifications.enabled) return;

    if (auth.user?.role == 'ADMIN') {
      final admin = context.read<AdminProvider>();
      await admin.loadAllOrders();
      if (!mounted) return;

      if (!notifications.adminOrdersSeeded) {
        await notifications.seedAdminOrders(admin.allOrders);
      } else {
        await notifications.processAdminOrders(admin.allOrders);
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
