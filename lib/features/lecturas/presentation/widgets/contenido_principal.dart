import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexsys_app/core/utils/utils.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';
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
  final RutasState rutasState;

  const ContenidoPrincipal({
    super.key,
    required this.ref,
    required this.periodoState,
    required this.hasInternet,
    required this.rutasState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dowload = periodoState.periodo?.descargado ?? false;

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(periodoProvider.notifier).loadPeriodo();
        ref.read(rutasProvider.notifier).cargarRutas();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            /* ActionButton(
              icon: Icons.gps_fixed,
              text: "Obtener cordenadas",
              onTap: () async {
                final position = await LocationService.getCurrentPosition();
                print(position);
                Notifications.info(context, '$position');
              },
            ), */
            //const SizedBox(height: 20),
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
              _Rutas(rutasState: rutasState),
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
                icon: Icons.edit,
                text: "Editar lecturas",
                onTap: () => context.push('/lecturas/registrados'),
              ),
              const SizedBox(height: 10),
              ActionButton(
                icon: Icons.list,
                text: "Lista de lecturas asignados",
                onTap: () => context.push('/lecturas/lista'),
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

class _Rutas extends ConsumerWidget {
  final RutasState rutasState;
  const _Rutas({required this.rutasState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (rutasState.rutas.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(8),
        //margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade300, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red.shade400,
              size: 28,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                "No existen rutas disponibles",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Caso: Solo una ruta → Mostrar etiqueta
    if (rutasState.rutas.length == 1) {
      final ruta = rutasState.rutas.first;

      return Container(
        //margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black12),
          /*  boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ], */
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                ruta.detalle,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    }

    // Caso: Varias rutas → Mostrar Dropdown
    /* final rutasConOpcionExtra = [
      Ruta(detalle: "Todas las rutas", id: -1, sectorId: -1),
      ...rutasState.rutas,
    ]; */

    // Valor por defecto: “Todas las rutas”
    //Ruta valorSeleccionado = rutasConOpcionExtra.first;
    return Container(
      margin: EdgeInsetsGeometry.only(top: 6),
      child: DropdownButtonFormField<Ruta>(
        decoration: InputDecoration(
          labelText: "Selecciona una ruta",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        initialValue: rutasState.rutaSeleccionada, // ← ESTE ES EL VALOR
        isExpanded: true,
        items: rutasState.rutas.map((r) {
          return DropdownMenuItem(value: r, child: Text(r.detalle));
        }).toList(),
        onChanged: (ruta) {
          if (ruta != null) {
            ref.read(rutasProvider.notifier).setRutaSeleccionada(ruta);
            if (ruta.id == -1) {
              ref.read(periodoProvider.notifier).refreshAvance();
            } else {
              ref.read(periodoProvider.notifier).filterByRuta(ruta.id);
            }
          }
        },
      ),
    );
  }
}
