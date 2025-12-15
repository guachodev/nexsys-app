import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool obscure;
  final TextEditingController controller;

  const CustomTextField({
    super.key,
    required this.label,
    this.icon,
    this.obscure = false,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        SizedBox(height: 2),
        TextField(
          obscureText: obscure,
          controller: controller,
          decoration: InputDecoration(
            suffixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
            
            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 14),
            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
          ),
        ),
      ],
    );
  }
}
