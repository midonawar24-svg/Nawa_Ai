import 'package:flutter/material.dart';

class AppTheme {
  // Master V1 Colors - Deep Black + Neon
  static const deepBlack = Color(0xFF050507);
  static const deepBlack2 = Color(0xFF0A0A0F);
  static const deepBlack3 = Color(0xFF11111A);
  
  static const cyanNeon = Color(0xFF00D9FF);
  static const blueNeon = Color(0xFF6366F1);
  static const purpleNeon = Color(0xFF7C3AED);
  static const purpleGlow = Color(0xFF8B5CF6);
  
  static const glassBg = Color(0x1AFFFFFF); // 10% white
  static const glassBorder = Color(0x0FFFFFFF); // 6% white
  static const glassBgStrong = Color(0x26FFFFFF); // 15% white
  
  // Engine colors
  static const memoryIndigo = Color(0xFF6366F1);
  static const knowledgeEmerald = Color(0xFF10B981);
  static const decisionAmber = Color(0xFFF59E0B);
  static const searchCyan = Color(0xFF06B6D4);
  static const systemSlate = Color(0xFF64748B);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: deepBlack,
      colorScheme: const ColorScheme.dark(
        primary: cyanNeon,
        secondary: purpleNeon,
        surface: deepBlack2,
        background: deepBlack,
        error: Color(0xFFEF4444),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: glassBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: glassBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: glassBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: cyanNeon, width: 1.2),
        ),
      ),
    );
  }

  static BoxDecoration get glassDecoration {
    return BoxDecoration(
      color: glassBg,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: glassBorder, width: 1),
    );
  }

  static BoxDecoration glassDecorationWithRadius(double radius) {
    return BoxDecoration(
      color: glassBg,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: glassBorder, width: 1),
    );
  }

  static BoxDecoration get neonGlow {
    return BoxDecoration(
      boxShadow: [
        BoxShadow(color: cyanNeon.withOpacity(0.3), blurRadius: 20, spreadRadius: 0),
        BoxShadow(color: purpleNeon.withOpacity(0.2), blurRadius: 40, spreadRadius: 0),
      ],
    );
  }
}
