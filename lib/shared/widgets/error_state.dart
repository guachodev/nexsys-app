import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class ErrorState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    this.title = "Ocurrió un error",
    this.subtitle = "No pudimos cargar la información.",
    this.icon = Icons.error_outline,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /* Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(20),
                ),
                child:  Center(
                  child: Icon(icon, size: 100, color: Colors.redAccent),
                ),
              ), */
            Tada(child: Icon(icon, size: 120, color: Colors.redAccent)),
            const SizedBox(height: 30),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            if (onRetry != null)
              SizedBox(
                width: 180,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Reintentar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
