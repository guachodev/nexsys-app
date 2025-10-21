import 'package:flutter/material.dart';

class AppDesignTokens {
  // Border Radius
  static const BorderRadius borderRadiusSmall = BorderRadius.all(
    Radius.circular(8),
  );
  static const BorderRadius borderRadiusMedium = BorderRadius.all(
    Radius.circular(12),
  );
  static const BorderRadius borderRadiusLarge = BorderRadius.all(
    Radius.circular(16),
  );

  // Padding
  static const EdgeInsets paddingSmall = EdgeInsets.all(8);
  static const EdgeInsets paddingMedium = EdgeInsets.all(12);
  static const EdgeInsets paddingLarge = EdgeInsets.all(16);

  // Spacing
  static const double spacingXS = 4;
  static const double spacingS = 8;
  static const double spacingM = 12;
  static const double spacingL = 16;
  static const double spacingXL = 24;

  // Shadows
  static final BoxShadow shadowSmall = BoxShadow(
    color: Colors.black.withValues(alpha: 0.1),
    blurRadius: 4,
    offset: const Offset(0, 2),
  );

  static final BoxShadow shadowMedium = BoxShadow(
    color: Colors.black.withValues(alpha: 0.15),
    blurRadius: 8,
    offset: const Offset(0, 4),
  );

  // Animations
  static const Duration animationShort = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
}
