import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

import '../../providers/cart_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/order_provider.dart';

import '../../theme/app_theme.dart';

import '../../utils/app_snackbar.dart';

import '../../utils/auth_guard.dart';

import '../../utils/currency_formatter.dart';

import '../../widgets/floating_cart_bar.dart';

import 'home_tab.dart';

import '../cart/cart_tab.dart';

import '../orders/orders_tab.dart';

import '../profile/profile_tab.dart';



class MainScreen extends StatefulWidget {

  final int initialTab;

  final bool showWelcome;



  const MainScreen({

    super.key,

    this.initialTab = 0,

    this.showWelcome = false,

  });



  @override

  State<MainScreen> createState() => _MainScreenState();

}



class _MainScreenState extends State<MainScreen> {

  late int _index;



  @override

  void initState() {

    super.initState();

    _index = widget.initialTab;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<CartProvider>().loadCart();
      final auth = context.read<AuthProvider>();
      if (auth.isLoggedIn && auth.user?.role != 'ADMIN') {
        final orders = context.read<OrderProvider>();
        final notifications = context.read<NotificationProvider>();
        await orders.loadOrders();
        if (!mounted) return;
        if (notifications.hasSnapshots) {
          await notifications.processOrders(orders.orders);
        } else {
          await notifications.seedStatuses(orders.orders);
        }
      }
      if (!mounted) return;
      if (widget.showWelcome) {
        final name = auth.user?.name;
        AppSnackBar.success(
          context,
          name != null && name.isNotEmpty ? 'Welcome back, $name!' : 'Welcome back!',
        );
      }

    });

  }



  Future<void> _onTabSelected(int i) async {

    if (i == 2 && !context.read<AuthProvider>().isLoggedIn) {

      final ok = await AuthGuard.requireLogin(context);

      if (!ok || !mounted) return;

      context.read<OrderProvider>().loadOrders();

    }

    setState(() => _index = i);

    if (i == 1) context.read<CartProvider>().loadCart();

    if (i == 2) context.read<OrderProvider>().loadOrders();

  }



  @override

  Widget build(BuildContext context) {

    final cart = context.watch<CartProvider>();

    final showCartBar = cart.itemCount > 0 && _index != 1;



    return Scaffold(

      backgroundColor: AppTheme.background,

      body: IndexedStack(

        index: _index,

        children: [

          HomeTab(onSwitchTab: (i) => setState(() => _index = i)),

          CartTab(onBrowseCakes: () => setState(() => _index = 0)),

          const OrdersTab(),

          ProfileTab(onSwitchTab: (i) => setState(() => _index = i)),

        ],

      ),

      bottomNavigationBar: Column(

        mainAxisSize: MainAxisSize.min,

        children: [

          if (showCartBar)

            Padding(

              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),

              child: FloatingCartBar(

                itemCount: cart.itemCount,

                total: cart.total,

                totalLabel: CurrencyFormatter.format(cart.total),

                onTap: () => setState(() => _index = 1),

              ),

            ),

          Container(

            decoration: BoxDecoration(

              color: AppTheme.surface,

              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),

              boxShadow: [

                BoxShadow(

                  color: AppTheme.primaryDark.withValues(alpha: 0.06),

                  blurRadius: 20,

                  offset: const Offset(0, -4),

                ),

              ],

            ),

            child: SafeArea(

              top: false,

              child: NavigationBar(

                height: 70,

                backgroundColor: Colors.transparent,

                indicatorColor: AppTheme.primary.withValues(alpha: 0.1),

                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

                selectedIndex: _index,

                onDestinationSelected: _onTabSelected,

                destinations: [

                  NavigationDestination(

                    icon: Icon(Icons.home_outlined, color: AppTheme.textMuted),

                    selectedIcon: const Icon(Icons.home_rounded, color: AppTheme.primary),

                    label: 'Home',

                  ),

                  NavigationDestination(

                    icon: Badge(

                      isLabelVisible: cart.itemCount > 0,

                      backgroundColor: AppTheme.primary,

                      label: Text(

                        '${cart.itemCount}',

                        style: const TextStyle(fontSize: 10),

                      ),

                      child: Icon(Icons.shopping_bag_outlined, color: AppTheme.textMuted),

                    ),

                    selectedIcon: const Icon(Icons.shopping_bag_rounded, color: AppTheme.primary),

                    label: 'Cart',

                  ),

                  NavigationDestination(

                    icon: Icon(Icons.receipt_long_outlined, color: AppTheme.textMuted),

                    selectedIcon: const Icon(Icons.receipt_long_rounded, color: AppTheme.primary),

                    label: 'Orders',

                  ),

                  NavigationDestination(

                    icon: Icon(Icons.person_outline_rounded, color: AppTheme.textMuted),

                    selectedIcon: const Icon(Icons.person_rounded, color: AppTheme.primary),

                    label: 'Account',

                  ),

                ],

              ),

            ),

          ),

        ],

      ),

    );

  }

}


