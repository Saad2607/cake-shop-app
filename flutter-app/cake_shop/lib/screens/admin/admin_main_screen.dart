import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../theme/admin_theme.dart';
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AdminTheme.surface,
          border: Border(top: BorderSide(color: AdminTheme.border)),
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: _loadTab,
            height: 64,
            backgroundColor: AdminTheme.surface,
            indicatorColor: AdminTheme.accent.withValues(alpha: 0.12),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.grid_view_rounded, size: 22),
                selectedIcon: Icon(Icons.grid_view_rounded, color: AdminTheme.accent, size: 22),
                label: 'Overview',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: adminAlertCount > 0,
                  label: Text('$adminAlertCount'),
                  backgroundColor: AdminTheme.warning,
                  child: const Icon(Icons.receipt_long_outlined, size: 22),
                ),
                selectedIcon: Badge(
                  isLabelVisible: adminAlertCount > 0,
                  label: Text('$adminAlertCount'),
                  backgroundColor: AdminTheme.warning,
                  child: const Icon(Icons.receipt_long_rounded, color: AdminTheme.accent, size: 22),
                ),
                label: 'Orders',
              ),
              NavigationDestination(
                icon: Icon(Icons.restaurant_menu_outlined, size: 22),
                selectedIcon: Icon(Icons.restaurant_menu_rounded, color: AdminTheme.accent, size: 22),
                label: 'Menu',
              ),
              NavigationDestination(
                icon: Icon(Icons.local_offer_outlined, size: 22),
                selectedIcon: Icon(Icons.local_offer_rounded, color: AdminTheme.accent, size: 22),
                label: 'Offers',
              ),
              NavigationDestination(
                icon: Icon(Icons.people_outline_rounded, size: 22),
                selectedIcon: Icon(Icons.people_rounded, color: AdminTheme.accent, size: 22),
                label: 'Customers',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded, size: 22),
                selectedIcon: Icon(Icons.person_rounded, color: AdminTheme.accent, size: 22),
                label: 'Account',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
