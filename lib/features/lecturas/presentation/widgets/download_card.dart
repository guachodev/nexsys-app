import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexsys_app/core/utils/utils.dart';
import 'package:nexsys_app/features/lecturas/presentation/presentation.dart';

class DownloadCard extends ConsumerWidget {
  final WidgetRef ref;
  final int periodoId;
  final bool hasInternet;
  const DownloadCard({
    required this.ref,
    super.key,
    required this.periodoId,
    required this.hasInternet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.amber[700]),
              const SizedBox(width: 8),
              const Text(
                "Descargar medidores asignados",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Descarga los medidores asignados para comenzar a registrar lecturas y trabajar sin conexión.",
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text("Descargar"),
              onPressed: () async {
                if (!hasInternet) {
                  Loader.openInfoRed(
                    context,
                    "Para poder descargar las los medidores asignados, por favor conéctate a una red Wi-Fi o de datos móviles.",
                  );
                  return;
                }

                Loader.openDowloadLecturas(context);

                await ref
                    .read(descargaLecturasProvider.notifier)
                    .descargarLecturas(periodoId.toString());

                Future.microtask(() {
                  ref.read(rutasProvider.notifier).cargarRutas();
                  ref.read(periodoProvider.notifier).marcarDescargado();
                  //ref.read(periodoProvider.notifier).refreshAvance();
                });

                if (!context.mounted) return;
                Loader.stopLoading(context);
                Notifications.success(context, 'Se descargaron correctamente.');
              },
            ),
          ),
        ],
      ),
    );
  }
}
