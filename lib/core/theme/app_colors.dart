import 'package:flutter/material.dart';

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  final swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }

  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }

  return MaterialColor(color.value, swatch);
}

class AppColors {
  // Paleta principal
  //static const primary = Color(0xFF4CAF50);
 /*  static const MaterialColor primary = MaterialColor(0xFF007AFF, <int, Color>{
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
  }); */

  static const MaterialColor primary =   MaterialColor(
  0xFF0066DD,
  <int, Color>{
    50:  Color(0xFFE7F0FF),
    100: Color(0xFFC3DAFF),
    200: Color(0xFF9DC2FF),
    300: Color(0xFF76AAFF),
    400: Color(0xFF5596FF),
    500: Color(0xFF3382FF),
    600: Color(0xFF1D72F5),
    700: Color(0xFF0A63E6),
    800: Color(0xFF0054C2),
    900: Color(0xFF003F8F),
  },
);


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
