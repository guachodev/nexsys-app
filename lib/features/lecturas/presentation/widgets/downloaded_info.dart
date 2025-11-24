import 'package:flutter/material.dart';
import 'package:nexsys_app/core/theme/theme.dart';

class DownloadedInfo extends StatelessWidget {
  const DownloadedInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 30, color: AppColors.primary.shade400),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Medidores descargados localmente. \nPuedes trabajar sin conexión.",
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
