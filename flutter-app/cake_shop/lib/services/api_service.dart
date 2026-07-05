import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/admin_customer.dart';
import 'server_settings_service.dart';
import '../models/admin_dashboard.dart';
import '../models/cake.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/user.dart';

class ApiService {
  static const _tokenKey = 'auth_token';
  static const _timeout = Duration(seconds: 15);

  final ServerSettingsService serverSettings;
  String? _token;

  ApiService({required this.serverSettings});

  String get _baseUrl => serverSettings.baseUrl;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<http.Response> _request(Future<http.Response> future) async {
    try {
      return await future.timeout(_timeout);
    } on TimeoutException {
      throw Exception(
        'Connection timed out.\n'
        '• Backend running? npm run dev\n'
        '• Account → Server connection → update your PC IP\n'
        '• USB? Run: adb reverse tcp:3000 tcp:3000',
      );
    } on http.ClientException {
      throw Exception(
        'Cannot reach $_baseUrl\n'
        'Account → Server connection → set PC IP or USB mode',
      );
    }
  }

  Future<bool> testConnection() async {
    try {
      final response = await http
          .get(Uri.parse(serverSettings.healthUrl))
          .timeout(const Duration(seconds: 8));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    Map<String, dynamic> body = {};
    if (response.body.isNotEmpty) {
      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) body = decoded;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    throw Exception(body['error'] ?? 'Request failed (${response.statusCode})');
  }

  Future<List<dynamic>> _handleListResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = json.decode(response.body);
      if (decoded is List) return decoded;
    }
    Map<String, dynamic> body = {};
    if (response.body.isNotEmpty) {
      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) body = decoded;
    }
    throw Exception(body['error'] ?? 'Request failed (${response.statusCode})');
  }

  // Auth
  Future<User> login(String email, String password) async {
    final response = await _request(http.post(
      Uri.parse('${_baseUrl}/auth/login'),
      headers: _headers,
      body: json.encode({'email': email, 'password': password}),
    ));
    final data = await _handleResponse(response);
    await saveToken(data['token'] as String);
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> register(
      String name, String email, String phone, String password) async {
    final response = await _request(http.post(
      Uri.parse('${_baseUrl}/auth/register'),
      headers: _headers,
      body: json.encode({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      }),
    ));
    await _handleResponse(response);
  }

  Future<User> getProfile() async {
    final response = await _request(http.get(
      Uri.parse('${_baseUrl}/auth/profile'),
      headers: _headers,
    ));
    final data = await _handleResponse(response);
    return User.fromJson(data);
  }

  Future<void> updateProfile(String name, String phone) async {
    final response = await _request(http.put(
      Uri.parse('${_baseUrl}/auth/profile'),
      headers: _headers,
      body: json.encode({'name': name, 'phone': phone}),
    ));
    await _handleResponse(response);
  }

  // Cakes
  Future<List<Cake>> getCakes({String? category, String? search}) async {
    final params = <String, String>{};
    if (category != null && category != 'ALL') params['category'] = category;
    if (search != null && search.isNotEmpty) params['search'] = search;

    final uri = Uri.parse('${_baseUrl}/cakes')
        .replace(queryParameters: params.isEmpty ? null : params);
    final response = await _request(http.get(uri, headers: _headers));
    final data = await _handleListResponse(response);
    return data.map((e) => Cake.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Cake> getCakeById(String id) async {
    final response = await _request(http.get(
      Uri.parse('${_baseUrl}/cakes/$id'),
      headers: _headers,
    ));
    final data = await _handleResponse(response);
    return Cake.fromJson(data);
  }

  // Cart
  Future<CartResponse> getCart() async {
    final response = await _request(http.get(
      Uri.parse('${_baseUrl}/cart'),
      headers: _headers,
    ));
    final data = await _handleResponse(response);
    return CartResponse.fromJson(data);
  }

  Future<void> addToCart({
    required String cakeId,
    required int quantity,
    required String selectedSize,
    required String selectedFlavor,
    String? customMessage,
    required double unitPrice,
  }) async {
    final response = await _request(http.post(
      Uri.parse('${_baseUrl}/cart'),
      headers: _headers,
      body: json.encode({
        'cakeId': cakeId,
        'quantity': quantity,
        'selectedSize': selectedSize,
        'selectedFlavor': selectedFlavor,
        'customMessage': customMessage,
        'unitPrice': unitPrice,
      }),
    ));
    await _handleResponse(response);
  }

  Future<void> updateCartQuantity(String itemId, int quantity) async {
    final response = await _request(http.put(
      Uri.parse('${_baseUrl}/cart/$itemId'),
      headers: _headers,
      body: json.encode({'quantity': quantity}),
    ));
    await _handleResponse(response);
  }

  Future<void> removeCartItem(String itemId) async {
    final response = await _request(http.delete(
      Uri.parse('${_baseUrl}/cart/$itemId'),
      headers: _headers,
    ));
    await _handleResponse(response);
  }

  // Orders
  Future<Order> placeOrder({
    required String deliveryAddress,
    required int deliveryDate,
    required String paymentMethod,
    String? promoCode,
  }) async {
    final response = await _request(http.post(
      Uri.parse('${_baseUrl}/orders'),
      headers: _headers,
      body: json.encode({
        'deliveryAddress': deliveryAddress,
        'deliveryDate': deliveryDate,
        'paymentMethod': paymentMethod,
        if (promoCode != null && promoCode.isNotEmpty) 'promoCode': promoCode,
      }),
    ));
    final data = await _handleResponse(response);
    return Order.fromJson(data);
  }

  Future<List<Order>> getOrders() async {
    final response = await _request(http.get(
      Uri.parse('${_baseUrl}/orders'),
      headers: _headers,
    ));
    final data = await _handleListResponse(response);
    return data.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Order> getOrderById(String id) async {
    final response = await _request(http.get(
      Uri.parse('${_baseUrl}/orders/$id'),
      headers: _headers,
    ));
    final data = await _handleResponse(response);
    return Order.fromJson(data);
  }

  Future<void> cancelOrder(String id) async {
    final response = await _request(http.patch(
      Uri.parse('${_baseUrl}/orders/$id/cancel'),
      headers: _headers,
    ));
    await _handleResponse(response);
  }

  // Admin
  Future<AdminDashboard> getAdminDashboard() async {
    final response = await _request(http.get(
      Uri.parse('${_baseUrl}/admin/dashboard'),
      headers: _headers,
    ));
    final data = await _handleResponse(response);
    return AdminDashboard.fromJson(data);
  }

  Future<List<AdminCustomer>> getAdminCustomers() async {
    final response = await _request(http.get(
      Uri.parse('${_baseUrl}/admin/customers'),
      headers: _headers,
    ));
    final data = await _handleListResponse(response);
    return data.map((e) => AdminCustomer.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Order>> getAllOrdersAdmin({String? status, String? search}) async {
    final params = <String, String>{};
    if (status != null && status != 'ALL') params['status'] = status;
    if (search != null && search.isNotEmpty) params['search'] = search;
    final uri = Uri.parse('${_baseUrl}/admin/orders')
        .replace(queryParameters: params.isEmpty ? null : params);
    final response = await _request(http.get(uri, headers: _headers));
    final data = await _handleListResponse(response);
    return data.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    final response = await _request(http.patch(
      Uri.parse('${_baseUrl}/admin/orders/$orderId/status'),
      headers: _headers,
      body: json.encode({'status': status}),
    ));
    await _handleResponse(response);
  }

  Future<List<Cake>> getCakesAdmin() async {
    final response = await _request(http.get(
      Uri.parse('${_baseUrl}/cakes'),
      headers: _headers,
    ));
    final data = await _handleListResponse(response);
    return data.map((e) => Cake.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Cake> createCakeAdmin(Map<String, dynamic> body) async {
    final response = await _request(http.post(
      Uri.parse('${_baseUrl}/cakes'),
      headers: _headers,
      body: json.encode(body),
    ));
    final data = await _handleResponse(response);
    return Cake.fromJson(data);
  }

  Future<Cake> updateCakeAdmin(String id, Map<String, dynamic> body) async {
    final response = await _request(http.put(
      Uri.parse('${_baseUrl}/cakes/$id'),
      headers: _headers,
      body: json.encode(body),
    ));
    final data = await _handleResponse(response);
    return Cake.fromJson(data);
  }

  Future<void> deleteCakeAdmin(String id) async {
    final response = await _request(http.delete(
      Uri.parse('${_baseUrl}/cakes/$id'),
      headers: _headers,
    ));
    await _handleResponse(response);
  }
}
