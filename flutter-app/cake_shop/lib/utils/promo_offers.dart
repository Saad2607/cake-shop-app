import 'package:flutter/material.dart';

enum PromoAction { applyDiscount, showInfo, browseCategory }

class PromoOffer {
  final String id;
  final String title;
  final String subtitle;
  final List<Color> colors;
  final Color accent;
  final IconData icon;
  final PromoAction action;
  final String? code;
  final double? discountPercent;
  final double? minOrder;
  final String? category;
  final String? infoMessage;
  final String tapHint;

  const PromoOffer({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.accent,
    required this.icon,
    required this.action,
    required this.tapHint,
    this.code,
    this.discountPercent,
    this.minOrder,
    this.category,
    this.infoMessage,
  });
}

/// Promo banners on home — tap to apply code or browse cakes.
class PromoOffers {
  static const all = [
    PromoOffer(
      id: 'first_order',
      title: 'First order delight',
      subtitle: '50% off · Code SWEET50 · Min ₹999',
      colors: [Color(0xFF4A1530), Color(0xFF8B2D52)],
      accent: Color(0xFFC9A962),
      icon: Icons.local_offer_rounded,
      action: PromoAction.applyDiscount,
      code: 'SWEET50',
      discountPercent: 0.5,
      minOrder: 999,
      tapHint: 'Tap to apply SWEET50',
    ),
    PromoOffer(
      id: 'same_day',
      title: 'Same-day magic',
      subtitle: 'Order before 2 PM for evening delivery',
      colors: [Color(0xFF3D2B1F), Color(0xFF7A5C3E)],
      accent: Color(0xFFE8C98A),
      icon: Icons.delivery_dining_rounded,
      action: PromoAction.showInfo,
      infoMessage: 'Place your order before 2 PM for same-day delivery (2–4 hrs).',
      tapHint: 'Tap for delivery info',
    ),
    PromoOffer(
      id: 'custom_cakes',
      title: 'Custom photo cakes',
      subtitle: 'Turn memories into edible art',
      colors: [Color(0xFF5C1A3D), Color(0xFFB8365E)],
      accent: Color(0xFFF2C4D0),
      icon: Icons.camera_alt_rounded,
      action: PromoAction.browseCategory,
      category: 'CUSTOM',
      tapHint: 'Tap to browse custom cakes',
    ),
  ];

  static PromoOffer? byCode(String code) {
    final normalized = code.trim().toUpperCase();
    for (final offer in all) {
      if (offer.code?.toUpperCase() == normalized) return offer;
    }
    return null;
  }

  static PromoOffer? byId(String id) {
    for (final offer in all) {
      if (offer.id == id) return offer;
    }
    return null;
  }
}
