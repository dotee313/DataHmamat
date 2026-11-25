import 'package:flutter/material.dart';

/// هوية موحّدة: بنفسجي الشعار، ذهبي، وكحلي.
abstract final class AppTheme {
  static const Color purple = Color(0xFF8338EC);
  static const Color purpleDark = Color(0xFF5B21B6);
  static const Color gold = Color(0xFFFCA311);
  static const Color navy = Color(0xFF14213D);

  static const Color canvas = Color(0xFFF7F7FB);
  static const Color card = Colors.white;
  static const Color ink = navy;
  static const Color muted = Color(0xFF667085);
  static const Color line = Color(0xFFE4E7EC);

  static const Color darkCanvas = Color(0xFF0E1624);
  static const Color darkCard = Color(0xFF17253B);
  static const Color darkInk = Color(0xFFF4F6FB);
  static const Color darkMuted = Color(0xFFA9B4C6);
  static const Color darkLine = Color(0xFF26364F);

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: purple,
      primary: purple,
      secondary: gold,
      surface: isDark ? darkCard : card,
      error: const Color(0xFFB3261E),
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? darkCanvas : canvas,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? darkCanvas : canvas,
        foregroundColor: isDark ? darkInk : ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: isDark ? darkInk : ink,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark ? darkCard : card,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: isDark ? darkLine : line),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF213149) : const Color(0xFFF1F3F8),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: purple, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: purple,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? darkInk : purple,
          minimumSize: const Size.fromHeight(48),
          side: BorderSide(color: isDark ? darkLine : line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? darkCard : card,
        surfaceTintColor: Colors.transparent,
        indicatorColor: purple.withValues(alpha: 0.16),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: DividerThemeData(color: isDark ? darkLine : line, space: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: navy,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? darkCard : card,
        titleTextStyle: TextStyle(
          color: isDark ? darkInk : ink,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
