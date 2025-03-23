import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.dark(
        background: const Color(0xFF181818),
        surface: const Color(0xFF222222),
        primary: const Color(0xFF21FF5F),
        secondary: const Color(0xFFFF5C01),
        tertiary: const Color(0xFFFFEE4A),
        onBackground: const Color(0xFFE1E1E1),
        onSurface: const Color(0xFFE1E1E1),
        onPrimary: const Color(0xFF181818),
        onSecondary: const Color(0xFFE1E1E1),
        onTertiary: const Color(0xFF181818),
      ),
      scaffoldBackgroundColor: const Color(0xFF181818),
      useMaterial3: true,
      textTheme: GoogleFonts.montserratAlternatesTextTheme(
        TextTheme(
          displayLarge: GoogleFonts.montserratAlternates(fontWeight: FontWeight.bold, fontSize: 32, color: const Color(0xFFE1E1E1)),
          displayMedium: GoogleFonts.montserratAlternates(fontWeight: FontWeight.bold, fontSize: 24, color: const Color(0xFFE1E1E1)),
          displaySmall: GoogleFonts.montserratAlternates(fontWeight: FontWeight.bold, fontSize: 20, color: const Color(0xFFE1E1E1)),
          headlineLarge: GoogleFonts.montserratAlternates(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFFE1E1E1)),
          headlineMedium: GoogleFonts.montserratAlternates(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFFE1E1E1)),
          headlineSmall: GoogleFonts.montserratAlternates(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFFE1E1E1)),
          bodyLarge: GoogleFonts.montserrat(fontSize: 16, color: const Color(0xFFE1E1E1)),
          bodyMedium: GoogleFonts.montserrat(fontSize: 14, color: const Color(0xFFE1E1E1)),
          bodySmall: GoogleFonts.montserrat(fontSize: 12, color: const Color(0xFFE1E1E1)),
          titleLarge: GoogleFonts.montserratAlternates(fontWeight: FontWeight.w600, fontSize: 18, color: const Color(0xFFE1E1E1)),
          titleMedium: GoogleFonts.montserratAlternates(fontWeight: FontWeight.w500, fontSize: 16, color: const Color(0xFFE1E1E1)),
          titleSmall: GoogleFonts.montserratAlternates(fontWeight: FontWeight.w400, fontSize: 14, color: const Color(0xFFE1E1E1)),
          labelLarge: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFFE1E1E1)),
          labelMedium: GoogleFonts.montserrat(fontWeight: FontWeight.w500, fontSize: 12, color: const Color(0xFFE1E1E1)),
          labelSmall: GoogleFonts.montserrat(fontWeight: FontWeight.normal, fontSize: 10, color: const Color(0xFFE1E1E1)),
        ).apply(
          bodyColor: const Color(0xFFE1E1E1),
          displayColor: const Color(0xFFE1E1E1),
        ),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF222222),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Helper method to get color based on health score
  static Color getHealthScoreColor(int score) {
    if (score >= 7) return Colors.green;
    if (score >= 4) return Colors.orange;
    return Colors.red;
  }
} 