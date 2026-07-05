import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'providers/admin_provider.dart';

import 'providers/auth_provider.dart';

import 'providers/cake_provider.dart';

import 'providers/cart_provider.dart';

import 'providers/delivery_address_provider.dart';

import 'providers/notification_provider.dart';

import 'providers/order_provider.dart';

import 'providers/promo_provider.dart';

import 'providers/wishlist_provider.dart';

import 'screens/app_bootstrap.dart';

import 'services/api_service.dart';
import 'services/notification_service.dart';
import 'services/server_settings_service.dart';

import 'theme/app_theme.dart';

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

        ChangeNotifierProvider(create: (_) => AuthProvider(apiService)),

        ChangeNotifierProvider(create: (_) => CakeProvider(apiService)),

        ChangeNotifierProvider(create: (_) => CartProvider(apiService)),

        ChangeNotifierProvider(create: (_) => DeliveryAddressProvider()..load()),

        ChangeNotifierProvider(create: (_) => OrderProvider(apiService)),

        ChangeNotifierProvider(create: (_) => PromoProvider()),

        ChangeNotifierProvider(create: (_) => WishlistProvider()..load()),

        ChangeNotifierProvider(create: (_) => AdminProvider(apiService)),

        ChangeNotifierProvider(create: (_) => NotificationProvider()..load()),

      ],

      child: OrderNotificationListener(

        child: MaterialApp(

          title: 'Cake Shop',

          debugShowCheckedModeBanner: false,

          theme: AppTheme.lightTheme,

          home: const AppBootstrap(),

        ),

      ),

    );

  }

}


