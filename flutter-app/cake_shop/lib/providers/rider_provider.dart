import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/api_service.dart';

class RiderProvider extends ChangeNotifier {
  final ApiService api;

  List<Order> availablePickups = [];
  List<Order> activeDeliveries = [];
  List<Order> history = [];
  bool isLoading = false;
  String? error;
  bool isOnline = true;

  RiderProvider(this.api);

  void toggleDuty() {
    isOnline = !isOnline;
    notifyListeners();
  }

  Future<void> loadAvailablePickups() async {
    try {
      availablePickups = await api.getRiderAvailablePickups();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<void> loadActiveDeliveries() async {
    try {
      activeDeliveries = await api.getRiderActiveDeliveries();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<void> loadHistory() async {
    try {
      history = await api.getRiderDeliveryHistory();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<void> loadAll() async {
    isLoading = true;
    error = null;
    notifyListeners();

    await Future.wait([
      loadAvailablePickups(),
      loadActiveDeliveries(),
      loadHistory(),
    ]);

    isLoading = false;
    notifyListeners();
  }

  Future<bool> pickupOrder(String orderId) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await api.pickupOrderRider(orderId);
      await loadAll();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeDelivery(String orderId, {String? otp}) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await api.completeDeliveryRider(orderId, otp: otp);
      await loadAll();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
