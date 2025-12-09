import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;

  final colorScheme = ColorScheme(
    brightness: brightness,
    primary: isDark ? const Color(0xFF7C9EFF) : const Color(0xFF2D6AE3),
    onPrimary: Colors.white,
    secondary: isDark ? const Color(0xFF87E6A6) : const Color(0xFF1FBF75),
    onSecondary: Colors.white,
    error: const Color(0xFFEF5350),
    onError: Colors.white,
    surface: isDark ? const Color(0xFF121212) : Colors.white,
    onSurface: isDark ? const Color(0xFFECECEC) : const Color(0xFF1E1E1E),
    tertiary: isDark ? const Color(0xFFB0B0B0) : const Color(0xFF6B7280),
    onTertiary: isDark ? const Color(0xFF121212) : Colors.white,
  );

  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(fontWeight: FontWeight.w700),
      titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w600),
      bodyMedium: GoogleFonts.inter(),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: true,
    ),
    scaffoldBackgroundColor: colorScheme.surface,
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFF111827),
      contentTextStyle: TextStyle(color: Colors.white),
    ),
  );
}
