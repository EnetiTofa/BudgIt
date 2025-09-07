import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._(); // This class is not meant to be instantiated.

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Outfit',
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF1E1F20),
      onPrimary: Colors.white,
      secondary: Color(0xFF495057),
      onSecondary: Colors.white,
      tertiary: Color.fromARGB(255, 105, 112, 120),
      onTertiary: Colors.white,
      error: Color(0xFFD32F2F),
      onError: Colors.white,
      outline: Color(0xFF495057),
      outlineVariant: Color(0xFFCED4DA),
      surface: Colors.white,
      onSurface: Color(0xFF212529),
      surfaceDim: Color(0xFFE5E5E5),
      surfaceBright: Color(0xFFFFFFFF),
      surfaceContainerLowest: Color(0xFFFAFAFA),
      surfaceContainerLow: Color(0xFFF3F5F7),
      surfaceContainer: Color(0xFFF1F3F5),
      surfaceContainerHigh: Color(0xFFE9ECEF),
      surfaceContainerHighest: Color(0xFFDEE2E6),
      onSurfaceVariant: Color(0xFF6C757D),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Outfit',
        color: Color(0xFF1E1F20),
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(
        color: Color(0xFF212529),
      ),
    ),
    bottomAppBarTheme: const BottomAppBarTheme(
      color: Color(0xFFFAFAFA),
      elevation: 0,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Outfit',
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFE9ECEF),
      onPrimary: Colors.black,
      secondary: Color(0xFF6C757D),
      onSecondary: Colors.white,
      tertiary: Color.fromARGB(255, 79, 85, 92),
      onTertiary: Colors.black,
      error: Color(0xFFCF6679),
      onError: Colors.black,
      outline: Color(0xFF8A939A),
      outlineVariant: Color(0xFF495057),
      surface: Color(0xFF121212),
      onSurface: Colors.white,
      surfaceDim: Color(0xFF101010),
      surfaceBright: Color(0xFF363636),
      surfaceContainerLowest: Color(0xFF161718),
      surfaceContainerLow: Color(0xFF191A1B),
      surfaceContainer: Color(0xFF232425),
      surfaceContainerHigh: Color(0xFF2D2E2F),
      surfaceContainerHighest: Color(0xFF38393A),
      onSurfaceVariant: Color(0xFFADB5BD),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Outfit',
        color: Color(0xFFE9ECEF),
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),
    bottomAppBarTheme: const BottomAppBarTheme(
      color: Color.fromARGB(255, 15, 15, 15),
      elevation: 0,
    ),
  );
}