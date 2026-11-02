import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import '../screens/admin/admin_main_screen.dart';
import '../screens/home/main_screen.dart';
import '../screens/rider/rider_main_screen.dart';

/// Routes user to customer app, rider portal, or admin panel based on role.
/// Guests always land on the customer dashboard.
class AppRouter {
  static Widget homeFor(AuthProvider auth) {
    if (auth.isLoggedIn) {
      if (auth.user?.role == 'ADMIN') {
        return const AdminMainScreen();
      }
      if (auth.user?.role == 'RIDER') {
        return const RiderMainScreen();
      }
    }
    return const MainScreen();
  }
}
