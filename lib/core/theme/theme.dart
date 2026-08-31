import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF050505);
  static const Color cardBg = Color(0xFF101010);
  static const Color accent = Color(0xFFA3E635);
  static const Color accentDark = Color(0xFF4E7A06);
  static const Color textMain = Colors.white;
  static const Color textSubtle = Color(0xFFB3B3B3);
  static const Color goldAccent = Color(0xFFC7A43D);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: accent,
      cardColor: cardBg,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: textSubtle,
        surface: cardBg,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: Colors.white,
      ),
      dividerColor: Colors.white10,
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          color: textMain,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.outfit(
          color: textMain,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.outfit(
          color: textMain,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: GoogleFonts.outfit(
          color: textMain,
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.outfit(
          color: textSubtle,
          fontSize: 14,
          height: 1.4,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textMain,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
        iconTheme: IconThemeData(color: textMain),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textMain,
          side: const BorderSide(color: Colors.white24),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  // Helper styling methods
  static BoxDecoration glassBoxDecoration({
    Color color = Colors.white10,
    double radius = 24.0,
    double borderWidth = 1.0,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Colors.white10,
        width: borderWidth,
      ),
    );
  }

  static BoxDecoration accentGlowDecoration({
    Color glowColor = accent,
    double radius = 24.0,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: glowColor.withValues(alpha: 0.15),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ],
    );
  }
}
