import 'package:flutter/material.dart';
import '../utils/currency_formatter.dart';
import '../utils/promo_offers.dart';

class PromoProvider extends ChangeNotifier {
  PromoOffer? _applied;

  PromoOffer? get applied => _applied;
  String? get appliedCode => _applied?.code;
  bool get hasDiscount => _applied?.discountPercent != null;

  void apply(PromoOffer offer) {
    if (offer.action != PromoAction.applyDiscount || offer.code == null) return;
    _applied = offer;
    notifyListeners();
  }

  bool applyCode(String code) {
    final offer = PromoOffers.byCode(code);
    if (offer == null) return false;
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
    return subtotal * _applied!.discountPercent!;
  }

  double payableTotal(double subtotal) => subtotal - discountAmount(subtotal);

  String? minOrderWarning(double subtotal) {
    if (_applied?.minOrder == null) return null;
    if (subtotal >= _applied!.minOrder!) return null;
    return 'Add ${CurrencyFormatter.format(_applied!.minOrder! - subtotal)} more to use ${_applied!.code}';
  }
}
