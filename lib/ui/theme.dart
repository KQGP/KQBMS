import 'package:flutter/material.dart';

class AppTheme {
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF1C1C1E);
  static const Color darkSystemBlue = Color(0xFF0A84FF);
  static const Color darkSystemGreen = Color(0xFF30D158);
  static const Color darkSystemRed = Color(0xFFFF453A);
  static const Color darkSystemOrange = Color(0xFFFF9F0A);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xCCEBEBF5);
  static const Color darkTextTertiary = Color(0x99EBEBF5);

  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF2F2F7);
  static const Color lightSystemBlue = Color(0xFF007AFF);
  static const Color lightSystemGreen = Color(0xFF34C759);
  static const Color lightSystemRed = Color(0xFFFF3B30);
  static const Color lightSystemOrange = Color(0xFFFF9500);
  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightTextSecondary = Color(0x993C3C43);
  static const Color lightTextTertiary = Color(0x4D3C3C43);

  static const Color systemGrey = Color(0xFF8E8E93);
  static const Color systemGrey2 = Color(0xFF636366);
  static const Color systemGrey3 = Color(0xFF48484A);
  static const Color systemGrey4 = Color(0xFF3A3A3C);
  static const Color systemGrey5 = Color(0xFF2C2C2E);
  static const Color systemGrey6 = Color(0xFF1C1C1E);

  static const Color lightSystemGrey3 = Color(0xFFC7C7CC);
  static const Color lightSystemGrey4 = Color(0xFFD1D1D6);
  static const Color lightSystemGrey5 = Color(0xFFE5E5EA);
  static const Color lightSystemGrey6 = Color(0xFFF2F2F7);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: darkSystemBlue,
      colorScheme: const ColorScheme.dark(
        primary: darkSystemBlue,
        secondary: darkSystemGreen,
        surface: darkSurface,
        error: darkSystemRed,
      ),
      useMaterial3: true,
      cardTheme: CardThemeData(
        color: darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      primaryColor: lightSystemBlue,
      colorScheme: const ColorScheme.light(
        primary: lightSystemBlue,
        secondary: lightSystemGreen,
        surface: lightSurface,
        error: lightSystemRed,
      ),
      useMaterial3: true,
      cardTheme: CardThemeData(
        color: lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }

  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color getBackground(BuildContext context) {
    return isDark(context) ? darkBackground : lightBackground;
  }

  static Color getSurface(BuildContext context) {
    return isDark(context) ? darkSurface : lightSurface;
  }

  static Color getPrimary(BuildContext context) {
    return isDark(context) ? darkSystemBlue : lightSystemBlue;
  }

  static Color getSuccess(BuildContext context) {
    return isDark(context) ? darkSystemGreen : lightSystemGreen;
  }

  static Color getError(BuildContext context) {
    return isDark(context) ? darkSystemRed : lightSystemRed;
  }

  static Color getWarning(BuildContext context) {
    return isDark(context) ? darkSystemOrange : lightSystemOrange;
  }

  static Color getTextPrimary(BuildContext context) {
    return isDark(context) ? darkTextPrimary : lightTextPrimary;
  }

  static Color getTextSecondary(BuildContext context) {
    return isDark(context) ? darkTextSecondary : lightTextSecondary;
  }

  static Color getTextTertiary(BuildContext context) {
    return isDark(context) ? darkTextTertiary : lightTextTertiary;
  }

  static Color getGlassColor(BuildContext context) {
    return isDark(context) ? systemGrey6 : lightSystemGrey6;
  }

  static Color getGlassBorder(BuildContext context) {
    return isDark(context)
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.05);
  }

  static Color getDividerColor(BuildContext context) {
    return isDark(context) ? Colors.white10 : Colors.black12;
  }

  static TextStyle largeTitleStyle(BuildContext context) => TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.bold,
    fontFamily: 'Roboto',
    color: getTextPrimary(context),
    letterSpacing: 0.37,
  );

  static TextStyle title2Style(BuildContext context) => TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    fontFamily: 'Roboto',
    color: getTextPrimary(context),
    letterSpacing: 0.35,
  );

  static TextStyle headlineStyle(BuildContext context) => TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    fontFamily: 'Roboto',
    color: getTextPrimary(context),
    letterSpacing: -0.41,
  );

  static TextStyle bodyStyle(BuildContext context) => TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    fontFamily: 'Roboto',
    color: getTextPrimary(context),
    letterSpacing: -0.41,
  );

  static TextStyle largeValueStyle(BuildContext context) => TextStyle(
    fontSize: 42,
    fontWeight: FontWeight.w300,
    fontFamily: 'Roboto',
    color: getTextPrimary(context),
  );

  static TextStyle labelStyle(BuildContext context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: 'Roboto',
    color: getTextSecondary(context),
  );

  static TextStyle unitStyle(BuildContext context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontFamily: 'Roboto',
    color: getTextSecondary(context),
  );
}
