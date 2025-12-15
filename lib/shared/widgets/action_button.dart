import 'package:flutter/material.dart';
import 'package:nexsys_app/core/theme/theme.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const ActionButton({
    required this.icon,
    required this.text,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        borderRadius: BorderRadius.circular(10),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.58),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          splashColor: AppColors.primary.withValues(alpha: 0.1),
          highlightColor: AppColors.primary.withValues(alpha: 0.05),
          focusColor: Colors.white,
          hoverColor: Colors.white,
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: AppColors.primary.shade700, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      text,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.black45,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
