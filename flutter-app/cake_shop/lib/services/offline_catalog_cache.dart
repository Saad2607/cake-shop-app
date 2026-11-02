import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cake.dart';

class OfflineCatalogCache {
  static const _cakesCacheKey = 'sweet_delights_cached_cakes_v1';
  static const _promosCacheKey = 'sweet_delights_cached_promos_v1';

  static Future<void> saveCakes(List<Cake> cakes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = cakes.map((c) => c.toJson()).toList();
      await prefs.setString(_cakesCacheKey, jsonEncode(list));
    } catch (_) {}
  }

  static Future<List<Cake>> loadCachedCakes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cakesCacheKey);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> list = jsonDecode(raw);
        return list.map((item) => Cake.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<void> savePromos(List<dynamic> promosJson) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_promosCacheKey, jsonEncode(promosJson));
    } catch (_) {}
  }

  static Future<List<dynamic>> loadCachedPromos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_promosCacheKey);
      if (raw != null && raw.isNotEmpty) {
        return jsonDecode(raw) as List<dynamic>;
      }
    } catch (_) {}
    return [];
  }
}
