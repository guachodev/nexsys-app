import 'package:flutter/material.dart';

class DownloadedInfo extends StatelessWidget {
  const DownloadedInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8, top: 8),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.indigo),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          Icon(Icons.info, size: 28, color: Colors.indigo.shade600),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Medidores descargados localmente. \nPuedes trabajar sin conexión.",
              style: TextStyle(color: Colors.indigo),
            ),
          ),
        ],
      ),
    );
  }
}
