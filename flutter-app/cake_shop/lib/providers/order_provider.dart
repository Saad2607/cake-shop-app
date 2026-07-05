import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/api_service.dart';

class OrderProvider extends ChangeNotifier {
  final ApiService api;
  List<Order> orders = [];
  bool isLoading = false;

  OrderProvider(this.api);

  Future<void> loadOrders() async {
    isLoading = true;
    notifyListeners();
    try {
      orders = await api.getOrders();
    } catch (_) {
      orders = [];
    }
    isLoading = false;
    notifyListeners();
  }

  Future<Order?> placeOrder({
    required String deliveryAddress,
    required int deliveryDate,
    required String paymentMethod,
    String? promoCode,
  }) async {
    try {
      final order = await api.placeOrder(
        deliveryAddress: deliveryAddress,
        deliveryDate: deliveryDate,
        paymentMethod: paymentMethod,
        promoCode: promoCode,
      );
      await loadOrders();
      return order;
    } catch (_) {
      return null;
    }
  }

  Future<bool> cancelOrder(String id) async {
    try {
      await api.cancelOrder(id);
      await loadOrders();
      return true;
    } catch (_) {
      return false;
    }
  }
}
