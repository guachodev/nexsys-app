import 'package:flutter/material.dart';
import 'package:nexsys_app/core/constants/constants.dart';

class ItemInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subvalue;
  final Color? color;
  final VoidCallback? onTap;
  final bool highlightValue;

  const ItemInfo({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.subvalue,
    this.highlightValue = false,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = color ?? Colors.blue.shade600;

    return AnimatedContainer(
      duration: AppDesignTokens.animationShort,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accentColor,
                 borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blueGrey,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: highlightValue ? 20 : 16,
                      fontWeight: highlightValue
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: Colors.grey.shade800,
                      height: subvalue != null ? 0.7 : 0,
                    ),
                  ),
                  ?subvalue != null
                      ? Text(subvalue!, style:  TextStyle(fontSize: 14,color: Colors.grey.shade600))
                      : null,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
