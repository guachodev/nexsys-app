import 'package:flutter/material.dart';
import 'package:nexsys_app/core/theme/theme.dart';

class CircularIconProgress extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;

  const CircularIconProgress({
    required this.icon,
    this.size = 120,
    this.color = AppColors.primary,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 6,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        Icon(icon, size: size * 0.58, color: color),
      ],
    );
  }
}
