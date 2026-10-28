import 'package:flutter/material.dart';

/// Design system.
///
/// Flat, layered dark surfaces. Depth is created only with solid fills and
/// hairline borders — no gradients and no glow/blur shadows anywhere.
class AppTheme {
  AppTheme._();

  // ── Surfaces (darkest → lightest) ──────────────────────────────────────
  static const Color background = Color(0xFF09090B);
  static const Color sidebar = Color(0xFF09090B);
  static const Color card = Color(0xFF111114);
  static const Color surfaceHigh = Color(0xFF18181D);
  static const Color input = Color(0xFF1C1C22);

  // ── Lines ──────────────────────────────────────────────────────────────
  static const Color border = Color(0xFF25252C);
  static const Color borderStrong = Color(0xFF34343E);

  // ── Brand ──────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF3B6CFF);
  static const Color primaryLight = Color(0xFF7C9CFF);
  static const Color accent = Color(0xFF121A33);
  static const Color accentForeground = Color(0xFFDCE6FF);

  // ── Text ───────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF4F4F5);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textMuted = Color(0xFF71717A);

  // ── Semantic ───────────────────────────────────────────────────────────
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFF87171);
  static const Color info = Color(0xFF38BDF8);
  static const Color violet = Color(0xFFA78BFA);

  /// Distinct flat colour per council member.
  static const List<Color> agentColors = [
    Color(0xFF38BDF8),
    Color(0xFFA78BFA),
    Color(0xFFFBBF24),
    Color(0xFFF472B6),
  ];

  // ── Radii & spacing ────────────────────────────────────────────────────
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;

  /// Flat tinted fill of [color] suitable for chips/badges.
  static Color tint(Color color, [double alpha = 0.12]) =>
      color.withValues(alpha: alpha);

  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
    );

    final textTheme = base.textTheme.apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    );

    return base.copyWith(
      scaffoldBackgroundColor: background,
      cardColor: card,
      primaryColor: primary,
      textTheme: textTheme,
      splashFactory: InkRipple.splashFactory,
      colorScheme: const ColorScheme.dark(
        surface: background,
        primary: primary,
        secondary: accent,
        error: error,
        onPrimary: Colors.white,
        onSurface: textPrimary,
        surfaceTint: Colors.transparent,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 4,
        titleTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: textSecondary),
      ),
      dividerTheme: const DividerThemeData(color: border, thickness: 1),
      drawerTheme: const DrawerThemeData(
        backgroundColor: sidebar,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceHigh,
        contentTextStyle: const TextStyle(color: textPrimary, fontSize: 13),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: const BorderSide(color: border),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryLight,
      ),
    );
  }
}
