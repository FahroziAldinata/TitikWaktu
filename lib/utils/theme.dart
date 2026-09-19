import 'package:flutter/material.dart';
import 'package:titik_waktu/theme/app_colors.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightTextPrimary,
      onPrimary: AppColors.lightSurface,
      primaryContainer: Color(0xFFF0EFEA),
      onPrimaryContainer: AppColors.lightTextPrimary,
      secondary: AppColors.lightTextPrimary,
      onSecondary: AppColors.lightSurface,
      secondaryContainer: Color(0xFFF0EFEA),
      onSecondaryContainer: AppColors.lightTextPrimary,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
      surfaceContainerHighest: Color(0xFFF2F1ED),
      onSurfaceVariant: AppColors.lightTextSecondary,
      outline: AppColors.lightBorder,
      outlineVariant: AppColors.lightBorder,
      error: Colors.redAccent,
      onError: Colors.white,
      errorContainer: Color(0xFFFDE8E8),
      onErrorContainer: Color(0xFF9B1C1C),
      tertiaryContainer: Color(0xFFEBEAE5),
      onTertiaryContainer: AppColors.lightTextSecondary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBackground,
      foregroundColor: AppColors.lightTextPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      iconTheme: IconThemeData(
        color: AppColors.lightTextPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.lightSurface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: AppColors.lightBorder,
          width: 0.5,
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.lightTextPrimary,
      foregroundColor: AppColors.lightBackground,
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
      shape: CircleBorder(),
      sizeConstraints: BoxConstraints.tightFor(
        width: 44,
        height: 44,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: false,
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.lightBorder, width: 1),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.lightBorder, width: 1),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.lightTextPrimary, width: 1.5),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      labelStyle: TextStyle(color: AppColors.lightTextSecondary, fontSize: 14),
      hintStyle: TextStyle(color: AppColors.lightTextSecondary, fontSize: 14),
      contentPadding: EdgeInsets.symmetric(vertical: 8),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.lightBorder,
      thickness: 0.5,
      space: 1,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 38,
        fontWeight: FontWeight.w500,
        color: AppColors.lightTextPrimary,
        letterSpacing: -0.5,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.lightTextPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.lightTextPrimary,
      ),
      bodySmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.lightTextSecondary,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkTextPrimary,
      onPrimary: AppColors.darkBackground,
      primaryContainer: Color(0xFF282723),
      onPrimaryContainer: AppColors.darkTextPrimary,
      secondary: AppColors.darkTextPrimary,
      onSecondary: AppColors.darkBackground,
      secondaryContainer: Color(0xFF282723),
      onSecondaryContainer: AppColors.darkTextPrimary,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      surfaceContainerHighest: Color(0xFF252420),
      onSurfaceVariant: AppColors.darkTextSecondary,
      outline: AppColors.darkBorder,
      outlineVariant: AppColors.darkBorder,
      error: Colors.redAccent,
      onError: Colors.white,
      errorContainer: Color(0xFF3B1212),
      onErrorContainer: Color(0xFFF87171),
      tertiaryContainer: Color(0xFF282723),
      onTertiaryContainer: AppColors.darkTextSecondary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.darkTextPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      iconTheme: IconThemeData(
        color: AppColors.darkTextPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: AppColors.darkBorder,
          width: 0.5,
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.darkTextPrimary,
      foregroundColor: AppColors.darkBackground,
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
      shape: CircleBorder(),
      sizeConstraints: BoxConstraints.tightFor(
        width: 44,
        height: 44,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: false,
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.darkBorder, width: 1),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.darkBorder, width: 1),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.darkTextPrimary, width: 1.5),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      labelStyle: TextStyle(color: AppColors.darkTextSecondary, fontSize: 14),
      hintStyle: TextStyle(color: AppColors.darkTextSecondary, fontSize: 14),
      contentPadding: EdgeInsets.symmetric(vertical: 8),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.darkBorder,
      thickness: 0.5,
      space: 1,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 38,
        fontWeight: FontWeight.w500,
        color: AppColors.darkTextPrimary,
        letterSpacing: -0.5,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.darkTextPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.darkTextPrimary,
      ),
      bodySmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.darkTextSecondary,
      ),
    ),
  );
}
