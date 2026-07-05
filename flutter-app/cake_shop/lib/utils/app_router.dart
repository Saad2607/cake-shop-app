import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import '../screens/admin/admin_main_screen.dart';
import '../screens/home/main_screen.dart';

/// Routes user to customer app or admin panel based on role.
/// Guests always land on the customer dashboard.
class AppRouter {
  static Widget homeFor(AuthProvider auth) {
    if (auth.isLoggedIn && auth.user?.role == 'ADMIN') {
      return const AdminMainScreen();
    }
    return const MainScreen();
  }
}
