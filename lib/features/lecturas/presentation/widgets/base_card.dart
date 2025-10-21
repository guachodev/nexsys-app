import 'package:flutter/material.dart';
import 'package:nexsys_app/core/constants/constants.dart';

class BaseCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final bool withShadow;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const BaseCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.withShadow = true,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: AppDesignTokens.borderRadiusMedium,
        boxShadow: withShadow ? [AppDesignTokens.shadowSmall] : null,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppDesignTokens.borderRadiusMedium,
          child: Padding(
            padding: padding ?? AppDesignTokens.paddingMedium,
            child: child,
          ),
        ),
      ),
    );
  }
}