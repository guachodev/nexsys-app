import 'package:flutter/material.dart';
import 'package:nexsys_app/core/theme/app_colors.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary.shade600,
                    ),
                    strokeWidth: 6,
                  ),
                ),
                Icon(
                  Icons.water_drop_outlined, // Puedes cambiar por otro ícono
                  size: 70,
                  color: AppColors.primary,
                ),
              ],
            ),
            SizedBox(height: 30),
            Text(
              "Cargando lecturas de agua potable.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary[800],
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Por favor, espere…",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),

            //SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
