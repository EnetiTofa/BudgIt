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
      secondary: Color.fromARGB(255, 85, 92, 100),
      onSecondary: Colors.white,
      tertiary: Color.fromARGB(255, 105, 112, 120),
      onTertiary: Colors.white,
      error: Colors.redAccent,
      onError: Colors.white,
      outline: Color(0xFF495057),
      outlineVariant: Color(0xFFCED4DA),
      surface: Colors.white,
      onSurface: Color(0xFF212529),
      surfaceDim: Color.fromARGB(255, 245, 245, 245),
      surfaceBright: Color(0xFFFFFFFF),
      surfaceContainerLowest: Color(0xFFFAFAFA),
      surfaceContainerLow: Color.fromARGB(255, 239, 241, 243),
      surfaceContainer: Color.fromARGB(255, 229, 231, 233),
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
    bottomAppBarTheme: const BottomAppBarThemeData(
      color: Color(0xFFFAFAFA),
      elevation: 0,
    ),
    // --- CORRECTED CLASS NAME ---
    dialogTheme: DialogThemeData(
      backgroundColor: const Color.fromARGB(255, 239, 241, 243), // surfaceContainerLow
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: const TextStyle(
        fontFamily: 'Outfit',
        color: Color(0xFF212529), // onSurface
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF212529), // onSurface
      contentTextStyle: const TextStyle(color: Colors.white).copyWith(fontWeight: FontWeight.w600), // surface
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
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
      secondary: Color.fromARGB(255, 158, 162, 165),
      onSecondary: Colors.white,
      tertiary: Color.fromARGB(255, 79, 85, 92),
      onTertiary: Colors.black,
      error: Colors.redAccent,
      onError: Colors.black,
      outline: Color(0xFF8A939A),
      outlineVariant: Color(0xFF495057),
      surface: Color(0xFF121212),
      onSurface: Colors.white,
      surfaceDim: Color.fromARGB(255, 15, 15, 15),
      surfaceBright: Color(0xFF363636),
      surfaceContainerLowest: Color.fromARGB(255, 21, 22, 23),
      surfaceContainerLow: Color.fromARGB(255, 24, 25, 26),
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
    bottomAppBarTheme: const BottomAppBarThemeData(
      color: Color.fromARGB(255, 15, 15, 15),
      elevation: 0,
    ),
    // --- CORRECTED CLASS NAME ---
    dialogTheme: DialogThemeData(
      backgroundColor: const Color.fromARGB(255, 24, 25, 26), // surfaceContainerLow
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: const TextStyle(
        fontFamily: 'Outfit',
        color: Colors.white, // onSurface
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.white, // onSurface
      contentTextStyle: TextStyle(color: Color(0xFF121212)).copyWith(fontWeight: FontWeight.w600), // surface
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
    ),
  );
}