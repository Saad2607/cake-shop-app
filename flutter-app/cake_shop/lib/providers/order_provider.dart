import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/api_service.dart';

class OrderProvider extends ChangeNotifier {
  final ApiService api;
  List<Order> orders = [];
  bool isLoading = false;
  String? lastError;

  OrderProvider(this.api);

  Future<void> loadOrders() async {
    isLoading = true;
    lastError = null;
    notifyListeners();
    try {
      orders = await api.getOrders();
    } catch (e) {
      orders = [];
      lastError = e.toString().replaceFirst('Exception: ', '');
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
    lastError = null;
    try {
      final order = await api.placeOrder(
        deliveryAddress: deliveryAddress,
        deliveryDate: deliveryDate,
        paymentMethod: paymentMethod,
        promoCode: promoCode,
      );
      await loadOrders();
      return order;
    } catch (e) {
      lastError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  Future<bool> cancelOrder(String id) async {
    lastError = null;
    try {
      await api.cancelOrder(id);
      await loadOrders();
      return true;
    } catch (e) {
      lastError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<Order?> submitReview(String id, int rating, {String? comment}) async {
    lastError = null;
    try {
      final updated = await api.submitOrderReview(id, rating, comment: comment);
      await loadOrders();
      return updated;
    } catch (e) {
      lastError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }
}
