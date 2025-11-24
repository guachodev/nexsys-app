import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexsys_app/core/utils/utils.dart';
import 'package:nexsys_app/features/lecturas/presentation/presentation.dart';
import 'package:nexsys_app/shared/widgets/widgets.dart';

import 'download_card.dart';
import 'downloaded_info.dart';
import 'periodo_card.dart';
import 'resumen_card.dart';
import 'search_bar_section.dart';

class ContenidoPrincipal extends ConsumerWidget {
  final WidgetRef ref;
  final PeriodoState periodoState;
  final bool hasInternet;

  const ContenidoPrincipal({
    required this.ref,
    required this.periodoState,
    required this.hasInternet,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dowload = periodoState.periodo?.descargado ?? false;

    return RefreshIndicator(
      onRefresh: () async => ref.read(periodoProvider.notifier).loadPeriodo(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            PeriodoCard(nombre: periodoState.periodo!.name),
            if (!hasInternet) const OfflineBanner(top: true),
            const SizedBox(height: 10),
            if (!dowload)
              DownloadCard(
                ref: ref,
                periodoId: periodoState.periodo!.id,
                hasInternet: hasInternet,
              )
            else ...[
              const DownloadedInfo(),
              SearchBarSection(
                ref: ref,
                isCompleted:
                    periodoState.periodo!.totalMedidores ==
                    periodoState.periodo!.medidoresLeidos,
              ),
              const SizedBox(height: 10),
              ResumenCard(
                total: periodoState.periodo!.totalMedidores,
                leidos: periodoState.periodo!.medidoresLeidos,
                pendientes: periodoState.periodo!.pendientes,
                progreso: periodoState.periodo!.porcentajeAvance,
              ),
              const SizedBox(height: 10),
              ActionButton(
                icon: Icons.app_registration,
                text: "Registrar lecturas",
                onTap: () {
                  if (periodoState.periodo!.totalMedidores ==
                      periodoState.periodo!.medidoresLeidos) {
                    _showDone(context);
                    return;
                  }
                  ref.read(searchLecturaProvider.notifier).reset();
                  context.push('/lecturas/search');
                },
              ),
              const SizedBox(height: 10),
              ActionButton(
                icon: Icons.sync_rounded,
                text: "Sincronizar lecturas",
                onTap: () => context.push('/lecturas/sincronizar'),
              ),
              const SizedBox(height: 10),
              ActionButton(
                icon: Icons.history_rounded,
                text: "Lecturas registradas",
                onTap: () => context.push('/lecturas/registrados'),
              ),
              const SizedBox(height: 10),
              /* ActionButton(
                icon: Icons.history_rounded,
                text: "Resetear lecturas",
                onTap: () {
                  ref
                      .read(lecturasProvider.notifier)
                      .resetearLecturas(periodoState.periodo!);
                  SnackbarService.success(
                    context,
                    "Se resetearon las lecturas.",
                  );
                },
              ),
              const SizedBox(height: 10),
              ActionButton(
                icon: Icons.history_rounded,
                text: "Exportar lecturas",
                onTap: () async {
                  Loader.openLoading(
                    context,
                    'Exportando lecturas',
                    'Por favor espere estamos generando el archivo para exportar...',
                  );
                  final scaffoldContext = context;
                  ref.read(lecturasProvider.notifier).exportarLecturas().then((
                    filePath,
                  ) {
                    if (filePath == null) {
                      SnackbarService.error(
                        scaffoldContext,
                        "Error al exportar lecturas",
                      );
                      Loader.stopLoading(context);
                      return;
                    }

                    SnackbarService.info(
                      scaffoldContext,
                      "Archivo guardado en Descargas:\n$filePath",
                    );
                    Loader.stopLoading(context);
                  });
                },
              ), */
            ],
          ],
        ),
      ),
    );
  }

  void _showDone(BuildContext context) {
    Notifications.show(
      context,
      icon: Icons.check_circle,
      title: '¡Completado!',
      message: 'Todas las lecturas han sido registradas correctamente.',
    );
  }
}
