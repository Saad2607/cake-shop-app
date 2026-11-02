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
import '../../widgets/floating_checkout_bar.dart';
import '../../widgets/glass/glass_bottom_navigation_bar.dart';

import 'home_tab.dart';
import '../catalog/catalog_tab.dart';
import '../cart/cart_tab.dart';
import '../cart/checkout_screen.dart';
import '../orders/orders_tab.dart';
import '../profile/profile_tab.dart';
import '../profile/wishlist_screen.dart';

class MainScreen extends StatefulWidget {
  static const int tabHome = 0;
  static const int tabCategories = 1;
  static const int tabWishlist = 2;
  static const int tabCart = 3;
  static const int tabProfile = 4;
  static const int tabOrders = 5;

  final int initialTab;
  final bool showWelcome;

  const MainScreen({
    super.key,
    this.initialTab = 0,
    this.showWelcome = false,
  });

  const MainScreen.home({super.key})
      : initialTab = tabHome,
        showWelcome = false;

  const MainScreen.categories({super.key})
      : initialTab = 101,
        showWelcome = false;

  const MainScreen.wishlist({super.key})
      : initialTab = 102,
        showWelcome = false;

  const MainScreen.cart({super.key})
      : initialTab = tabCart,
        showWelcome = false;

  const MainScreen.profile({super.key})
      : initialTab = tabProfile,
        showWelcome = false;

  const MainScreen.orders({super.key})
      : initialTab = tabOrders,
        showWelcome = false;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _index;

  static int _resolveIndex(int tab) {
    if (tab == 101) return MainScreen.tabCategories;
    if (tab == 102) return MainScreen.tabWishlist;
    // Legacy mapping:
    if (tab == 1) return MainScreen.tabCart; // legacy 1 was Cart
    if (tab == 2) return MainScreen.tabOrders; // legacy 2 was Orders
    return tab;
  }

  @override
  void initState() {
    super.initState();
    _index = _resolveIndex(widget.initialTab);

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
    if (i == MainScreen.tabOrders && !context.read<AuthProvider>().isLoggedIn) {
      final ok = await AuthGuard.requireLogin(context);
      if (!ok || !mounted) return;
      context.read<OrderProvider>().loadOrders();
    }

    setState(() => _index = i);

    if (i == MainScreen.tabCart) {
      context.read<CartProvider>().loadCart();
    } else if (i == MainScreen.tabOrders) {
      context.read<OrderProvider>().loadOrders();
    }
  }

  void _handleSwitch(int i) {
    if (i == 2) {
      // Legacy switch to orders or wishlist
      _onTabSelected(MainScreen.tabOrders);
    } else if (i == 1) {
      _onTabSelected(MainScreen.tabCart);
    } else {
      _onTabSelected(i);
    }
  }

  Future<void> _handleCheckout() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      final ok = await AuthGuard.requireLogin(context);
      if (!ok || !mounted) return;
    }
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final isLoggedIn = auth.isLoggedIn && user != null;
    final userInitial = isLoggedIn && user.name.trim().isNotEmpty
        ? user.name.trim()[0].toUpperCase()
        : 'U';
    final accountLabel = isLoggedIn && user.name.trim().isNotEmpty
        ? user.name.trim().split(' ').first
        : 'Account';

    final showCartBar = cart.itemCount > 0 && _index != MainScreen.tabCart;
    final navIndex = _index < 5 ? _index : MainScreen.tabProfile;

    final profileNavItem = isLoggedIn
        ? GlassNavItem.avatar(
            initial: userInitial,
            label: accountLabel,
          )
        : const GlassNavItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: 'Account',
          );

    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (_index == MainScreen.tabOrders) {
            setState(() => _index = MainScreen.tabProfile);
          } else {
            setState(() => _index = 0);
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        extendBody: true,
        body: IndexedStack(
          index: _index,
          children: [
            HomeTab(onSwitchTab: _handleSwitch),
            const CatalogTab(),
            WishlistScreen(
              isTab: true,
              onBrowseMenu: () => setState(() => _index = MainScreen.tabCategories),
            ),
            CartTab(onBrowseCakes: () => setState(() => _index = MainScreen.tabHome)),
            ProfileTab(onSwitchTab: _handleSwitch),
            OrdersTab(
              showBack: true,
              onBack: () => setState(() => _index = MainScreen.tabProfile),
            ),
          ],
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showCartBar)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: FloatingCartBar(
                  itemCount: cart.itemCount,
                  total: cart.total,
                  totalLabel: CurrencyFormatter.format(cart.total),
                  onTap: () => setState(() => _index = MainScreen.tabCart),
                ),
              ),
            if (_index == MainScreen.tabCart && cart.items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: FloatingCheckoutBar(
                  itemCount: cart.itemCount,
                  total: cart.total,
                  totalLabel: CurrencyFormatter.format(cart.total),
                  onCheckout: _handleCheckout,
                ),
              ),
            GlassBottomNavigationBar(
              selectedIndex: navIndex,
              onItemSelected: _onTabSelected,
              items: [
                const GlassNavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                ),
                const GlassNavItem(
                  icon: Icons.grid_view_outlined,
                  activeIcon: Icons.grid_view_rounded,
                  label: 'Menu',
                ),
                const GlassNavItem(
                  icon: Icons.favorite_outline_rounded,
                  activeIcon: Icons.favorite_rounded,
                  label: 'Saved',
                ),
                GlassNavItem(
                  icon: Icons.shopping_bag_outlined,
                  activeIcon: Icons.shopping_bag_rounded,
                  label: 'Cart',
                  badgeCount: cart.itemCount > 0 ? cart.itemCount : null,
                ),
                profileNavItem,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
