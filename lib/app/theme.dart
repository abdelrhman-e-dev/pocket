import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // =========================
  // App Colors
  // =========================

  static const Color backgroundColor = Color(0xFFFAFBFC);

  static const Color imageAreaColor = Color(0xFFF4F6F8);

  static const Color primaryColor = Color(0xFF00658A);

  static const Color secondaryColor = Color(0xFF4F7C92);

  static const Color textColor = Color(0xFF172027);

  static const Color subtitleColor = Color(0xFF52616B);

  static const Color surfaceColor = Colors.white;

  static const Color borderColor = Color(0xFFE4E9ED);

  static const Color iconBackgroundColor = Color(0xFFE1F2F8);

  static const Color errorColor = Color(0xFFBA1A1A);

  // =========================
  // Light Theme
  // =========================

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Cairo',
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ).copyWith(
          primary: primaryColor,
          onPrimary: Colors.white,

          secondary: secondaryColor,

          primaryContainer: iconBackgroundColor,
          onPrimaryContainer: primaryColor,

          surface: surfaceColor,
          onSurface: textColor,

          surfaceContainerLowest: Colors.white,
          surfaceContainerLow: backgroundColor,
          surfaceContainer: const Color(0xFFF4F6F8),
          surfaceContainerHigh: const Color(0xFFEFF2F4),

          outline: const Color(0xFFD9E0E5),
          outlineVariant: borderColor,

          error: errorColor,
          onError: Colors.white,
        ),
    scaffoldBackgroundColor: backgroundColor,

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF172027),
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,

      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    ),

    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: borderColor),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD9E0E5)),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD9E0E5)),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,

        minimumSize: const Size(double.infinity, 54),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

        textStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),

    dividerTheme: const DividerThemeData(color: borderColor, thickness: 1),
  );

  // =========================
  // Dark Theme
  // =========================

  static const Color darkBackgroundColor = Color(0xFF0A1520);
  static const Color darkSurfaceColor = Color(0xFF101F2E);
  static const Color darkSurfaceContainerColor = Color(0xFF16293A);
  static const Color darkBorderColor = Color(0xFF26394A);
  static const Color darkPrimaryColor = Color(0xFF5AC8E0);
  static const Color darkSecondaryColor = Color(0xFF7B93A8);
  static const Color darkTextColor = Color(0xFFE8F1F5);
  static const Color darkTextVariantColor = Color(0xFF93A5B3);
  static const Color darkErrorColor = Color(0xFFFF7A7A);
  static const Color darkSuccessColor = Color(0xFF70D6A0);

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Cairo',
    colorScheme: ColorScheme.dark(
      brightness: Brightness.dark,
      primary: darkPrimaryColor,
      onPrimary: darkBackgroundColor,
      secondary: darkSecondaryColor,
      onSecondary: darkBackgroundColor,
      primaryContainer: darkSurfaceContainerColor,
      onPrimaryContainer: darkTextColor,
      surface: darkSurfaceColor,
      onSurface: darkTextColor,
      onSurfaceVariant: darkTextVariantColor,
      surfaceContainerLowest: darkBackgroundColor,
      surfaceContainerLow: darkSurfaceColor,
      surfaceContainer: darkSurfaceContainerColor,
      surfaceContainerHigh: darkBorderColor,
      surfaceContainerHighest: darkBorderColor,
      outline: darkBorderColor,
      outlineVariant: darkBorderColor,
      tertiary: darkSuccessColor,
      onTertiary: darkBackgroundColor,
      error: darkErrorColor,
      onError: darkBackgroundColor,
    ),
    scaffoldBackgroundColor: darkBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurfaceColor,
      foregroundColor: darkTextColor,
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: darkSurfaceColor,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    cardTheme: CardThemeData(
      color: darkSurfaceColor,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: darkBorderColor),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkPrimaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: darkPrimaryColor,
        foregroundColor: darkBackgroundColor,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: darkPrimaryColor,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: darkPrimaryColor,
      foregroundColor: darkBackgroundColor,
    ),
    dividerTheme: const DividerThemeData(color: darkBorderColor, thickness: 1),
  );
}
