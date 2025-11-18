// Optimized LecturasScreen (refactored & cleaned)

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:nexsys_app/core/constants/constants.dart';
import 'package:nexsys_app/core/providers/network_provider.dart';
import 'package:nexsys_app/core/utils/utils.dart';
import 'package:nexsys_app/shared/widgets/widgets.dart';

import '../presentation.dart';
import '../providers/periodo_provider.dart';
import '../widgets/qr_scanner_sheet.dart';

class LecturasScreen extends ConsumerWidget {
  const LecturasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasInternet = ref.watch(networkProvider).value ?? false;
    final periodoState = ref.watch(periodoProvider);

    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        drawer: const CustomDrawer(),
        appBar: _buildAppBar(context, ref, hasInternet),
        body: _buildBody(periodoState.status, periodoState, ref),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, WidgetRef ref, bool hasInternet) {
    return AppBar(
      title: const Text("Lecturas de Consumo"),
      actions: [
        IconButton(
          icon: SvgPicture.asset(
            'assets/svg/help.svg',
            width: 24, // ajusta tamaño
            height: 24,
            /* colorFilter: const ColorFilter.mode(
              Colors.indigo, 
              BlendMode.srcIn,
            ), */
          ),
          onPressed: () => context.push('/lecturas/sincronizar'),
        ),
      ],
    );
  }
}

Widget _buildBody(SearchStatus status, PeriodoState state, WidgetRef ref) =>
    switch (status) {
      SearchStatus.loading => _LoadingScreen(periodoState: state),
      SearchStatus.initial => _LoadingScreen(periodoState: state),
      SearchStatus.loaded => _ContenidoPrincipal(),
      SearchStatus.empty => _AlertaSinAsignaciones(ref: ref),
      SearchStatus.error => _LoadingScreen(periodoState: state),
    };

class _LoadingScreen extends StatelessWidget {
  final PeriodoState periodoState;
  const _LoadingScreen({required this.periodoState});

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      child: Center(
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
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
                      strokeWidth: 6,
                    ),
                  ),
                  Icon(
                    Icons.water_drop_outlined, // Puedes cambiar por otro ícono
                    size: 70,
                    color: Colors.indigo,
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
                  color: Colors.indigo[800],
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
      ),
    );
  }
}


class _ContenidoPrincipal extends ConsumerWidget {
  const _ContenidoPrincipal();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasInternet = ref.watch(networkProvider).value ?? false;
    final periodoState = ref.watch(periodoProvider);
    final dowload = periodoState.periodo?.dowload ?? false;

    return RefreshIndicator(
      onRefresh: () async => ref.read(periodoProvider.notifier).loadPeriodo(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            if (!hasInternet) _OfflineBanner(),

            _PeriodoCard(nombre: periodoState.periodo!.name),
            const SizedBox(height: 10),
          if (!dowload) _buildDownloadCard(context, ref),

            if (dowload) ...[
              _buildDownloadedInfo(),
              _SearchBarSection(ref: ref, isCompleted: true),
              const SizedBox(height: 10),
              _ResumenCard(
                total: 40,
                leidos: 10,
                pendientes: 30,
                progreso: 10 / 100,
              ),
              const SizedBox(height: 10),
              _buildButton(
                icon: Icons.sync_rounded,
                text: "Sincronizar pendientes",
                onTap: () {},
              ),
              const SizedBox(height: 10),

              _buildButton(
                icon: Icons.history_rounded,
                text: "Lecturas registradas",
                onTap: () {},
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadCard(BuildContext context, WidgetRef ref) {
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
                Loader.openDowloadLecturas(context);
                await Future.delayed(const Duration(seconds: 2));
                ref.read(periodoProvider.notifier).updateDowload();
                Loader.stopLoading(context);
                Notifications.info(context, 'Se descargaron los medidores correctamente.');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadedInfo() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 30, color: Colors.indigo.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Medidores descargados localmente. \n Puedes trabajar sin conexión.",
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  /// --------------------------------------------------------------------
  /// Botón reutilizable
  /// --------------------------------------------------------------------
  Widget _buildButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        borderRadius: BorderRadius.circular(10),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          splashColor: Colors.indigo.withValues(alpha: 0.1),
          highlightColor: Colors.indigo.withValues(alpha: 0.05),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.black54, size: 24),
                const SizedBox(width: 10),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AlertaSinAsignaciones extends StatelessWidget {
  final WidgetRef ref;
  const _AlertaSinAsignaciones({required this.ref});

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
              SvgPicture.asset('assets/svg/addUsers.svg', height: 200),
              const SizedBox(height: 32),
              const Text(
                "No hay período activo",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "Por favor, espera a que se active un nuevo período de lecturas.",
                //style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              OutlinedButton(
                onPressed: () =>
                    ref.read(periodoProvider.notifier).loadPeriodo(),
                child: const Text("Reintentar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red),
      ),
      child: const Row(
        children: [
          Icon(Icons.wifi_off, color: Colors.red),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Sin conexión a internet",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodoCard extends StatelessWidget {
  final String nombre;
  const _PeriodoCard({required this.nombre});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo, Colors.indigo.shade600],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Periodo de lectura activo",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
                Text(
                  nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBarSection extends StatelessWidget {
  final WidgetRef ref;
  final bool isCompleted;
  const _SearchBarSection({required this.ref, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (isCompleted) return _showDone(context);
              ref.read(searchLecturaProvider.notifier).reset();
              context.push('/lecturas/search');
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: BoxBorder.all(color: Colors.black45, width: 1),
                borderRadius: BorderRadius.circular(8),
                /* boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ], */
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: const [
                  Icon(Icons.search, color: Colors.black54),
                  SizedBox(width: 8),
                  Text(
                    'Buscar medidor...',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Material(
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              if (isCompleted) return _showDone(context);
              ref.read(searchLecturaQrProvider.notifier).reset();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                isDismissible: false,
                useSafeArea: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const QrScannerSheet(),
              );
            },
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.barcode_reader, color: Colors.white, size: 28),
                ],
              ),
            ),
          ),
        ),
      ],
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

class _ResumenCard extends StatelessWidget {
  final int total, leidos, pendientes;
  final double progreso;
  const _ResumenCard({
    required this.total,
    required this.leidos,
    required this.pendientes,
    required this.progreso,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      shadowColor: Colors.indigo.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Resumen del Día",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.indigo,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total asignados: $total'),
                      Text('Leídos: $leidos'),
                      Text('Pendientes: $pendientes'),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: progreso,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(10),
                        backgroundColor: Colors.grey.shade200,
                        color: pendientes > 0 ? Colors.indigo : Colors.green,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: progreso,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          pendientes > 0 ? Colors.indigo : Colors.green,
                        ),
                      ),
                    ),
                    Text(
                      '${(progreso * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
