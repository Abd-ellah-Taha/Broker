import 'package:flutter/material.dart';

/// Material 3 theme for Broker - PropTech Marketplace.
/// Sophisticated, calm palette: Navy Blue, Slate Gray, Off-white.
class AppTheme {
  AppTheme._();

  // Brand colors
  static const Color navyBlue = Color(0xFF1A237E);
  static const Color slateGray = Color(0xFF455A64);
  static const Color offWhite = Color(0xFFFAFAFA);
  static const Color verifiedGreen = Color(0xFF2E7D32);

  // Semantic colors
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF263238);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: navyBlue,
      primary: navyBlue,
      secondary: slateGray,
      surface: surfaceLight,
      background: offWhite,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: offWhite,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceLight,
        foregroundColor: navyBlue,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: navyBlue,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 2,
        shadowColor: slateGray.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: navyBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: navyBlue,
          side: const BorderSide(color: slateGray),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: slateGray.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: navyBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: slateGray.withValues(alpha: 0.7)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: slateGray.withValues(alpha: 0.12),
        selectedColor: navyBlue.withValues(alpha: 0.2),
        labelStyle: const TextStyle(color: slateGray),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      iconTheme: const IconThemeData(
        color: slateGray,
        size: 24,
      ),
      textTheme: _buildTextTheme(Brightness.light),
    );
  }

  static TextTheme _buildTextTheme(Brightness brightness) {
    const baseColor = Color(0xFF263238);
    return TextTheme(
      displayLarge: const TextStyle(
        color: navyBlue,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: const TextStyle(
        color: navyBlue,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: const TextStyle(
        color: navyBlue,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: const TextStyle(
        color: navyBlue,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: const TextStyle(
        color: navyBlue,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: baseColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: baseColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: baseColor,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: baseColor,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        color: slateGray,
        fontSize: 12,
      ),
    );
  }
}
