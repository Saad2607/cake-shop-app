import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  static const _enabledKey = 'notifications_enabled';
  static const _statusesKey = 'order_status_snapshot';

  bool _enabled = true;
  bool _initialized = false;
  Map<String, String> _lastStatuses = {};

  bool get enabled => _enabled;
  bool get isInitialized => _initialized;
  bool get hasSnapshots => _lastStatuses.isNotEmpty;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_enabledKey) ?? true;
    final raw = prefs.getString(_statusesKey);
    if (raw != null) {
      _lastStatuses = Map<String, String>.from(jsonDecode(raw) as Map);
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
      } else if (prev == null && hasSnapshots && order.status != 'PENDING') {
        // Order progressed while we were offline (e.g. admin updated status).
        await NotificationService.instance.showStatusChange(
          order.orderNumber,
          order.status,
        );
      }
      _lastStatuses[order.id] = order.status;
    }

    await _persist();
  }

  /// First-time setup only — records statuses without notifying.
  Future<void> seedStatuses(List<Order> orders) async {
    for (final order in orders) {
      _lastStatuses[order.id] = order.status;
    }
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statusesKey, jsonEncode(_lastStatuses));
  }

  void recordOrder(String orderId, String status) {
    _lastStatuses[orderId] = status;
    _persist();
  }
}
