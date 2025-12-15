import 'package:flutter/material.dart';
import 'package:nexsys_app/core/theme/app_colors.dart';

class NoMedidoresCard extends StatelessWidget {
  const NoMedidoresCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8, top: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // SVG / Icon
          SizedBox(
            //height: height,
            child: Center(
              child: Icon(
                Icons.water_drop_rounded,
                size: 80,
                color: AppColors.primary,
              ),
            ),
          ),
      
          const SizedBox(height: 12),
      
          // Título
          Text(
            'Sin medidores asignados',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
      
          const SizedBox(height: 6),
      
          // Subtítulo
          Text(
            'No hay medidores vinculados a este lector para el período actual.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
