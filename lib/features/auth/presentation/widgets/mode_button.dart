import 'package:flutter/material.dart';
import 'package:nexsys_app/core/theme/theme.dart';

class ModeButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool selected;
  final bool isFirst;
  final Function()? onTap;

  const ModeButton({
    super.key,
    required this.text,
    required this.icon,
    required this.selected,
    required this.isFirst,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            //borderRadius: BorderRadius.circular(6),
            borderRadius: _getBorderRadius(isFirst),
            color: selected ? AppColors.primary : Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: selected ? Colors.white : Colors.grey.shade700,
              ),
              SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BorderRadius _getBorderRadius(bool isFirst) {
    if (selected && isFirst) {
      return BorderRadius.only(
        topLeft: Radius.circular(8),
        bottomLeft: Radius.circular(8),
      );
    } else {
      return BorderRadius.only(
        topRight: Radius.circular(8),
        bottomRight: Radius.circular(8),
      );
    }
  }
}
