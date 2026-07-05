import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium bakery palette — warm cream, rose, champagne gold
  static const Color primary = Color(0xFFB8365E);
  static const Color primaryDark = Color(0xFF6B1D3A);
  static const Color primaryLight = Color(0xFFF2C4D0);
  static const Color gold = Color(0xFFC9A962);
  static const Color goldLight = Color(0xFFF5EDD8);
  static const Color secondary = Color(0xFFE8A87C);
  static const Color background = Color(0xFFFFFBF7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1C1410);
  static const Color textMuted = Color(0xFF8B7B73);
  static const Color success = Color(0xFF3D8B5F);
  static const Color successLight = Color(0xFFE8F5EE);
  static const Color cardBorder = Color(0xFFF0E8E4);

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

  static BoxShadow get cardShadow => BoxShadow(
        color: const Color(0xFF6B1D3A).withValues(alpha: 0.06),
        blurRadius: 20,
        offset: const Offset(0, 8),
      );

  static BoxShadow get softShadow => BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 12,
        offset: const Offset(0, 4),
      );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A1530), Color(0xFF8B2D52), Color(0xFFC4457A)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3D1228), Color(0xFF7A2548), Color(0xFFD4567E)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC9A962), Color(0xFFE8C98A)],
  );

  static const LinearGradient ctaGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFB8365E), Color(0xFFD4567E)],
  );

  static BorderRadius get radiusLg => BorderRadius.circular(24);
  static BorderRadius get radiusMd => BorderRadius.circular(16);
  static BorderRadius get radiusSm => BorderRadius.circular(12);

  static const Color statusPending = Color(0xFFC9A962);
  static const Color statusConfirmed = Color(0xFFB8365E);
  static const Color statusBaking = Color(0xFFE8A87C);
  static const Color statusReady = Color(0xFFC9A962);
  static const Color statusDelivered = Color(0xFF3D8B5F);
  static const Color statusCancelled = Color(0xFF9E4A5A);

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
        foregroundColor: Colors.white,
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
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withValues(alpha: 0.1),
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: primary,
            );
          }
          return GoogleFonts.plusJakartaSans(fontSize: 11, color: textMuted);
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: radiusSm),
        backgroundColor: primaryDark,
      ),
    );
  }
}
