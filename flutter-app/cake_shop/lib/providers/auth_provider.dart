import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService api;
  User? user;
  bool isLoading = false;
  String? error;

  AuthProvider(this.api);

  bool get isLoggedIn => api.isLoggedIn && user != null;

  Future<void> init() async {
    await api.loadToken();
    if (api.isLoggedIn) {
      try {
        user = await api.getProfile();
        notifyListeners();
      } catch (_) {
        await api.clearToken();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      user = await api.login(email, password);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
      String name, String email, String phone, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await api.register(name, email, phone, password);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> forgotPassword(String email, String newPassword) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await api.forgotPassword(email, newPassword);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await api.clearToken();
    user = null;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    user = await api.getProfile();
    notifyListeners();
  }

  Future<void> updateProfile(String name, String phone) async {
    await api.updateProfile(name, phone);
    await refreshProfile();
  }
}
