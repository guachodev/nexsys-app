import 'package:flutter/material.dart';

class Notifications {
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
    IconData icon = Icons.info_outline,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  Text(
                    message,
                    style: TextStyle(color: textColor, fontSize: 14),
                  ),
                ],
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

  static void info(BuildContext context, String message) {
    show(
      context,
      message: message,
      backgroundColor: Colors.blue.shade600,
      icon: Icons.info_outline_rounded,
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

 static  Future<void> showTopSnackbar(BuildContext context, String message) async {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => Positioned(
      top: 50,
      left: 16,
      right: 16,
      child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.import_contacts, color:Colors.white, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      //color: widget.textColor,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),),
    ),
  );

  overlay.insert(entry);

  await Future.delayed(const Duration(seconds: 8));
  entry.remove();
}

}
