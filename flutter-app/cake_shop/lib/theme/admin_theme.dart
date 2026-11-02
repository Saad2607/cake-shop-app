import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme.dart';

/// Merchant / partner panel styling — refined liquid glass data-dense theme.
class AdminTheme {
  static const Color scaffold = Color(0xFFF7F4F0);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceGlass = Color(0xF2FFFFFF);
  static const Color border = Color(0xFFEBE3DC);
  static const Color borderGlass = Color(0x66FFFFFF);
  static const Color textPrimary = Color(0xFF2B1D19);
  static const Color textSecondary = Color(0xFF7D6E68);
  static const Color accent = Color(0xFFC7516B);
  static const Color accentDark = Color(0xFF6B1D30);
  static const Color accentLight = Color(0xFFF8DCE2);
  static const Color online = Color(0xFF2E8558);
  static const Color warning = Color(0xFFC58828);
  static const Color info = Color(0xFF2A75C7);

  static BorderRadius get radiusSm => BorderRadius.circular(10);
  static BorderRadius get radiusMd => BorderRadius.circular(14);
  static BorderRadius get radiusLg => BorderRadius.circular(20);

  static BoxDecoration get cardDecoration => BoxDecoration(
        color: surface,
        borderRadius: radiusMd,
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2B1D19).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      );

  static BoxDecoration get glassDecoration => BoxDecoration(
        color: surfaceGlass,
        borderRadius: radiusMd,
        border: Border.all(color: borderGlass, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2B1D19).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static TextStyle get sectionTitle => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.2,
      );

  static TextStyle get kpiValue => GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        letterSpacing: -0.5,
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
        return const Color(0xFF8B4CB8);
      case 'READY':
        return const Color(0xFF1E94A8);
      case 'OUT_FOR_DELIVERY':
        return const Color(0xFF0288D1);
      case 'DELIVERED':
        return online;
      case 'CANCELLED':
        return const Color(0xFFC53030);
      default:
        return textSecondary;
    }
  }
}
