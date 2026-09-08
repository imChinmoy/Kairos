import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// KAIROS Design System
/// Maritime government-grade color palette: deep navy, ocean blue, teal, white, soft grey.
/// Indian government accents: saffron/orange, tricolor green — used sparingly.
class KairosTheme {
  KairosTheme._();

  // ─── Color Palette ────────────────────────────────────────────────────────

  static const Color deepNavy = Color(0xFF0A1628);
  static const Color navyBlue = Color(0xFF0F2952);
  static const Color oceanBlue = Color(0xFF1A4A8A);
  static const Color lightBlue = Color(0xFF2E6FBF);
  static const Color teal = Color(0xFF0B7A75);
  static const Color tealLight = Color(0xFF14B8A6);
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF8FAFB);
  static const Color surfaceGrey = Color(0xFFF1F5F9);
  static const Color borderGrey = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);

  // Accent — Indian government palette (used minimally)
  static const Color saffron = Color(0xFFFF6B35);
  static const Color govGreen = Color(0xFF138808);

  // Status colors
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF0EA5E9);

  // Priority colors
  static const Color priorityCritical = Color(0xFF7C3AED);
  static const Color priorityHigh = Color(0xFFDC2626);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityLow = Color(0xFF16A34A);

  // SOS — emergency red
  static const Color sosRed = Color(0xFFCC0000);
  static const Color sosPulse = Color(0xFFFF4444);

  // ─── Theme Data ───────────────────────────────────────────────────────────

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: oceanBlue,
        onPrimary: white,
        primaryContainer: Color(0xFFDBEAFE),
        onPrimaryContainer: deepNavy,
        secondary: teal,
        onSecondary: white,
        secondaryContainer: Color(0xFFCCFBF1),
        onSecondaryContainer: Color(0xFF134E4A),
        error: error,
        onError: white,
        surface: offWhite,
        onSurface: textPrimary,
        surfaceContainerHighest: surfaceGrey,
        outline: borderGrey,
        outlineVariant: Color(0xFFCBD5E1),
      ),
      scaffoldBackgroundColor: offWhite,
      textTheme: _buildTextTheme(),
      appBarTheme: _buildAppBarTheme(),
      cardTheme: _buildCardTheme(),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(),
      inputDecorationTheme: _buildInputDecorationTheme(),
      bottomNavigationBarTheme: _buildBottomNavTheme(),
      chipTheme: _buildChipTheme(),
      dividerTheme: const DividerThemeData(color: borderGrey, thickness: 1),
      snackBarTheme: _buildSnackBarTheme(),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: const TextStyle(
        fontSize: 32, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -0.5,
      ),
      displayMedium: const TextStyle(
        fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary,
      ),
      headlineLarge: const TextStyle(
        fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary,
      ),
      headlineMedium: const TextStyle(
        fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary,
      ),
      headlineSmall: const TextStyle(
        fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary,
      ),
      titleLarge: const TextStyle(
        fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary,
      ),
      titleMedium: const TextStyle(
        fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary,
      ),
      titleSmall: const TextStyle(
        fontSize: 14, fontWeight: FontWeight.w500, color: textSecondary,
      ),
      bodyLarge: const TextStyle(
        fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14, fontWeight: FontWeight.w400, color: textPrimary,
      ),
      bodySmall: const TextStyle(
        fontSize: 12, fontWeight: FontWeight.w400, color: textSecondary,
      ),
      labelLarge: const TextStyle(
        fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5,
      ),
      labelMedium: const TextStyle(
        fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.3,
      ),
      labelSmall: const TextStyle(
        fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.4,
      ),
    );
  }

  static AppBarTheme _buildAppBarTheme() {
    return const AppBarTheme(
      backgroundColor: white,
      foregroundColor: textPrimary,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: Color(0x14000000),
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary,
      ),
    );
  }

  static CardThemeData _buildCardTheme() {
    return CardThemeData(
      color: white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: borderGrey),
      ),
      margin: EdgeInsets.zero,
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: oceanBlue,
        foregroundColor: white,
        minimumSize: const Size(double.infinity, 52),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.3),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: oceanBlue,
        minimumSize: const Size(double.infinity, 52),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: const BorderSide(color: oceanBlue),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: surfaceGrey,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: borderGrey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: borderGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: oceanBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: error),
      ),
      labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
      hintStyle: const TextStyle(color: textMuted, fontSize: 14),
    );
  }

  static BottomNavigationBarThemeData _buildBottomNavTheme() {
    return const BottomNavigationBarThemeData(
      backgroundColor: white,
      selectedItemColor: oceanBlue,
      unselectedItemColor: textMuted,
      selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 11),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    );
  }

  static ChipThemeData _buildChipTheme() {
    return ChipThemeData(
      backgroundColor: surfaceGrey,
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  static SnackBarThemeData _buildSnackBarTheme() {
    return SnackBarThemeData(
      backgroundColor: deepNavy,
      contentTextStyle: const TextStyle(color: white, fontSize: 14),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  // ─── Utility Methods ─────────────────────────────────────────────────────

  static Color priorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'CRITICAL': return priorityCritical;
      case 'HIGH': return priorityHigh;
      case 'MEDIUM': return priorityMedium;
      case 'LOW': return priorityLow;
      default: return textMuted;
    }
  }

  static Color statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ASSIGNED': return warning;
      case 'ACCEPTED': return info;
      case 'IN_PROGRESS': return oceanBlue;
      case 'COMPLETED': return success;
      case 'CANCELLED': return textMuted;
      default: return textMuted;
    }
  }

  static Color compatibilityColor(String compatibility) {
    switch (compatibility.toUpperCase()) {
      case 'HIGH': return error;
      case 'MEDIUM': return warning;
      case 'LOW': return success;
      default: return textMuted;
    }
  }
}
