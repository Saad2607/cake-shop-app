import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/order_provider.dart';
import '../screens/admin/admin_main_screen.dart';
import '../screens/home/main_screen.dart';
import '../services/notification_service.dart';

/// Central navigation after auth events.
class NavigationHelper {
  static Future<void> afterCustomerAuth(BuildContext context, {bool welcome = true}) async {
    await NotificationService.instance.requestPermission();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => MainScreen(initialTab: 0, showWelcome: welcome),
      ),
      (_) => false,
    );
  }

  static void afterAdminAuth(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AdminMainScreen()),
      (_) => false,
    );
  }

  static Future<void> afterAuth(
    BuildContext context,
    AuthProvider auth, {
    bool welcome = true,
  }) async {
    if (auth.user?.role == 'ADMIN') {
      afterAdminAuth(context);
      return;
    }

    await NotificationService.instance.requestPermission();
    if (!context.mounted) return;
    await context.read<OrderProvider>().loadOrders();
    if (!context.mounted) return;
    final orders = context.read<OrderProvider>().orders;
    final notifications = context.read<NotificationProvider>();
    if (notifications.hasSnapshots) {
      await notifications.processOrders(orders);
    } else {
      await notifications.seedStatuses(orders);
    }
    if (!context.mounted) return;
    await afterCustomerAuth(context, welcome: welcome);
  }
}
