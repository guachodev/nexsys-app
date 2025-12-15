import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexsys_app/core/constants/constants.dart';
import 'package:nexsys_app/core/theme/theme.dart';
import 'package:nexsys_app/core/utils/utils.dart';
import 'package:nexsys_app/features/lecturas/presentation/presentation.dart';
import 'package:nexsys_app/shared/widgets/widgets.dart';

import 'download_card.dart';
import 'nomedidores.dart';
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
    final descargado = periodoState.periodo?.descargado ?? false;
    final tieneAsignado = periodoState.periodo?.descargable ?? false;
    final rutasBloqueadas =
        rutasState.todasRutasCerradas || rutasState.unicaRutaCerrada;
    // Puede descargar solo si tiene asignado Y no está descargado
    final bool puedeDescargar = tieneAsignado && !descargado;
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(periodoProvider.notifier).loadPeriodo();
        ref.read(rutasProvider.notifier).cargarRutas();
        ref.read(novedadesProvider.notifier).loadNovedades();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            //const SizedBox(height: 20),
            PeriodoCard(nombre: periodoState.periodo!.name),
            if (!hasInternet)
              const OfflineBanner(
                top: true,
                text: 'Sin internet, puedes seguir trabajando offline.',
                fontSize: 14,
              ),
            const SizedBox(height: 8),
            // Caso 1: NO TIENE MEDIDORES ASIGNADOS
            if (!tieneAsignado) NoMedidoresCard(),
            if (puedeDescargar)
              DownloadCard(
                ref: ref,
                periodoId: periodoState.periodo!.id,
                hasInternet: hasInternet,
              ),
            // Caso 2: YA DESCARGÓ
            if (descargado)
              Column(
                children: [
                  _Rutas(rutasState: rutasState),
                  const SizedBox(height: 10),
                  //const DownloadedInfo(),
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
                  ActionButton(
                    icon: Icons.search,
                    text: "Buscar lecturas",
                    onTap: () {
                      if (periodoState.periodo!.totalMedidores ==
                          periodoState.periodo!.medidoresLeidos) {
                        _showDone(context);
                        return;
                      }

                      if (rutasBloqueadas) {
                        _showRutaCerrada(context);
                        return;
                      }
                      ref.read(searchLecturaProvider.notifier).reset();
                      context.push('/lecturas/search');
                    },
                  ),
                  const SizedBox(height: 10),
                  ActionButton(
                    icon: Icons.app_registration,
                    text: "Registrar lecturas en orden",
                    onTap: () {
                      if (periodoState.periodo!.totalMedidores ==
                          periodoState.periodo!.medidoresLeidos) {
                        _showDone(context);
                        return;
                      }

                      if (rutasBloqueadas) {
                        _showRutaCerrada(context);
                        return;
                      }

                      if (!rutasState.rutaActivaAbierta) {
                        Notifications.error(
                          context,
                          "Seleccione la ruta activa en la que realizará las lecturas para continua.",
                        );
                        return;
                      }

                      //ref.read(searchLecturaProvider.notifier).reset();
                      context.push('/lectura/ruta', extra: LecturaModo.ruta);
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
                    onTap: () {
                      if (rutasBloqueadas) {
                        _showRutaCerrada(context);
                        return;
                      }
                      context.push('/lecturas/registrados');
                    },
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
                      ref.read(periodoProvider.notifier).resetearDescargado();
                      Notifications.success(
                        context,
                        "Se resetearon las lecturas.",
                      );
                    },
                  ),
                  const SizedBox(height: 10), */

                  /* ActionButton(
                    icon: Icons.backup_rounded,
                    text: "Backup Base de datos",
                    onTap: () async {
                      final dbFile = await DatabaseProvider.getDatabaseFile();

                      if (!await dbFile.exists()) {
                        Notifications.error(
                          context,
                          "⚠ ERROR: La base de datos no existe en: ${dbFile.path}",
                        );
                        return;
                      }

                      final filename = DatabaseProvider.backupFilename();
                      final fileBytes = await dbFile.readAsBytes();

                      // Seleccionar dónde guardar el archivo (SAF)
                      String? outputPath = await FilePicker.platform.saveFile(
                        dialogTitle: 'Selecciona dónde guardar tu backup:',
                        fileName: filename,
                        bytes: fileBytes, // <-- YA LO GUARDA AQUÍ
                        type: FileType.custom,
                        allowedExtensions: ['db'],
                      );

                      if (!context.mounted) return;

                      if (outputPath == null) {
                        Notifications.error(context, "Usuario canceló");
                        return;
                      }

                      // ⚠️ NO ES NECESARIO NI POSIBLE USAR File(outputPath).
                      // Android YA guardó el archivo cuando pasaste bytes:

                      Notifications.success(
                        context,
                        "Backup guardado correctamente",
                      );
                    },
                  ), */
                ],
              ),
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

  void _showRutaCerrada(BuildContext context) {
    Notifications.error(
      context,
      "Todas las rutas asignadas se encuentran cerradas. "
      "No es posible registrar, buscar ni editar lecturas.",
    );
  }
}

class _Rutas extends ConsumerWidget {
  final RutasState rutasState;
  const _Rutas({required this.rutasState});

  void _openRutasBottomSheet(BuildContext context, WidgetRef ref) {
    final rutasState = ref.read(rutasProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 60,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

              // Header
              Container(
                padding: const EdgeInsets.only(top: 2, left: 12, right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Seleccionar Ruta',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.shade50,
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),
              ),

              ...rutasState.rutas.map((ruta) {
                final selected = ruta.id == rutasState.rutaSeleccionada?.id;

                return ListTile(
                  leading: Icon(
                    Icons.directions,
                    color: selected ? AppColors.primary : Colors.grey,
                  ),
                  title: Text(ruta.detalle),
                  trailing: selected
                      ? const Icon(
                          Icons.check_rounded,
                          color: AppColors.primary,
                        )
                      : null,
                  onTap: () {
                    ref.read(rutasProvider.notifier).setRutaSeleccionada(ruta);

                    if (ruta.id == -1) {
                      ref.read(periodoProvider.notifier).refreshAvance();
                    } else {
                      ref.read(periodoProvider.notifier).filterByRuta(ruta.id);
                    }

                    Navigator.pop(context);
                  },
                );
              }),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (rutasState.rutas.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.directions, color: Colors.red.shade700, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "No existen rutas disponibles",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.red.shade900,
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.directions, color: AppColors.primary.shade700, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                ruta.detalle,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primary.shade900,
                ),
              ),
            ),
            /* Icon(
              Icons.chevron_right_rounded,
              color: AppColors.primary.shade700,
            ), */
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => _openRutasBottomSheet(context, ref),
      child: Container(
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                rutasState.rutaSeleccionada?.detalle ?? 'Selecciona una ruta',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded),
          ],
        ),
      ),
    );
  }
}
