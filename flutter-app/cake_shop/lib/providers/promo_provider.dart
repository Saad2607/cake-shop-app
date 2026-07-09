import 'package:flutter/material.dart';
import '../models/promo_offer_model.dart';
import '../utils/currency_formatter.dart';
import 'promo_catalog_provider.dart';

class PromoProvider extends ChangeNotifier {
  final PromoCatalogProvider catalog;

  PromoOfferModel? _applied;

  PromoProvider(this.catalog);

  PromoOfferModel? get applied => _applied;
  String? get appliedCode => _applied?.code;
  bool get hasDiscount => _applied?.discountPercent != null;

  void apply(PromoOfferModel offer) {
    if (offer.action != PromoActionType.discount || offer.code == null) return;
    if (offer.isExpired) return;
    _applied = offer;
    notifyListeners();
  }

  bool applyCode(String code) {
    final offer = catalog.byCode(code);
    if (offer == null) return false;
    if (offer.isExpired) return false;
    apply(offer);
    return true;
  }

  void clear() {
    _applied = null;
    notifyListeners();
  }

  double discountAmount(double subtotal) {
    if (_applied == null || _applied!.discountPercent == null) return 0;
    final min = _applied!.minOrder;
    if (min != null && subtotal < min) return 0;
    final raw = subtotal * _applied!.discountPercent!;
    return (raw * 100).roundToDouble() / 100;
  }

  double payableTotal(double subtotal) {
    final total = subtotal - discountAmount(subtotal);
    return (total * 100).roundToDouble() / 100;
  }

  String? minOrderWarning(double subtotal) {
    if (_applied?.minOrder == null) return null;
    if (subtotal >= _applied!.minOrder!) return null;
    return 'Add ${CurrencyFormatter.format(_applied!.minOrder! - subtotal)} more to use ${_applied!.code}';
  }
}
