import 'package:flutter/material.dart';
import '../models/admin_customer.dart';
import '../models/admin_dashboard.dart';
import '../models/cake.dart';
import '../models/order.dart';
import '../models/promo_offer_model.dart';
import '../services/api_service.dart';

class AdminProvider extends ChangeNotifier {
  final ApiService api;

  AdminDashboard? dashboard;
  List<Order> allOrders = [];
  List<Cake> products = [];
  List<AdminCustomer> customers = [];
  List<PromoOfferModel> promos = [];
  bool isLoading = false;
  bool promosLoading = false;
  String? error;
  String orderStatusFilter = 'ALL';
  String orderSearch = '';

  AdminProvider(this.api);

  Future<void> loadDashboard() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      dashboard = await api.getAdminDashboard();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> loadAllOrders({String? status, String? search}) async {
    if (status != null) orderStatusFilter = status;
    if (search != null) orderSearch = search;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      allOrders = await api.getAllOrdersAdmin(
        status: orderStatusFilter,
        search: orderSearch.isEmpty ? null : orderSearch,
      );
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      allOrders = [];
    }
    isLoading = false;
    notifyListeners();
  }

  /// Unfiltered fetch used only for new-order notification detection.
  Future<List<Order>> fetchOrdersForNotifications() async {
    try {
      return await api.getAllOrdersAdmin();
    } catch (_) {
      return List<Order>.from(allOrders);
    }
  }

  Future<void> loadProducts() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      products = await api.getCakesAdmin();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      products = [];
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> loadCustomers() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      customers = await api.getAdminCustomers();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      customers = [];
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> refreshAll() async {
    await Future.wait([
      loadDashboard(),
      loadAllOrders(),
      loadProducts(),
      loadCustomers(),
      loadPromos(),
    ]);
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      await api.updateOrderStatus(orderId, status);
      await loadAllOrders();
      await loadDashboard();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> createProduct(Map<String, dynamic> data) async {
    try {
      await api.createCakeAdmin(data);
      await loadProducts();
      await loadDashboard();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      await api.updateCakeAdmin(id, data);
      await loadProducts();
      await loadDashboard();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      await api.deleteCakeAdmin(id);
      await loadProducts();
      await loadDashboard();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleStock(Cake cake) async {
    return updateProduct(cake.id, {'inStock': !cake.inStock});
  }

  Future<void> loadPromos() async {
    promosLoading = true;
    error = null;
    notifyListeners();
    try {
      final data = await api.getAllPromosAdmin();
      promos = data
          .map((e) => PromoOfferModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      promos = [];
    }
    promosLoading = false;
    notifyListeners();
  }

  Future<bool> createPromo(Map<String, dynamic> data) async {
    try {
      await api.createPromoAdmin(data);
      await loadPromos();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePromo(String id, Map<String, dynamic> data) async {
    try {
      await api.updatePromoAdmin(id, data);
      await loadPromos();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePromo(String id) async {
    try {
      await api.deletePromoAdmin(id);
      await loadPromos();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
