import 'package:flutter/material.dart';
import '../models/admin_customer.dart';
import '../models/admin_dashboard.dart';
import '../models/cake.dart';
import '../models/order.dart';
import '../services/api_service.dart';

class AdminProvider extends ChangeNotifier {
  final ApiService api;

  AdminDashboard? dashboard;
  List<Order> allOrders = [];
  List<Cake> products = [];
  List<AdminCustomer> customers = [];
  bool isLoading = false;
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
}
