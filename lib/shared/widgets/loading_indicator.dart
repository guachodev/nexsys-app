import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nexsys_app/core/theme/app_colors.dart';

class LoadingIndicator extends StatefulWidget {
  final String title;
  final String subtitle;
  final Duration duration;

  const LoadingIndicator({
    super.key,
    this.title = "CARGANDO...",
    this.subtitle = "Downloading data...",
    this.duration = const Duration(seconds: 5),
  });

  @override
  State<LoadingIndicator> createState() => _AppLoadingIndicatorState();
}

class _AppLoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5), // Duración total de la animación
      vsync: this,
    )..repeat(); // Repetir para un efecto continuo
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 150,
            height: 150,
            child: Lottie.asset(
              'assets/animations/loading-oclock.json',
              repeat: true,
            ),
          ),
          // Ícono grande con gradiente
          /*Container(
            width: 160,
            height: 160,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.water_drop_rounded,
              size: 110,
              color: Colors.white,
            ),
          ),*/
          const SizedBox(height: 32),

          // Texto principal
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black45,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 220,
            child: LinearProgressIndicator(
              minHeight: 10,
              borderRadius: BorderRadius.circular(10),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              backgroundColor: Colors.grey.withValues(alpha: 0.3),
            ),
          ),

          // Barra de progreso animada
          const SizedBox(height: 16),

          // Texto secundario
          Text(
            widget.subtitle,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
