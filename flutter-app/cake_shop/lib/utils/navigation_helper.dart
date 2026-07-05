import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import '../screens/admin/admin_main_screen.dart';
import '../screens/home/main_screen.dart';
import '../services/notification_service.dart';

/// Central navigation after auth events.
class NavigationHelper {
  static void afterCustomerAuth(BuildContext context, {bool welcome = true}) async {
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

  static void afterAuth(BuildContext context, AuthProvider auth,
      {bool welcome = true}) {
    if (auth.user?.role == 'ADMIN') {
      afterAdminAuth(context);
    } else {
      afterCustomerAuth(context, welcome: welcome);
    }
  }
}
