import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Saved delivery location shown on home (like Swiggy's "Deliver to").
class DeliveryAddressProvider extends ChangeNotifier {
  static const _labelKey = 'delivery_label';
  static const _addressKey = 'delivery_address';

  String _label = 'Add delivery address';
  String _fullAddress = '';
  bool _loaded = false;

  String get label => _label;
  String get fullAddress => _fullAddress;
  bool get hasAddress => _fullAddress.trim().isNotEmpty;
  bool get loaded => _loaded;

  /// Short line for hero header, e.g. "Home · Andheri West"
  String get displayLine {
    if (!hasAddress) return 'Tap to set location';
    if (_label.isNotEmpty && _label != _fullAddress) return _label;
    final parts = _fullAddress.split(',');
    if (parts.length >= 2) {
      return '${parts.first.trim()} · ${parts[1].trim()}';
    }
    return _fullAddress.length > 32 ? '${_fullAddress.substring(0, 32)}...' : _fullAddress;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _label = prefs.getString(_labelKey) ?? 'Add delivery address';
    _fullAddress = prefs.getString(_addressKey) ?? '';
    _loaded = true;
    notifyListeners();
  }

  Future<void> setAddress({
    required String label,
    required String fullAddress,
  }) async {
    _label = label.trim().isEmpty ? 'Delivery address' : label.trim();
    _fullAddress = fullAddress.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_labelKey, _label);
    await prefs.setString(_addressKey, _fullAddress);
    notifyListeners();
  }

  Future<void> clear() async {
    _label = 'Add delivery address';
    _fullAddress = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_labelKey);
    await prefs.remove(_addressKey);
    notifyListeners();
  }
}
