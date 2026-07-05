import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/admin_theme.dart';
import '../../widgets/admin/admin_merchant_header.dart';
import 'admin_account_tab.dart';
import 'admin_customers_tab.dart';
import 'admin_dashboard_tab.dart';
import 'admin_orders_tab.dart';
import 'admin_products_tab.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _tab = 0;

  static const _titles = ['Overview', 'Orders', 'Menu', 'Customers', 'Account'];

  bool get _isAccountTab => _tab == 4;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().refreshAll();
    });
  }

  void _loadTab(int index) {
    setState(() => _tab = index);
    final admin = context.read<AdminProvider>();
    switch (index) {
      case 0:
        admin.loadDashboard();
      case 1:
        admin.loadAllOrders();
      case 2:
        admin.loadProducts();
      case 3:
        admin.loadCustomers();
      case 4:
        admin.loadDashboard();
        context.read<AuthProvider>().refreshProfile();
    }
  }

  void _refreshCurrentTab() => _loadTab(_tab);

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final todayOrders = admin.dashboard?.todayOrders;

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
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.grid_view_rounded, size: 22),
                selectedIcon: Icon(Icons.grid_view_rounded, color: AdminTheme.accent, size: 22),
                label: 'Overview',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined, size: 22),
                selectedIcon: Icon(Icons.receipt_long_rounded, color: AdminTheme.accent, size: 22),
                label: 'Orders',
              ),
              NavigationDestination(
                icon: Icon(Icons.restaurant_menu_outlined, size: 22),
                selectedIcon: Icon(Icons.restaurant_menu_rounded, color: AdminTheme.accent, size: 22),
                label: 'Menu',
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
