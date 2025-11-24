import 'package:flutter/material.dart';

class BarApp extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading; // Icono o botón a la izquierda
  final List<Widget>? actions; // Botones a la derecha
  final Color backgroundColor;
  final bool centerTitle;

  const BarApp({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.backgroundColor = Colors.white,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
      elevation: 1,
      leading: leading,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
