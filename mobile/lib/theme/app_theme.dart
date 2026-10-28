import 'package:flutter/material.dart';

class AppTheme {
  // Obsidian dark color scheme matching original Chatbot
  static const Color background = Color(0xFF0B0B0D);
  static const Color card = Color(0xFF111114);
  static const Color sidebar = Color(0xFF050506);
  static const Color border = Color(0xFF222228);
  static const Color input = Color(0xFF1E2028);

  static const Color primary = Color(0xFF2E6BFF);
  static const Color primaryLight = Color(0xFF5B8CFF);
  static const Color accent = Color(0xFF141B2E);
  static const Color accentForeground = Color(0xFFDCE6FF);

  static const Color textPrimary = Color(0xFFFAFAFA);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF5B544);
  static const Color error = Color(0xFFEF4444);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    cardColor: card,
    primaryColor: primary,
    colorScheme: const ColorScheme.dark(
      surface: background,
      primary: primary,
      secondary: accent,
      error: error,
      onPrimary: Colors.white,
      onSurface: textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: sidebar,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: textSecondary),
    ),
    dividerTheme: const DividerThemeData(
      color: border,
      thickness: 1,
    ),
  );
}
