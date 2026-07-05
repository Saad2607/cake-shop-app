import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WishlistProvider extends ChangeNotifier {
  static const _key = 'wishlist_cake_ids';
  final Set<String> _ids = {};

  Set<String> get ids => Set.unmodifiable(_ids);

  bool isFavorite(String cakeId) => _ids.contains(cakeId);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _ids
      ..clear()
      ..addAll(prefs.getStringList(_key) ?? const []);
    notifyListeners();
  }

  Future<void> toggle(String cakeId) async {
    if (_ids.contains(cakeId)) {
      _ids.remove(cakeId);
    } else {
      _ids.add(cakeId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _ids.toList());
    notifyListeners();
  }
}
