import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/admin_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cake_provider.dart';
import 'providers/celebration_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/delivery_address_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/order_provider.dart';
import 'providers/promo_catalog_provider.dart';
import 'providers/promo_provider.dart';
import 'providers/rider_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/wishlist_provider.dart';

import 'constants/app_branding.dart';
import 'screens/app_bootstrap.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';
import 'services/server_settings_service.dart';
import 'theme/app_theme.dart';
import 'widgets/deep_link_handler.dart';
import 'widgets/order_notification_listener.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();

  final serverSettings = ServerSettingsService();
  await serverSettings.load();
  final apiService = ApiService(serverSettings: serverSettings);

  runApp(CakeShopApp(
    apiService: apiService,
    serverSettings: serverSettings,
  ));
}

class CakeShopApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final ApiService apiService;
  final ServerSettingsService serverSettings;

  const CakeShopApp({
    super.key,
    required this.apiService,
    required this.serverSettings,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        ChangeNotifierProvider<ServerSettingsService>.value(
          value: serverSettings,
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider(apiService)),
        ChangeNotifierProvider(create: (_) => CakeProvider(apiService)),
        ChangeNotifierProvider(create: (_) => CartProvider(apiService)),
        ChangeNotifierProvider(create: (_) => DeliveryAddressProvider()..load()),
        ChangeNotifierProvider(create: (_) => OrderProvider(apiService)),
        ChangeNotifierProvider(
          create: (_) => PromoCatalogProvider(apiService)..loadActivePromos(),
        ),
        ChangeNotifierProxyProvider<PromoCatalogProvider, PromoProvider>(
          create: (ctx) => PromoProvider(ctx.read<PromoCatalogProvider>()),
          update: (_, catalog, promo) => promo ?? PromoProvider(catalog),
        ),
        ChangeNotifierProvider(create: (_) => WishlistProvider()..load()),
        ChangeNotifierProvider(create: (_) => CelebrationProvider()..loadCelebrations()),
        ChangeNotifierProvider(create: (_) => AdminProvider(apiService)),
        ChangeNotifierProvider(create: (_) => RiderProvider(apiService)),
        ChangeNotifierProvider(create: (_) => NotificationProvider()..load()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return OrderNotificationListener(
            child: MaterialApp(
              navigatorKey: navigatorKey,
              title: kAppName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeProvider.themeMode,
              themeAnimationDuration: Duration.zero,
              home: const AppBootstrap(),
              builder: (context, child) {
                return DeepLinkHandler(
                  navigatorKey: navigatorKey,
                  child: child ?? const SizedBox.shrink(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
