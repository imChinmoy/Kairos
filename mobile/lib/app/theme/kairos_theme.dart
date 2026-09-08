import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// KAIROS Design System
/// Maritime government-grade color palette: deep navy, ocean blue, teal, white, soft grey.
class KairosTheme {
  KairosTheme._();

  // ─── Color Palette ────────────────────────────────────────────────────────

  static const Color backgroundLight = Color(0xFFF6F8FB);
  static const Color primaryNavy = Color(0xFF0F3B6E);
  static const Color secondaryBlue = Color(0xFF1976D2);
  static const Color teal = Color(0xFF00A6A6);
  static const Color seaGreen = Color(0xFF2E7D32);
  static const Color saffron = Color(0xFFFF9800);
  
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color borderGrey = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF14213D);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF0EA5E9);

  // Priority colors
  static const Color priorityCritical = Color(0xFF7C3AED);
  static const Color priorityHigh = error;
  static const Color priorityMedium = saffron;
  static const Color priorityLow = seaGreen;

  static const Color sosRed = error;

  // ─── Legacy Color Palette (for compatibility) ───────────────────────────
  static const Color white = cardWhite;
  static const Color offWhite = backgroundLight;
  static const Color deepNavy = primaryNavy;
  static const Color navyBlue = primaryNavy;
  static const Color oceanBlue = secondaryBlue;
  static const Color surfaceGrey = borderGrey;
  static const Color govGreen = success;
  static const Color tealLight = teal;

  // ─── Spacing & Corner Radius ──────────────────────────────────────────────
  
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;

  static const double radius12 = 12.0;
  static const double radius16 = 16.0;
  static const double radius20 = 20.0;

  // ─── Theme Data ───────────────────────────────────────────────────────────

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryNavy,
        onPrimary: cardWhite,
        primaryContainer: Color(0xFFDBEAFE),
        onPrimaryContainer: primaryNavy,
        secondary: secondaryBlue,
        onSecondary: cardWhite,
        secondaryContainer: Color(0xFFCCFBF1),
        onSecondaryContainer: teal,
        error: error,
        onError: cardWhite,
        surface: backgroundLight,
        onSurface: textPrimary,
        surfaceContainerHighest: borderGrey,
        outline: borderGrey,
      ),
      scaffoldBackgroundColor: backgroundLight,
      textTheme: _buildTextTheme(),
      appBarTheme: _buildAppBarTheme(),
      cardTheme: _buildCardTheme(),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(),
      bottomNavigationBarTheme: _buildBottomNavTheme(),
      dividerTheme: const DividerThemeData(color: borderGrey, thickness: 1),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 30, fontWeight: FontWeight.w700, color: textPrimary,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary,
      ),
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 15, fontWeight: FontWeight.w400, color: textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400, color: textPrimary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 13, fontWeight: FontWeight.w500, color: textSecondary,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w600,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 13, fontWeight: FontWeight.w500,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w500,
      ),
    );
  }

  static AppBarTheme _buildAppBarTheme() {
    return AppBarTheme(
      backgroundColor: backgroundLight,
      foregroundColor: textPrimary,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary,
      ),
    );
  }

  static CardThemeData _buildCardTheme() {
    return CardThemeData(
      color: cardWhite,
      elevation: 2,
      shadowColor: textPrimary.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius16),
        side: const BorderSide(color: borderGrey, width: 0.5),
      ),
      margin: EdgeInsets.zero,
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryNavy,
        foregroundColor: cardWhite,
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsets.symmetric(horizontal: spacing24, vertical: spacing12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius12)),
        elevation: 0,
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: secondaryBlue,
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsets.symmetric(horizontal: spacing24, vertical: spacing12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius12)),
        side: const BorderSide(color: secondaryBlue),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }

  static BottomNavigationBarThemeData _buildBottomNavTheme() {
    return BottomNavigationBarThemeData(
      backgroundColor: cardWhite,
      selectedItemColor: primaryNavy,
      unselectedItemColor: textMuted,
      selectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
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
      case 'IN_PROGRESS': return secondaryBlue;
      case 'COMPLETED': return success;
      case 'CANCELLED': return textMuted;
      default: return textMuted;
    }
  }

  static Color compatibilityColor(String priority) => priorityColor(priority);
}

