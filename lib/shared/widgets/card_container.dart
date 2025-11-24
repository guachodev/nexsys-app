import 'package:flutter/material.dart';

class CardContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const CardContainer({required this.child, this.padding, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 6))
        ],
      ),
      child: child,
    );
  }
}
