import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Palette — inspired by fire, wood, and midnight ambience
  static const Color backgroundDark = Color(0xFF0A0A0F);
  static const Color backgroundMid = Color(0xFF12121A);
  static const Color backgroundCard = Color(0xFF1A1A26);
  static const Color surfaceGlass = Color(0x1AFFFFFF);

  static const Color emberOrange = Color(0xFFFF6B35);
  static const Color amberGold = Color(0xFFFFA500);
  static const Color warmCream = Color(0xFFFFF8E7);
  static const Color softWhite = Color(0xFFEAE4D8);
  static const Color mutedGray = Color(0xFF6B6880);
  static const Color deepSlate = Color(0xFF2D2B3D);

  static const Gradient fireGradient = LinearGradient(
    colors: [Color(0xFFFF4500), Color(0xFFFF8C00), Color(0xFFFFD700)],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  static const Gradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E1B2E), Color(0xFF252237)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient sceneSelectorGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: const TextStyle(
          color: warmCream,
          fontSize: 48,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.5,
        ),
        displayMedium: const TextStyle(
          color: warmCream,
          fontSize: 36,
          fontWeight: FontWeight.w600,
          letterSpacing: -1,
        ),
        headlineLarge: const TextStyle(
          color: warmCream,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        headlineMedium: const TextStyle(
          color: warmCream,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: const TextStyle(
          color: warmCream,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: const TextStyle(
          color: softWhite,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: const TextStyle(
          color: softWhite,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: const TextStyle(
          color: amberGold,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
        labelMedium: const TextStyle(
          color: mutedGray,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
      ).apply(bodyColor: softWhite, displayColor: warmCream),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: emberOrange,
        inactiveTrackColor: deepSlate,
        thumbColor: amberGold,
        overlayColor: amberGold.withAlpha(30),
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),
      iconTheme: const IconThemeData(color: softWhite, size: 24),
      dividerColor: deepSlate,
      useMaterial3: true,
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: warmCream,
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: const TextStyle(
          color: deepSlate,
          fontSize: 48,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.5,
        ),
        displayMedium: const TextStyle(
          color: deepSlate,
          fontSize: 36,
          fontWeight: FontWeight.w600,
          letterSpacing: -1,
        ),
        headlineLarge: const TextStyle(
          color: deepSlate,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        headlineMedium: const TextStyle(
          color: deepSlate,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: const TextStyle(
          color: deepSlate,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: const TextStyle(
          color: backgroundCard,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: const TextStyle(
          color: backgroundCard,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: const TextStyle(
          color: amberGold, // Amber pops on light too
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
        labelMedium: const TextStyle(
          color: mutedGray,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
      ).apply(bodyColor: backgroundCard, displayColor: deepSlate),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: backgroundDark),
        titleTextStyle: TextStyle(
          color: backgroundDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: emberOrange,
        inactiveTrackColor: softWhite,
        thumbColor: amberGold,
        overlayColor: amberGold.withAlpha(30),
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),
      iconTheme: const IconThemeData(color: backgroundDark, size: 24),
      dividerColor: surfaceGlass, // using surfaceGlass as subtle divider
      useMaterial3: true,
    );
  }
}
