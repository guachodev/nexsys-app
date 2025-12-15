import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexsys_app/core/constants/enums.dart';
import 'package:nexsys_app/core/providers/providers.dart';
import 'package:nexsys_app/core/utils/utils.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';
import 'package:nexsys_app/features/lecturas/presentation/presentation.dart';
import 'package:nexsys_app/shared/widgets/widgets.dart';

class SincronizarScreen extends ConsumerStatefulWidget {
  const SincronizarScreen({super.key});

  @override
  ConsumerState<SincronizarScreen> createState() => _SincronizarScreenState();
}

class _SincronizarScreenState extends ConsumerState<SincronizarScreen> {
  @override
  void initState() {
    super.initState();

    // 🔹 Cargar lecturas pendientes automáticamente al entrar a la pantalla
    Future.microtask(() {
      ref.read(lecturasLocalProvider.notifier).cargarLecturasNoSincronizados();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasInternet = ref.watch(networkProvider).value ?? false;
    final lecturasLocalState = ref.watch(lecturasLocalProvider);

    final lecturas = lecturasLocalState.lecturas
        .where((e) => e.sincronizado == false && e.registrado)
        .toList();

    return Scaffold(
      appBar: const BarApp(title: 'Sincronizar Lectura pendientes'),
      body:
          lecturasLocalState.status == SearchStatus.loading ||
              lecturasLocalState.status == SearchStatus.initial
          ? LoadingIndicator(subtitle: 'Cargando lectura pendientes espere un momento')
          : RefreshIndicator(
              onRefresh: () async => ref
                  .read(lecturasLocalProvider.notifier)
                  .cargarLecturasNoSincronizados(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: lecturas.isEmpty
                    ? _buildEmptyState()
                    : _buildListState(lecturas, hasInternet),
              ),
            ),
      bottomNavigationBar: lecturas.isEmpty || lecturasLocalState.status == SearchStatus.loading
          ? null
          : _buildBottomButton(context, lecturas, hasInternet),
    );
  }

  // 🔹 Vista cuando NO hay lecturas
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Tada(child: Icon(Icons.cloud_done_rounded, size: 90, color: Colors.green)),
            const SizedBox(height: 20),
            const Text(
              "Todo sincronizado",
              style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            ),
            const SizedBox(height: 10),
            Text(
            "No tienes lecturas pendientes de sincronizar",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
          ),
            
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  ref
                      .read(lecturasLocalProvider.notifier)
                      .cargarLecturasNoSincronizados();
                },
                child: const Text('Recargar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Vista cuando SÍ hay lecturas
  Widget _buildListState(List<Lectura> lecturas, bool hasInternet) {
    return Column(
      children: [
        if (!hasInternet) const OfflineBanner(bottom: true),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1.2),
          ),
          child: Row(
            children: [
              Icon(Icons.cloud_upload_rounded, color: Colors.blue.shade800),
              const SizedBox(width: 10),
              Text(
                "Pendientes: ${lecturas.length}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: lecturas.length,
            itemBuilder: (_, i) {
              final l = lecturas[i];
              return Card(
                elevation: 1,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(Icons.water_drop, color: Colors.blue.shade600),
                  ),
                  title: Text(
                    "Cuenta: ${l.cuenta}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "Lectura actual: ${l.lecturaActual}\nMedidor: ${l.medidor}\nId: ${l.id}",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  trailing: const Icon(Icons.sync, color: Colors.orange),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 🔹 Botón inferior profesional con validación de internet
  Widget _buildBottomButton(
    BuildContext context,
    List<Lectura> lecturas,
    bool hasInternet,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          /* backgroundColor: hasInternet
              ? Colors.blue.shade700
              : Colors.grey.shade400, */
          elevation: 4,
        ),
        icon: const Icon(Icons.cloud_sync_rounded, size: 26),
        label: const Text(
          "Sincronizar todo",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          if (!hasInternet) {
            Loader.openInfoRed(
              context,
              "Para poder sincronizar tus datos, por favor conéctate a una red Wi-Fi o de datos móviles.",
            );
            return;
          }

          Loader.openLoading(
            context,
            'Sincronizando lecturas',
            'Por favor espera mientras sincronizamos tus lecturas con el servidor...',
          );

          final notifier = ref.read(sincronizacionProvider.notifier);
          final success = await notifier.sincronizar();

          if (context.mounted) {
            //Navigator.pop(context);

            if (success) {
              ref
                  .read(lecturasLocalProvider.notifier)
                  .cargarLecturasNoSincronizados();
              Notifications.success(context, "Sincronización completada.");
              Loader.stopLoading(context);
            } else {
              final error =
                  ref.read(sincronizacionProvider).error ?? "Error desconocido";
              Notifications.error(context, "Error al sincronizar: $error");
              Loader.stopLoading(context);
            }
          }
        }, // si no hay internet, botón deshabilitado
      ),
    );
  }
}
