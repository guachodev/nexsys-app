import 'package:flutter/material.dart';

class SnackbarService {
  static void show(
    BuildContext context, {
    required String message,
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
    IconData icon = Icons.info_outline,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        showCloseIcon: true,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin:  const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        content: Row(
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: textColor, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void success(BuildContext context, String message) {
    show(
      context,
      message: message,
      backgroundColor: Colors.green.shade600,
      icon: Icons.check_circle_outline,
    );
  }

  static void error(BuildContext context, String message) {
    show(
      context,
      message: message,
      backgroundColor: Colors.red.shade600,
      icon: Icons.error_outline,

    );
  }

  static void warning(BuildContext context, String message) {
    show(
      context,
      message: message,
      backgroundColor: Colors.orange.shade700,
      icon: Icons.warning_amber_rounded,
    );
  }

  static void info(BuildContext context, String message) {
    show(
      context,
      message: message,
      backgroundColor: Colors.blue.shade700,
      icon: Icons.warning_amber_rounded,
    );
  }
}
