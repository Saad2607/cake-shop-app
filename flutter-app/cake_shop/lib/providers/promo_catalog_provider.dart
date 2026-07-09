import 'package:flutter/material.dart';
import '../models/promo_offer_model.dart';
import '../services/api_service.dart';
import '../utils/promo_offers.dart';

class PromoCatalogProvider extends ChangeNotifier {
  final ApiService api;

  List<PromoOfferModel> activePromos = [];
  bool isLoading = false;
  String? error;

  PromoCatalogProvider(this.api);

  Future<void> loadActivePromos() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final data = await api.getActivePromos();
      activePromos = data
          .map((e) => PromoOfferModel.fromJson(e as Map<String, dynamic>))
          .where((p) => !p.isExpired)
          .toList();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      activePromos = _fallbackPromos();
    }
    isLoading = false;
    notifyListeners();
  }

  PromoOfferModel? byCode(String code) {
    final normalized = code.trim().toUpperCase();
    for (final offer in activePromos) {
      if (offer.code?.toUpperCase() == normalized) return offer;
    }
    return null;
  }

  List<PromoOfferModel> _fallbackPromos() {
    return PromoOffers.all.map(_fromLegacy).toList();
  }

  static String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2)}';
  }

  PromoOfferModel _fromLegacy(PromoOffer offer) {
    return PromoOfferModel(
      id: offer.id,
      title: offer.title,
      subtitle: offer.subtitle,
      tapHint: offer.tapHint,
      action: switch (offer.action) {
        PromoAction.applyDiscount => PromoActionType.discount,
        PromoAction.browseCategory => PromoActionType.browseCategory,
        PromoAction.showInfo => PromoActionType.info,
      },
      code: offer.code,
      discountPercent: offer.discountPercent,
      minOrder: offer.minOrder,
      category: offer.category,
      infoMessage: offer.infoMessage,
      colorStart: _colorToHex(offer.colors.first),
      colorEnd: _colorToHex(offer.colors.last),
      accentColor: _colorToHex(offer.accent),
      icon: 'local_offer',
      expiresAt: offer.expiresAt?.millisecondsSinceEpoch,
    );
  }
}
