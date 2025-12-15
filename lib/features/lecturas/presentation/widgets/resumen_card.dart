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
    final color = pendientes > 0 ? AppColors.primary : Colors.green;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
       
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Resumen de avance",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
      
          const SizedBox(height: 4),
      
          // ---------- MENSAJE SI YA COMPLETÓ ----------
          if (progreso >= 100)
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 14,
              ),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.celebration_rounded,
                    color: Colors.amber.shade600,
                    size: 32,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "¡Excelente trabajo! Has completado el 100% del avance.",
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
      
          if (progreso >= 100) const SizedBox(height: 18),
      
          // ---------- DATOS PRINCIPALES ----------
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _statLine("Total asignados", total.toString()),
                    _statLine("Leídos", leidos.toString()),
                    _statLine("Pendientes", pendientes.toString()),
      
                    const SizedBox(height: 14),
                    LinearProgressIndicator(
                      value: progreso / 100,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(10),
                      backgroundColor: Colors.grey.shade200,
                      color: color,
                    ),
                    // ---------- BARRA DE PROGRESO MODERNA ----------
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CircularProgressIndicator(
                      value: progreso / 100,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                  Text(
                    progreso >= 100
                        ? "${progreso.toStringAsFixed(0)}%"
                        : "${progreso.toStringAsFixed(1)}%",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _statLine(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        Text(
          "$label:",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 15,
          ),
        ),
      ],
    ),
  );
}
