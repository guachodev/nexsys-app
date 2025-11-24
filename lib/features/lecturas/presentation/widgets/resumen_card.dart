import 'package:flutter/material.dart';
import 'package:nexsys_app/core/theme/theme.dart';

class ResumenCard extends StatelessWidget {
  final int total, leidos, pendientes;
  final double progreso;

  const ResumenCard({
    required this.total,
    required this.leidos,
    required this.pendientes,
    required this.progreso,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    print('$total $leidos $pendientes $progreso');
    final color = pendientes > 0 ? AppColors.primary : Colors.green;

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      shadowColor: color.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Resumen del Día",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total asignados: $total'),
                      Text('Leídos: $leidos'),
                      Text('Pendientes: $pendientes'),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: progreso / 100,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(10),
                        backgroundColor: Colors.grey.shade200,
                        color: color,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: progreso / 100,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                    Text(
                      '${(progreso).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
