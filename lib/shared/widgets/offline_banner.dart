import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  final bool top;
  final bool bottom;

  const OfflineBanner({
    super.key,
    this.top = false,
    this.bottom = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      margin: EdgeInsets.only(
        top: top ? 12 : 0,
        bottom: bottom ? 12 : 0,
      ),
      decoration: BoxDecoration(
        color: Colors.red.shade100.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade300, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade200.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              "Sin conexión a internet",
              style: TextStyle(
                color: Colors.red,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
