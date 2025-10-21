import 'package:flutter/material.dart';

class AppColors {
  // Paleta principal
  //static const primary = Color(0xFF4CAF50);
  static const MaterialColor primary = MaterialColor(0xFF007AFF, <int, Color>{
    50: Color(0xFFEFF6FF),
    100: Color(0xFFD6EEFF),
    200: Color(0xFFBEE4FF),
    300: Color(0xFF90D7FF),
    400: Color(0xFF62C9FF),
    500: Color(0xFF007AFF),
    600: Color(0xFF0066DD),
    700: Color(0xFF0051B5),
    800: Color(0xFF003C8F),
    900: Color(0xFF002E6B),
  });

  static const secondary = Color(0xFFFFC107);
  static const accent = Color(0xFF03A9F4);

  static const backgroundLight = Color(0xFFf2f3f6);
  static const surfaceLight = Colors.white;

  static const backgroundDark = Color(0xFF121213);
  static const surfaceDark = Color(0xFF1F1F21);

  // Estados
  static const success = Color(0xFF34C759);
  static const error = Color(0xFFFF3B30);
  static const warning = Color(0xFFFF9500);

  // Fondo y texto
  static const background = Color(0xFFF5F5F5);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
}
