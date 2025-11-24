import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/periodo_provider.dart';

class AlertaSinAsignaciones extends StatelessWidget {
  final WidgetRef ref;
  const AlertaSinAsignaciones({required this.ref, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //SvgPicture.asset('assets/svg/addUsers.svg', height: 200),
              const SizedBox(height: 32),
              const Text("No hay período activo", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text("Por favor, espera a que se active un nuevo período de lecturas."),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: () => ref.read(periodoProvider.notifier).loadPeriodo(), child: const Text("Reintentar")),
            ],
          ),
        ),
      ),
    );
  }
}
