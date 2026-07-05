import 'package:flutter/material.dart';
import '../models/cake.dart';
import '../services/api_service.dart';

enum CakeSortOption {
  recommended('Recommended'),
  topRated('Top rated'),
  priceLow('Price: Low to High'),
  priceHigh('Price: High to Low');

  const CakeSortOption(this.label);
  final String label;
}

class CakeProvider extends ChangeNotifier {
  final ApiService api;
  List<Cake> cakes = [];
  bool isLoading = false;
  String? error;
  String selectedCategory = 'ALL';
  String searchQuery = '';
  CakeSortOption sortOption = CakeSortOption.recommended;

  CakeProvider(this.api);

  List<Cake> get displayCakes {
    final list = List<Cake>.from(cakes);
    switch (sortOption) {
      case CakeSortOption.priceLow:
        list.sort((a, b) => a.basePrice.compareTo(b.basePrice));
      case CakeSortOption.priceHigh:
        list.sort((a, b) => b.basePrice.compareTo(a.basePrice));
      case CakeSortOption.topRated:
        list.sort((a, b) => b.rating.compareTo(a.rating));
      case CakeSortOption.recommended:
        list.sort((a, b) {
          final stock = (b.inStock ? 1 : 0) - (a.inStock ? 1 : 0);
          if (stock != 0) return stock;
          return b.rating.compareTo(a.rating);
        });
    }
    return list;
  }

  List<Cake> get bestsellers {
    final list = List<Cake>.from(cakes)..sort((a, b) => b.rating.compareTo(a.rating));
    return list.where((c) => c.inStock).take(8).toList();
  }

  Future<void> loadCakes() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      cakes = await api.getCakes(
        category: selectedCategory,
        search: searchQuery.isEmpty ? null : searchQuery,
      );
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    }
    isLoading = false;
    notifyListeners();
  }

  void setCategory(String category) {
    selectedCategory = category;
    loadCakes();
  }

  void setSearch(String query) {
    searchQuery = query;
    loadCakes();
  }

  void setSort(CakeSortOption option) {
    sortOption = option;
    notifyListeners();
  }
}
