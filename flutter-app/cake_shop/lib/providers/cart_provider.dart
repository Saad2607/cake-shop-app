import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../services/api_service.dart';

class CartProvider extends ChangeNotifier {
  final ApiService api;
  List<CartItem> _serverItems = [];
  List<CartItem> _guestItems = [];
  double total = 0;
  bool isLoading = false;
  int _guestId = 0;

  CartProvider(this.api);

  List<CartItem> get items => api.isLoggedIn ? _serverItems : _guestItems;

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  void _calcTotal() {
    total = items.fold(0.0, (sum, i) => sum + i.lineTotal);
  }

  Future<void> loadCart() async {
    if (!api.isLoggedIn) {
      _calcTotal();
      notifyListeners();
      return;
    }
    isLoading = true;
    notifyListeners();
    try {
      final response = await api.getCart();
      _serverItems = response.items;
      total = response.total;
    } catch (_) {
      _serverItems = [];
      total = 0;
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> addItem({
    required String cakeId,
    required String cakeName,
    required int quantity,
    required String selectedSize,
    required String selectedFlavor,
    String? customMessage,
    required double unitPrice,
  }) async {
    if (!api.isLoggedIn) {
      _guestItems.add(CartItem(
        id: 'guest_${_guestId++}',
        cakeId: cakeId,
        cakeName: cakeName,
        quantity: quantity,
        selectedSize: selectedSize,
        selectedFlavor: selectedFlavor,
        customMessage: customMessage,
        unitPrice: unitPrice,
      ));
      _calcTotal();
      notifyListeners();
      return;
    }

    await api.addToCart(
      cakeId: cakeId,
      quantity: quantity,
      selectedSize: selectedSize,
      selectedFlavor: selectedFlavor,
      customMessage: customMessage,
      unitPrice: unitPrice,
    );
    await loadCart();
  }

  Future<void> syncGuestCartAfterLogin() async {
    if (_guestItems.isEmpty || !api.isLoggedIn) return;
    final pending = List<CartItem>.from(_guestItems);
    _guestItems.clear();
    for (final item in pending) {
      await api.addToCart(
        cakeId: item.cakeId,
        quantity: item.quantity,
        selectedSize: item.selectedSize,
        selectedFlavor: item.selectedFlavor,
        customMessage: item.customMessage,
        unitPrice: item.unitPrice,
      );
    }
    await loadCart();
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    if (!api.isLoggedIn) {
      final idx = _guestItems.indexWhere((i) => i.id == itemId);
      if (idx >= 0) {
        if (quantity <= 0) {
          _guestItems.removeAt(idx);
        } else {
          final old = _guestItems[idx];
          _guestItems[idx] = CartItem(
            id: old.id,
            cakeId: old.cakeId,
            cakeName: old.cakeName,
            quantity: quantity,
            selectedSize: old.selectedSize,
            selectedFlavor: old.selectedFlavor,
            customMessage: old.customMessage,
            unitPrice: old.unitPrice,
          );
        }
        _calcTotal();
        notifyListeners();
      }
      return;
    }
    await api.updateCartQuantity(itemId, quantity);
    await loadCart();
  }

  Future<void> removeItem(String itemId) async {
    if (!api.isLoggedIn) {
      _guestItems.removeWhere((i) => i.id == itemId);
      _calcTotal();
      notifyListeners();
      return;
    }
    await api.removeCartItem(itemId);
    await loadCart();
  }

  void clearGuestCart() {
    _guestItems.clear();
    total = 0;
    notifyListeners();
  }
}
