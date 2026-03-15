// lib/theme/app_theme.dart
// =========================
// Centralized theme matching the dark maroon/rose aesthetic
// used in the existing website screens.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ── Core Colors ─────────────────────────────────────────────────────────

  static const Color background = Color(0xFF2D1A20);
  static const Color backgroundDark = Color(0xFF1A1014);
  static const Color backgroundGradientStart = Color(0xFF3D2028);
  static const Color backgroundGradientEnd = Color(0xFF251520);

  static const Color surface = Color(0xFF3A2129);
  static const Color surfaceLight = Color(0xFF4A2F38);

  static const Color accent = Color(0xFF8B5E6B);
  static const Color accentLight = Color(0xFF9B6F7A);
  static const Color accentDark = Color(0xFF6B4A54);

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xB3FFFFFF); // 70% white
  static const Color textMuted = Color(0x80FFFFFF); // 50% white

  // Risk level colors
  static const Color riskHigh = Color(0xFFE74C3C);
  static const Color riskMedium = Color(0xFFF39C12);
  static const Color riskLow = Color(0xFF2ECC71);
  static const Color riskNone = Color(0xFF95A5A6);

  // ── Sidebar ─────────────────────────────────────────────────────────────

  static const Color sidebarBg = Color(0xFF1E1218);
  static const double sidebarWidth = 72.0;
  static const double sidebarExpandedWidth = 240.0;

  // ── Card Styles ─────────────────────────────────────────────────────────

  static BoxDecoration glassCard({Color? borderColor}) => BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor ?? Colors.white.withOpacity(0.06),
        ),
      );

  static BoxDecoration solidCard({Color? color}) => BoxDecoration(
        color: color ?? surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  // ── Gradients ───────────────────────────────────────────────────────────

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundGradientStart, background, backgroundGradientEnd],
  );

  static LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
  );

  // ── Input Decoration ────────────────────────────────────────────────────

  static InputDecoration inputDecoration({
    required String label,
    String? hint,
    IconData? prefixIcon,
    Widget? suffix,
  }) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: textMuted, size: 20)
            : null,
        suffix: suffix,
        labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
        hintStyle: TextStyle(color: textMuted.withOpacity(0.5), fontSize: 14),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: riskHigh),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: riskHigh, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      );

  // ── Button Styles ───────────────────────────────────────────────────────

  static ButtonStyle primaryButton({Color? color}) => ElevatedButton.styleFrom(
        backgroundColor: color ?? accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      );

  static ButtonStyle outlinedButton({Color? color}) =>
      OutlinedButton.styleFrom(
        foregroundColor: color ?? accent,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        side: BorderSide(color: color ?? accent),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      );

  // ── ThemeData ───────────────────────────────────────────────────────────

  static ThemeData get themeData => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.dark(
          surface: background,
          primary: accent,
          secondary: accentLight,
          error: riskHigh,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.dark().textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: textPrimary,
        ),
        cardTheme: CardThemeData(
          color: surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: primaryButton(),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
        ),
      );

  // ── Responsive Helpers ──────────────────────────────────────────────────

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > 1100;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width > 768 &&
      MediaQuery.of(context).size.width <= 1100;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width <= 768;
}

// ── Risk Level Helpers ──────────────────────────────────────────────────────

Color riskColor(String level) {
  switch (level.toUpperCase()) {
    case 'HIGH':
      return AppTheme.riskHigh;
    case 'MEDIUM':
      return AppTheme.riskMedium;
    case 'LOW':
      return AppTheme.riskLow;
    default:
      return AppTheme.riskNone;
  }
}

String riskEmoji(String level) {
  switch (level.toUpperCase()) {
    case 'HIGH':
      return '🔴';
    case 'MEDIUM':
      return '🟡';
    case 'LOW':
      return '🟢';
    default:
      return '⚪';
  }
}
