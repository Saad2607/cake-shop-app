import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Merchant / partner panel styling — data-dense, neutral (Swiggy, Zomato, Blinkit style).
class AdminTheme {
  static const Color scaffold = Color(0xFFF4F6F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E9EF);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color accent = Color(0xFFB8365E);
  static const Color accentDark = Color(0xFF6B1D3A);
  static const Color online = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color info = Color(0xFF2563EB);

  static BorderRadius get radiusSm => BorderRadius.circular(8);
  static BorderRadius get radiusMd => BorderRadius.circular(12);

  static BoxDecoration get cardDecoration => BoxDecoration(
        color: surface,
        borderRadius: radiusMd,
        border: Border.all(color: border),
      );

  static TextStyle get sectionTitle => AppTheme.titleLarge.copyWith(
        fontSize: 16,
        color: textPrimary,
      );

  static TextStyle get kpiValue => AppTheme.displayMedium.copyWith(
        fontSize: 22,
        color: textPrimary,
      );

  static TextStyle get kpiLabel => AppTheme.bodySmall.copyWith(
        fontSize: 11,
        color: textSecondary,
        fontWeight: FontWeight.w600,
      );

  static Color statusColor(String status) {
    switch (status) {
      case 'PENDING':
        return warning;
      case 'CONFIRMED':
        return info;
      case 'BAKING':
        return const Color(0xFF7C3AED);
      case 'READY':
        return const Color(0xFF0891B2);
      case 'DELIVERED':
        return online;
      case 'CANCELLED':
        return const Color(0xFFDC2626);
      default:
        return textSecondary;
    }
  }
}
