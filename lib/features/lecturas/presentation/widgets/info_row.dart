import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LABEL (ancho mínimo)
          ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 97, // ajusta según tu diseño
            ),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(value, softWrap: true, overflow: TextOverflow.visible),
          ),
        ],
      ),
    );
  }
}
