import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../theme/admin_theme.dart';
import '../../theme/app_theme.dart';
import '../../widgets/admin/admin_merchant_header.dart';
import 'admin_account_tab.dart';
import 'admin_customers_tab.dart';
import 'admin_dashboard_tab.dart';
import 'admin_orders_tab.dart';
import 'admin_promos_tab.dart';
import 'admin_products_tab.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _tab = 0;

  static const _titles = ['Overview', 'Orders', 'Menu', 'Offers', 'Customers', 'Account'];

  bool get _isAccountTab => _tab == 5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final admin = context.read<AdminProvider>();
      final notif = context.read<NotificationProvider>();
      if (!notif.isInitialized) await notif.load();
      await admin.refreshAll();
      if (!mounted) return;
      final orders = await admin.fetchOrdersForNotifications();
      if (!notif.adminOrdersSeeded) {
        await notif.seedAdminOrders(orders);
      } else {
        await notif.processAdminOrders(orders);
      }
    });
  }

  void _loadTab(int index) {
    setState(() => _tab = index);
    if (index == 1) {
      context.read<NotificationProvider>().clearAdminCount();
    }
    final admin = context.read<AdminProvider>();
    switch (index) {
      case 0:
        admin.loadDashboard();
      case 1:
        admin.loadAllOrders();
      case 2:
        admin.loadProducts();
      case 3:
        admin.loadPromos();
      case 4:
        admin.loadCustomers();
      case 5:
        admin.loadDashboard();
        context.read<AuthProvider>().refreshProfile();
    }
  }

  void _refreshCurrentTab() => _loadTab(_tab);

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final notif = context.watch<NotificationProvider>();
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final isLoggedIn = auth.isLoggedIn && user != null;
    final userInitial = isLoggedIn && user.name.trim().isNotEmpty
        ? user.name.trim()[0].toUpperCase()
        : 'A';
    final userFirstName = isLoggedIn && user.name.trim().isNotEmpty
        ? user.name.trim().split(' ').first
        : 'Account';

    final todayOrders = admin.dashboard?.todayOrders;
    final pendingOrders = admin.dashboard?.pendingOrders ?? 0;
    final adminAlertCount = notif.adminNotificationCount > 0
        ? notif.adminNotificationCount
        : pendingOrders;

    return Scaffold(
      backgroundColor: AdminTheme.scaffold,
      body: Column(
        children: [
          if (!_isAccountTab)
            AdminMerchantHeader(
              title: _titles[_tab],
              todayOrders: todayOrders,
              onRefresh: _refreshCurrentTab,
            ),
          Expanded(
            child: IndexedStack(
              index: _tab,
              children: [
                AdminDashboardTab(onNavigate: _loadTab),
                const AdminOrdersTab(),
                const AdminProductsTab(),
                const AdminPromosTab(),
                const AdminCustomersTab(),
                const AdminAccountTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.94),
                  Colors.white.withValues(alpha: 0.82),
                ],
              ),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.95),
                  width: 1.2,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2B1D19).withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Row(
                  children: [
                    _adminNavItem(
                      index: 0,
                      icon: Icons.grid_view_outlined,
                      activeIcon: Icons.grid_view_rounded,
                      label: 'Overview',
                    ),
                    _adminNavItem(
                      index: 1,
                      icon: Icons.receipt_long_outlined,
                      activeIcon: Icons.receipt_long_rounded,
                      label: 'Orders',
                      badgeCount: adminAlertCount,
                    ),
                    _adminNavItem(
                      index: 2,
                      icon: Icons.restaurant_menu_outlined,
                      activeIcon: Icons.restaurant_menu_rounded,
                      label: 'Menu',
                    ),
                    _adminNavItem(
                      index: 3,
                      icon: Icons.local_offer_outlined,
                      activeIcon: Icons.local_offer_rounded,
                      label: 'Offers',
                    ),
                    _adminNavItem(
                      index: 4,
                      icon: Icons.people_outline_rounded,
                      activeIcon: Icons.people_rounded,
                      label: 'Customers',
                    ),
                    _adminAccountNavItem(
                      index: 5,
                      isLoggedIn: isLoggedIn,
                      initial: userInitial,
                      label: isLoggedIn ? userFirstName : 'Account',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _adminNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    int? badgeCount,
  }) {
    final isSelected = _tab == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _loadTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isSelected
                ? AdminTheme.accent.withValues(alpha: 0.12)
                : Colors.transparent,
            border: isSelected
                ? Border.all(
                    color: AdminTheme.accent.withValues(alpha: 0.25),
                    width: 1,
                  )
                : Border.all(color: Colors.transparent),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  AnimatedScale(
                    scale: isSelected ? 1.08 : 1.0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      isSelected ? activeIcon : icon,
                      size: 21,
                      color: isSelected ? AdminTheme.accent : AdminTheme.textSecondary,
                    ),
                  ),
                  if (badgeCount != null && badgeCount > 0)
                    Positioned(
                      top: -4,
                      right: -7,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: AdminTheme.warning,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                        child: Text(
                          '$badgeCount',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AdminTheme.accent : AdminTheme.textSecondary,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _adminAccountNavItem({
    required int index,
    required bool isLoggedIn,
    required String initial,
    required String label,
  }) {
    final isSelected = _tab == index;

    Widget iconWidget;
    if (isLoggedIn) {
      iconWidget = Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isSelected ? AppTheme.ctaGradient : null,
          color: isSelected ? null : AdminTheme.accent.withValues(alpha: 0.16),
          border: Border.all(
            color: isSelected ? Colors.white : AdminTheme.accent.withValues(alpha: 0.45),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AdminTheme.accent.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          initial,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : AdminTheme.accent,
            height: 1.1,
          ),
        ),
      );
    } else {
      iconWidget = Icon(
        isSelected ? Icons.person_rounded : Icons.person_outline_rounded,
        size: 21,
        color: isSelected ? AdminTheme.accent : AdminTheme.textSecondary,
      );
    }

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _loadTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isSelected
                ? AdminTheme.accent.withValues(alpha: 0.12)
                : Colors.transparent,
            border: isSelected
                ? Border.all(
                    color: AdminTheme.accent.withValues(alpha: 0.25),
                    width: 1,
                  )
                : Border.all(color: Colors.transparent),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.08 : 1.0,
                duration: const Duration(milliseconds: 180),
                child: iconWidget,
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AdminTheme.accent : AdminTheme.textSecondary,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
