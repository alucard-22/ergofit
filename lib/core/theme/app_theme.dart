import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  AppTheme._();

  // ── Colores ───────────────────────────────────────────────────────────────
  static const Color primary      = Color(0xFF1A6EF5);
  static const Color primaryDark  = Color(0xFF0D4DB3);
  static const Color primaryLight = Color(0xFF5B9BF8);

  static const Color accent       = Color(0xFF4CAF7D);
  static const Color accentOrange = Color(0xFFFFA000);
  static const Color accentRed    = Color(0xFFE53935);
  static const Color accentPurple = Color(0xFF7C3AED);

  // Fondos
  static const Color bgPrimary   = Color(0xFF0F1117);
  static const Color bgSecondary = Color(0xFF161B2E);
  static const Color bgTertiary  = Color(0xFF1E2540);
  static const Color bgCard      = Color(0xFF161B2E);

  // Textos
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8B8FA8);
  static const Color textHint      = Color(0xFF6B6F85);
  static const Color textMuted     = Color(0xFF4B4F6B);

  // Bordes
  static const Color border      = Color(0xFF1E2540);
  static const Color borderLight = Color(0xFF2A2D3A);

  // Colores por categoría
  static const Map<String, Color> categoryColors = {
    'neck':      Color(0xFF1A2F4E),
    'shoulders': Color(0xFF1A2F4E),
    'back':      Color(0xFF0D2E26),
    'eyes':      Color(0xFF1F1A3E),
    'wrists':    Color(0xFF2E1C0A),
    'legs':      Color(0xFF0D2137),
    'breathing': Color(0xFF1A1A3E),
  };

  static const Map<String, Color> categoryAccents = {
    'neck':      primary,
    'shoulders': primary,
    'back':      accent,
    'eyes':      accentPurple,
    'wrists':    accentOrange,
    'legs':      primary,
    'breathing': Color(0xFF06B6D4),
  };

  // ── Tema oscuro ───────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgPrimary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: bgSecondary,
        error: accentRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bgPrimary,
        selectedItemColor: primary,
        unselectedItemColor: textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 0.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? Colors.white : textHint),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? primary : borderLight),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: bgSecondary,
        selectedColor: primary,
        labelStyle: const TextStyle(color: textSecondary, fontSize: 13),
        side: const BorderSide(color: border, width: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgSecondary,
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
        labelStyle: const TextStyle(color: textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 0.5,
        space: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: bgSecondary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(color: textSecondary, fontSize: 14),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: bgTertiary,
        circularTrackColor: bgTertiary,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: bgSecondary,
        contentTextStyle: const TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      textTheme: const TextTheme(
        displayLarge:   TextStyle(color: textPrimary, fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -1.0),
        displayMedium:  TextStyle(color: textPrimary, fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        headlineLarge:  TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.3),
        headlineMedium: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        headlineSmall:  TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
        titleLarge:     TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
        titleMedium:    TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
        bodyLarge:      TextStyle(color: textPrimary, fontSize: 16, height: 1.5),
        bodyMedium:     TextStyle(color: textSecondary, fontSize: 14, height: 1.5),
        bodySmall:      TextStyle(color: textHint, fontSize: 12, height: 1.4),
        labelLarge:     TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
        labelMedium:    TextStyle(color: textSecondary, fontSize: 12),
        labelSmall:     TextStyle(color: textHint, fontSize: 11),
      ),
    );
  }
  static BoxDecoration cardDecoration({
    Color? color,
    double radius = 16,
    Color? borderColor,
  }) =>
      BoxDecoration(
        color: color ?? bgCard,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? border, width: 0.5),
      );

  static BoxDecoration gradientDecoration({
    required List<Color> colors,
    double radius = 20,
  }) =>
      BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(radius),
      );

  static Color categoryBg(String category) =>
      categoryColors[category] ?? bgSecondary;

  static Color categoryAccent(String category) =>
      categoryAccents[category] ?? primary;
}
