import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/order_status.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _channel = AndroidNotificationDetails(
    'order_updates',
    'Order Updates',
    channelDescription: 'Alerts when your cake order status changes',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@drawable/ic_launcher',
  );

  Future<void> init() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    await requestPermission();
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);

    return granted ?? true;
  }

  Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) await init();
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(android: _channel, iOS: DarwinNotificationDetails()),
    );
  }

  Future<void> showOrderPlaced(String orderNumber) async {
    await show(
      id: orderNumber.hashCode,
      title: 'Order placed! 🎂',
      body: 'Order $orderNumber received. We\'ll notify you at every step.',
    );
  }

  Future<void> showStatusChange(String orderNumber, String newStatus) async {
    final id = '$orderNumber-$newStatus'.hashCode;
    await show(
      id: id,
      title: _titleForStatus(newStatus),
      body: 'Order $orderNumber · ${OrderStatusFlow.label(newStatus)}',
    );
  }

  String _titleForStatus(String status) {
    switch (status) {
      case 'CONFIRMED':
        return 'Order confirmed ✓';
      case 'BAKING':
        return 'Your cake is baking! 🔥';
      case 'READY':
        return 'Cake is ready! 🎂';
      case 'DELIVERED':
        return 'Delivered — enjoy! 🎉';
      case 'CANCELLED':
        return 'Order cancelled';
      default:
        return 'Order update';
    }
  }
}
