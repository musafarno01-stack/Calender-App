import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const accent = Color(0xFF6558D9);

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF11121A) : const Color(0xFFF7F7FC),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData(brightness: brightness).textTheme,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark
            ? const Color(0xFF11121A)
            : const Color(0xFFF7F7FC),
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF1C1D29) : Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : const Color(0xFFEAEAF2),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? const Color(0xFF242532)
            : const Color(0xFFF1F1F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: isDark
            ? const Color(0xFF191A25)
            : Colors.white,
        indicatorColor: accent.withValues(alpha: 0.13),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.white,
      ),
      dividerColor: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : const Color(0xFFEAEAF2),
    );
  }
}
