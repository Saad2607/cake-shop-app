import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/saved_address.dart';

/// Multiple saved delivery addresses (Home / Office / Other).
class DeliveryAddressProvider extends ChangeNotifier {
  static const _listKey = 'delivery_addresses_v2';
  static const _selectedKey = 'delivery_selected_id';
  static const _legacyLabelKey = 'delivery_label';
  static const _legacyAddressKey = 'delivery_address';

  List<SavedAddress> _addresses = [];
  String? _selectedId;
  bool _loaded = false;

  List<SavedAddress> get addresses => List.unmodifiable(_addresses);
  bool get loaded => _loaded;
  bool get hasAddress => selected != null;

  SavedAddress? get selected {
    if (_selectedId == null) return null;
    for (final a in _addresses) {
      if (a.id == _selectedId) return a;
    }
    return _addresses.isNotEmpty ? _addresses.first : null;
  }

  String get label => selected?.label ?? 'Add delivery address';
  String get fullAddress => selected?.fullAddress ?? '';

  String get displayLine {
    final current = selected;
    if (current == null) return 'Tap to set location';
    if (current.label.isNotEmpty) {
      final parts = current.fullAddress.split(',');
      final area = parts.length >= 2 ? parts[1].trim() : parts.first.trim();
      return '${current.label} · $area';
    }
    return current.fullAddress.length > 32
        ? '${current.fullAddress.substring(0, 32)}...'
        : current.fullAddress;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_listKey);

    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      _addresses = list
          .map((e) => SavedAddress.fromJson(e as Map<String, dynamic>))
          .toList();
      _selectedId = prefs.getString(_selectedKey);
    } else {
      await _migrateLegacy(prefs);
    }

    if (_addresses.isNotEmpty &&
        (_selectedId == null || !_addresses.any((a) => a.id == _selectedId))) {
      _selectedId = _addresses.first.id;
    }

    _loaded = true;
    notifyListeners();
  }

  Future<void> _migrateLegacy(SharedPreferences prefs) async {
    final legacyAddress = prefs.getString(_legacyAddressKey) ?? '';
    if (legacyAddress.trim().isEmpty) return;

    final legacyLabel = prefs.getString(_legacyLabelKey) ?? 'Home';
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _addresses = [
      SavedAddress(
        id: id,
        label: legacyLabel,
        fullAddress: legacyAddress.trim(),
      ),
    ];
    _selectedId = id;
    await _persist(prefs);
  }

  Future<void> saveAddress({
    required String label,
    required String fullAddress,
    String? id,
  }) async {
    final normalizedLabel =
        label.trim().isEmpty ? 'Home' : label.trim();
    final address = fullAddress.trim();
    if (address.isEmpty) return;

    final existingId = id;
    if (existingId != null) {
      _addresses = _addresses
          .map(
            (a) => a.id == existingId
                ? SavedAddress(
                    id: a.id,
                    label: normalizedLabel,
                    fullAddress: address,
                  )
                : a,
          )
          .toList();
      _selectedId = existingId;
    } else {
      final newId = DateTime.now().millisecondsSinceEpoch.toString();
      _addresses = [
        ..._addresses,
        SavedAddress(id: newId, label: normalizedLabel, fullAddress: address),
      ];
      _selectedId = newId;
    }

    final prefs = await SharedPreferences.getInstance();
    await _persist(prefs);
    notifyListeners();
  }

  Future<void> selectAddress(String id) async {
    if (!_addresses.any((a) => a.id == id)) return;
    _selectedId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedKey, id);
    notifyListeners();
  }

  Future<void> deleteAddress(String id) async {
    _addresses = _addresses.where((a) => a.id != id).toList();
    if (_selectedId == id) {
      _selectedId = _addresses.isNotEmpty ? _addresses.first.id : null;
    }
    final prefs = await SharedPreferences.getInstance();
    await _persist(prefs);
    notifyListeners();
  }

  Future<void> setAddress({
    required String label,
    required String fullAddress,
  }) async {
    await saveAddress(label: label, fullAddress: fullAddress);
  }

  Future<void> clear() async {
    _addresses = [];
    _selectedId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_listKey);
    await prefs.remove(_selectedKey);
    notifyListeners();
  }

  Future<void> _persist(SharedPreferences prefs) async {
    await prefs.setString(
      _listKey,
      jsonEncode(_addresses.map((a) => a.toJson()).toList()),
    );
    if (_selectedId != null) {
      await prefs.setString(_selectedKey, _selectedId!);
    } else {
      await prefs.remove(_selectedKey);
    }
  }
}
