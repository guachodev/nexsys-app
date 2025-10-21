import 'package:flutter/material.dart';


class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final Color? primaryColor;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = primaryColor ?? Colors.blue.shade600;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
              height: 1.5,
            ),
          ),   
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
              height: .9,
            ),
          ),
          if (subtitle != null) ...[
            //const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 11,
                color: Colors.black45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}