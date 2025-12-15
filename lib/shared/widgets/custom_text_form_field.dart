import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatelessWidget {
  final String? label;
  final String? hintText;
  final String? errorMessage;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? initialValue; // <- ahora es nullable
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final bool? floating;
  final TextEditingController? controller;

  const CustomTextFormField({
    super.key,
    this.label,
    this.hintText,
    this.errorMessage,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.initialValue, // ← quitar default '' para permitir null
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLength,
    this.inputFormatters,
    this.autofocus = false,
    this.floating = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null, // ← FIX
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      autofocus: autofocus,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      maxLines: maxLines,
      decoration: InputDecoration(
        floatingLabelBehavior: maxLines > 1 || floating == true
            ? FloatingLabelBehavior.always
            : FloatingLabelBehavior.auto,
        label: label != null ? Text(label!) : null,
        hintText: hintText,
        errorText: errorMessage,
        focusColor: colors.primary,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
      ),
    );
  }
}
