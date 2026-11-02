import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/celebration.dart';

class CelebrationProvider extends ChangeNotifier {
  static const _storageKey = 'sweet_delights_celebrations_v1';
  List<Celebration> _celebrations = [];
  bool _isLoaded = false;

  List<Celebration> get celebrations => List.unmodifiable(_celebrations);

  List<Celebration> get upcomingCelebrations {
    final list = List<Celebration>.from(_celebrations);
    list.sort((a, b) => a.daysUntilNext.compareTo(b.daysUntilNext));
    return list;
  }

  bool get isLoaded => _isLoaded;

  CelebrationProvider() {
    loadCelebrations();
  }

  Future<void> loadCelebrations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(raw);
        _celebrations = decoded.map((e) => Celebration.fromJson(e)).toList();
      } else {
        // Seed default sample celebrations if empty
        _celebrations = [
          Celebration(
            id: 'sample-1',
            personName: 'Mom ❤️',
            occasionType: 'Birthday',
            date: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 5),
            cakePreference: 'French Vanilla Bean',
          ),
          Celebration(
            id: 'sample-2',
            personName: 'Wedding Anniversary 💍',
            occasionType: 'Anniversary',
            date: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 18),
            cakePreference: 'Romantic Heart Red Velvet',
          ),
        ];
        _save();
      }
    } catch (_) {
      _celebrations = [];
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> addCelebration(Celebration celebration) async {
    _celebrations.add(celebration);
    notifyListeners();
    await _save();
  }

  Future<void> removeCelebration(String id) async {
    _celebrations.removeWhere((c) => c.id == id);
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_celebrations.map((c) => c.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
