import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  static const _enabledKey = 'notifications_enabled';
  static const _statusesKey = 'order_status_snapshot';
  static const _customerCountKey = 'notification_count_customer';
  static const _adminCountKey = 'notification_count_admin';
  static const _adminOrdersKey = 'admin_known_order_ids';

  bool _enabled = true;
  bool _initialized = false;
  Map<String, String> _lastStatuses = {};
  int _customerNotificationCount = 0;
  int _adminNotificationCount = 0;
  Set<String> _knownAdminOrderIds = {};
  bool _adminOrdersSeeded = false;

  bool get enabled => _enabled;
  bool get isInitialized => _initialized;
  bool get hasSnapshots => _lastStatuses.isNotEmpty;
  bool get adminOrdersSeeded => _adminOrdersSeeded;
  int get customerNotificationCount => _customerNotificationCount;
  int get adminNotificationCount => _adminNotificationCount;

  int countForRole(String? role) =>
      role == 'ADMIN' ? _adminNotificationCount : _customerNotificationCount;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_enabledKey) ?? true;
    _customerNotificationCount = prefs.getInt(_customerCountKey) ?? 0;
    _adminNotificationCount = prefs.getInt(_adminCountKey) ?? 0;

    final raw = prefs.getString(_statusesKey);
    if (raw != null) {
      _lastStatuses = Map<String, String>.from(jsonDecode(raw) as Map);
    }

    final adminRaw = prefs.getString(_adminOrdersKey);
    if (adminRaw != null) {
      final list = jsonDecode(adminRaw) as List<dynamic>;
      _knownAdminOrderIds = list.map((e) => e.toString()).toSet();
      _adminOrdersSeeded = _knownAdminOrderIds.isNotEmpty;
    }

    _initialized = true;
    notifyListeners();
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);
    if (value) {
      await NotificationService.instance.requestPermission();
    }
    notifyListeners();
  }

  Future<void> incrementCustomerCount() async {
    _customerNotificationCount++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_customerCountKey, _customerNotificationCount);
    notifyListeners();
  }

  Future<void> incrementAdminCount() async {
    _adminNotificationCount++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_adminCountKey, _adminNotificationCount);
    notifyListeners();
  }

  Future<void> clearCustomerCount() async {
    _customerNotificationCount = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_customerCountKey, 0);
    notifyListeners();
  }

  Future<void> clearAdminCount() async {
    _adminNotificationCount = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_adminCountKey, 0);
    notifyListeners();
  }

  /// Compare fetched orders with last snapshot; fire notifications on changes.
  Future<void> processOrders(List<Order> orders) async {
    if (!_enabled) return;

    for (final order in orders) {
      final prev = _lastStatuses[order.id];
      if (prev != null && prev != order.status) {
        await NotificationService.instance.showStatusChange(
          order.orderNumber,
          order.status,
        );
        await incrementCustomerCount();
      } else if (prev == null && hasSnapshots && order.status != 'PENDING') {
        await NotificationService.instance.showStatusChange(
          order.orderNumber,
          order.status,
        );
        await incrementCustomerCount();
      }
      _lastStatuses[order.id] = order.status;
    }

    await _persist();
  }

  /// Notify admin when a new order arrives.
  Future<void> processAdminOrders(List<Order> orders) async {
    if (!_enabled) return;

    for (final order in orders) {
      final isNew = !_knownAdminOrderIds.contains(order.id);
      if (isNew) {
        if (_adminOrdersSeeded && order.status == 'PENDING') {
          await NotificationService.instance.showNewAdminOrder(
            order.orderNumber,
            order.customerName ?? 'Customer',
          );
          await incrementAdminCount();
        }
        _knownAdminOrderIds.add(order.id);
      }
    }

    if (!_adminOrdersSeeded && orders.isNotEmpty) {
      _adminOrdersSeeded = true;
    }

    await _persistAdminOrders();
  }

  /// First-time setup only — records statuses without notifying.
  Future<void> seedStatuses(List<Order> orders) async {
    for (final order in orders) {
      _lastStatuses[order.id] = order.status;
    }
    await _persist();
  }

  Future<void> seedAdminOrders(List<Order> orders) async {
    for (final order in orders) {
      _knownAdminOrderIds.add(order.id);
    }
    _adminOrdersSeeded = true;
    await _persistAdminOrders();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statusesKey, jsonEncode(_lastStatuses));
  }

  Future<void> _persistAdminOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _adminOrdersKey,
      jsonEncode(_knownAdminOrderIds.toList()),
    );
  }

  void recordOrder(String orderId, String status) {
    _lastStatuses[orderId] = status;
    _persist();
  }
}
