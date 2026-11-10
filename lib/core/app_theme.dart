import 'package:flutter/material.dart';

class AppColors {
  static const teal = Color(0xFF0F766E);
  static const tealLight = Color(0xFF14B8A6);
  static const cream = Color(0xFFFFF8EE);
  static const blush = Color(0xFFF9D5D3);
  static const ink = Color(0xFF1F2937);
  static const muted = Color(0xFF6B7280);
}

class AppTheme {
  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      brightness: brightness,
    ).copyWith(
      primary: dark ? AppColors.tealLight : AppColors.teal,
      onPrimary: dark ? const Color(0xFF00201D) : Colors.white,
    );

    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Poppins',
      scaffoldBackgroundColor:
      dark ? const Color(0xFF0E1716) : AppColors.cream,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF16231F) : Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: border(scheme.outlineVariant),
        enabledBorder: border(scheme.outlineVariant),
        focusedBorder: border(scheme.primary, 2),
        errorBorder: border(scheme.error),
        focusedErrorBorder: border(scheme.error, 2),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}