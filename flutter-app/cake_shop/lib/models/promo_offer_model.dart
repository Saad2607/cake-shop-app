import 'package:flutter/material.dart';

enum PromoActionType { discount, info, browseCategory }

class PromoOfferModel {
  final String id;
  final String title;
  final String subtitle;
  final String tapHint;
  final PromoActionType action;
  final String? code;
  final double? discountPercent;
  final double? minOrder;
  final String? category;
  final String? infoMessage;
  final String colorStart;
  final String colorEnd;
  final String accentColor;
  final String icon;
  final int? expiresAt;
  final bool active;
  final int sortOrder;
  final int useCount;
  final double totalDiscount;

  const PromoOfferModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.tapHint,
    required this.action,
    this.code,
    this.discountPercent,
    this.minOrder,
    this.category,
    this.infoMessage,
    required this.colorStart,
    required this.colorEnd,
    required this.accentColor,
    required this.icon,
    this.expiresAt,
    this.active = true,
    this.sortOrder = 0,
    this.useCount = 0,
    this.totalDiscount = 0,
  });

  factory PromoOfferModel.fromJson(Map<String, dynamic> json) {
    return PromoOfferModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      tapHint: json['tapHint'] as String? ?? 'Tap for details',
      action: _actionFromApi(json['action'] as String),
      code: json['code'] as String?,
      discountPercent: (json['discountPercent'] as num?)?.toDouble(),
      minOrder: (json['minOrder'] as num?)?.toDouble(),
      category: json['category'] as String?,
      infoMessage: json['infoMessage'] as String?,
      colorStart: json['colorStart'] as String? ?? '#4A1530',
      colorEnd: json['colorEnd'] as String? ?? '#8B2D52',
      accentColor: json['accentColor'] as String? ?? '#C9A962',
      icon: json['icon'] as String? ?? 'local_offer',
      expiresAt: json['expiresAt'] as int?,
      active: json['active'] as bool? ?? true,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      useCount: (json['useCount'] as num?)?.toInt() ?? 0,
      totalDiscount: (json['totalDiscount'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'subtitle': subtitle,
        'tapHint': tapHint,
        'action': actionToApi(action),
        if (code != null && code!.isNotEmpty) 'code': code,
        if (discountPercent != null) 'discountPercent': discountPercent,
        if (minOrder != null) 'minOrder': minOrder,
        if (category != null) 'category': category,
        if (infoMessage != null) 'infoMessage': infoMessage,
        'colorStart': colorStart,
        'colorEnd': colorEnd,
        'accentColor': accentColor,
        'icon': icon,
        if (expiresAt != null) 'expiresAt': expiresAt,
        'active': active,
        'sortOrder': sortOrder,
      };

  DateTime? get expiresAtDate =>
      expiresAt != null ? DateTime.fromMillisecondsSinceEpoch(expiresAt!) : null;

  List<Color> get gradientColors => [_hex(colorStart), _hex(colorEnd)];

  Color get accent => _hex(accentColor);

  IconData get iconData => _iconFromName(icon);

  bool get isExpired {
    final exp = expiresAtDate;
    if (exp == null) return false;
    return DateTime.now().isAfter(exp);
  }

  static PromoActionType _actionFromApi(String value) {
    switch (value) {
      case 'DISCOUNT':
        return PromoActionType.discount;
      case 'BROWSE_CATEGORY':
        return PromoActionType.browseCategory;
      default:
        return PromoActionType.info;
    }
  }

  static String actionToApi(PromoActionType action) {
    switch (action) {
      case PromoActionType.discount:
        return 'DISCOUNT';
      case PromoActionType.browseCategory:
        return 'BROWSE_CATEGORY';
      case PromoActionType.info:
        return 'INFO';
    }
  }

  static Color _hex(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  static IconData _iconFromName(String name) {
    switch (name) {
      case 'delivery_dining':
        return Icons.delivery_dining_rounded;
      case 'camera_alt':
        return Icons.camera_alt_rounded;
      case 'celebration':
        return Icons.celebration_rounded;
      case 'percent':
        return Icons.percent_rounded;
      default:
        return Icons.local_offer_rounded;
    }
  }
}

class WeeklyStat {
  final int date;
  final String label;
  final int orders;
  final double revenue;

  WeeklyStat({
    required this.date,
    required this.label,
    required this.orders,
    required this.revenue,
  });

  factory WeeklyStat.fromJson(Map<String, dynamic> json) {
    return WeeklyStat(
      date: json['date'] as int,
      label: json['label'] as String,
      orders: (json['orders'] as num).toInt(),
      revenue: (json['revenue'] as num).toDouble(),
    );
  }
}
