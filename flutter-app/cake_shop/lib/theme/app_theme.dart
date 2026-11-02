import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sweet Delights Liquid Glass Design System
/// Inspired by Apple Liquid Glass, luxury bakeries, and modern iOS aesthetics.
class AppTheme {
  // Primary: Soft blush pink
  static const Color primary = Color(0xFFC7516B);
  static const Color primaryDark = Color(0xFF6B1D30);
  static const Color primaryLight = Color(0xFFF8DCE2);

  // Secondary: Warm cream & champagne
  static const Color secondary = Color(0xFFF0B89C);
  static const Color cream = Color(0xFFFFF7F0);
  static const Color creamDark = Color(0xFFF6ECE3);
  static const Color gold = Color(0xFFC59F5A);
  static const Color goldLight = Color(0xFFF7F1E4);

  // Accent & Background
  static const Color accentRose = Color(0xFFDE526C);
  static const Color roseAccent = accentRose;
  static const Color accent = accentRose;
  static const Color background = Color(0xFFFAF6F2); // Warm ivory off-white
  static const Color surface = Color(0xFFFFFFFF);

  // Text: Deep chocolate brown & warm grey
  static const Color textDark = Color(0xFF2B1D19);
  static const Color textMuted = Color(0xFF7D6E68);
  static const Color textLight = Color(0xFFB5A8A2);

  // Status Colors
  static const Color success = Color(0xFF388E62);
  static const Color successLight = Color(0xFFEAF5EE);
  static const Color cardBorder = Color(0xFFEDE4DC);

  // Liquid Glass Tokens
  static const Color glassWhite = Color(0xCCFFFFFF); // 80% opacity
  static const Color glassWhiteDense = Color(0xEEFFFFFF); // 93% opacity
  static const Color glassWhiteSubtle = Color(0x99FFFFFF); // 60% opacity
  static const Color glassBorder = Color(0x80FFFFFF); // 50% white specular edge
  static const Color glassBorderSubtle = Color(0x332B1D19); // 20% brown tint border

  // Gradients
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5B1E30), Color(0xFF8E3752), Color(0xFFC45A75)],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A1626), Color(0xFF7E2843), Color(0xFFD66A83)],
  );

  static const LinearGradient ctaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC7516B), Color(0xFFE27088)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC59F5A), Color(0xFFE8C888)],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xDDFFFFFF), // 87% white highlight
      Color(0xA6FFFFFF), // 65% white base
    ],
  );

  static const LinearGradient glassSpecularGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0x00FFFFFF),
    ],
    stops: [0.0, 0.6],
  );

  // Radii
  static BorderRadius get radiusSm => BorderRadius.circular(12);
  static BorderRadius get radiusMd => BorderRadius.circular(16);
  static BorderRadius get radiusLg => BorderRadius.circular(24);
  static BorderRadius get radiusXl => BorderRadius.circular(32);
  static BorderRadius get radiusPill => BorderRadius.circular(100);

  // Shadows
  static BoxShadow get cardShadow => BoxShadow(
        color: const Color(0xFF2B1D19).withValues(alpha: 0.05),
        blurRadius: 20,
        offset: const Offset(0, 8),
      );

  static BoxShadow get softShadow => BoxShadow(
        color: const Color(0xFF2B1D19).withValues(alpha: 0.035),
        blurRadius: 14,
        offset: const Offset(0, 4),
      );

  static BoxShadow get glassShadow => BoxShadow(
        color: const Color(0xFF2B1D19).withValues(alpha: 0.07),
        blurRadius: 24,
        offset: const Offset(0, 8),
      );

  static BoxShadow get glowShadow => BoxShadow(
        color: primary.withValues(alpha: 0.28),
        blurRadius: 16,
        offset: const Offset(0, 6),
      );

  // Typography
  static TextStyle get displayLarge => GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textDark,
        height: 1.15,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMedium => GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textDark,
        height: 1.2,
      );

  static TextStyle get titleLarge => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textDark,
        letterSpacing: -0.3,
      );

  static TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: textDark,
      );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textDark,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textMuted,
      );

  static TextStyle get labelBold => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      );

  // Status color mapping
  static const Color statusPending = Color(0xFFC59F5A);
  static const Color statusConfirmed = Color(0xFFC7516B);
  static const Color statusBaking = Color(0xFFE0835D);
  static const Color statusReady = Color(0xFF2C9EA6);
  static const Color statusOutForDelivery = Color(0xFF0288D1);
  static const Color statusDelivered = Color(0xFF388E62);
  static const Color statusCancelled = Color(0xFFA84252);

  static Color orderStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return statusPending;
      case 'CONFIRMED':
        return statusConfirmed;
      case 'BAKING':
        return statusBaking;
      case 'READY':
        return statusReady;
      case 'OUT_FOR_DELIVERY':
        return statusOutForDelivery;
      case 'DELIVERED':
        return statusDelivered;
      case 'CANCELLED':
        return statusCancelled;
      default:
        return textMuted;
    }
  }

  static ThemeData get lightTheme {
    final base = GoogleFonts.plusJakartaSansTextTheme();
    return ThemeData(
      useMaterial3: true,
      textTheme: base.apply(bodyColor: textDark, displayColor: textDark),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: gold,
        surface: surface,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: radiusLg),
        color: surface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: radiusMd),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: radiusMd),
          side: const BorderSide(color: primary, width: 1.5),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: const BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: GoogleFonts.plusJakartaSans(color: textMuted, fontSize: 14),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: radiusSm),
        backgroundColor: textDark,
      ),
    );
  }

  /// Luxury "Midnight Chocolatier" Dark Theme
  static ThemeData get darkTheme {
    const darkBg = Color(0xFF140D0B); // Deep espresso
    const darkSurface = Color(0xFF221614); // Dark cocoa truffle
    const darkCardBorder = Color(0xFF382522);
    const darkText = Color(0xFFFFF6F0); // Warm cream
    const darkTextMuted = Color(0xFFA69690);

    final base = GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      textTheme: base.apply(bodyColor: darkText, displayColor: darkText),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        primary: const Color(0xFFE892A2),
        secondary: gold,
        surface: darkSurface,
      ),
      scaffoldBackgroundColor: darkBg,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: darkText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: darkText,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: radiusLg),
        color: darkSurface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: radiusMd),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFE892A2),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: radiusMd),
          side: const BorderSide(color: Color(0xFFE892A2), width: 1.5),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: const BorderSide(color: darkCardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: const BorderSide(color: Color(0xFFE892A2), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: GoogleFonts.plusJakartaSans(color: darkTextMuted, fontSize: 14),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: radiusSm),
        backgroundColor: darkSurface,
      ),
    );
  }
}
