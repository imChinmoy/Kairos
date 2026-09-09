import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// KAIROS Design System
/// Maritime government-grade color palette: deep navy, ocean blue, teal, white, soft grey.
class KairosTheme {
  KairosTheme._();

  // ─── Color Palette ────────────────────────────────────────────────────────
  static const Color primaryNavy = Color(0xFF0B2D4F);
  static const Color deepNavy = Color(0xFF071D35);
  static const Color oceanBlue = Color(0xFF1565C0);
  static const Color teal = Color(0xFF008C95);
  static const Color backgroundLight = Color(0xFFF4F7FA);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  
  static const Color textPrimary = Color(0xFF102A43);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  
  static const Color borderGrey = Color(0xFFD9E2EC);

  static const Color warning = Color(0xFFE89B18);
  static const Color error = Color(0xFFC62828);
  static const Color success = Color(0xFF2E7D5B);
  static const Color info = Color(0xFF1565C0);

  // Indian Identity Accents
  static const Color saffron = Color(0xFFE87518);
  static const Color indiaGreen = Color(0xFF138A58);

  // Legacy mappings for compatibility
  static const Color cardWhite = surfaceWhite;
  static const Color white = surfaceWhite;
  static const Color offWhite = backgroundLight;
  static const Color navyBlue = primaryNavy;
  static const Color surfaceGrey = borderGrey;
  static const Color govGreen = success;
  static const Color tealLight = teal;
  static const Color secondaryBlue = oceanBlue;
  static const Color seaGreen = indiaGreen;
  static const Color sosRed = error;

  // Priority colors
  static const Color priorityCritical = Color(0xFF7C3AED);
  static const Color priorityHigh = error;
  static const Color priorityMedium = saffron;
  static const Color priorityLow = teal;

  // ─── Spacing & Corner Radius ──────────────────────────────────────────────
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;

  static const double radius8 = 8.0;
  static const double radius12 = 12.0;
  static const double radius16 = 16.0;
  static const double radius20 = 16.0; // Overridden to prevent huge corners

  // ─── Theme Data ───────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryNavy,
        onPrimary: surfaceWhite,
        primaryContainer: Color(0xFFDBEAFE),
        onPrimaryContainer: primaryNavy,
        secondary: oceanBlue,
        onSecondary: surfaceWhite,
        secondaryContainer: Color(0xFFCCFBF1),
        onSecondaryContainer: teal,
        error: error,
        onError: surfaceWhite,
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
        fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400, color: textPrimary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 13, fontWeight: FontWeight.w400, color: textSecondary,
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
      backgroundColor: primaryNavy.withOpacity(0.95),
      foregroundColor: surfaceWhite,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 18, fontWeight: FontWeight.w700, color: surfaceWhite, letterSpacing: 1.5,
      ),
      iconTheme: const IconThemeData(color: surfaceWhite),
    );
  }

  static CardThemeData _buildCardTheme() {
    return CardThemeData(
      color: surfaceWhite.withOpacity(0.95),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius12),
        side: const BorderSide(color: borderGrey, width: 1),
      ),
      margin: EdgeInsets.zero,
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryNavy,
        foregroundColor: surfaceWhite,
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsets.symmetric(horizontal: spacing24, vertical: spacing12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius8)),
        elevation: 0,
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: oceanBlue,
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsets.symmetric(horizontal: spacing24, vertical: spacing12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius8)),
        side: const BorderSide(color: oceanBlue),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }

  static BottomNavigationBarThemeData _buildBottomNavTheme() {
    return BottomNavigationBarThemeData(
      backgroundColor: surfaceWhite,
      selectedItemColor: oceanBlue,
      unselectedItemColor: textSecondary,
      selectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500),
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
      case 'ACCEPTED': return oceanBlue;
      case 'IN_PROGRESS': return oceanBlue;
      case 'COMPLETED': return success;
      case 'CANCELLED': return textMuted;
      default: return textMuted;
    }
  }

  static Color compatibilityColor(String priority) => priorityColor(priority);
}

