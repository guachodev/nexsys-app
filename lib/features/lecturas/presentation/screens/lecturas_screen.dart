import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:nexsys_app/core/constants/constants.dart';
import 'package:nexsys_app/core/utils/utils.dart';
import 'package:nexsys_app/features/lecturas/presentation/presentation.dart';
import 'package:nexsys_app/features/lecturas/presentation/providers/periodo_provider.dart';
import 'package:nexsys_app/shared/widgets/widgets.dart';

import '../widgets/qr_scanner_sheet.dart';

class LecturasScreen extends ConsumerWidget {
  const LecturasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodoState = ref.watch(periodoProvider);
    final total = periodoState.periodo?.total ?? 0;
    final leidos = periodoState.periodo?.totalLectura ?? 0;

    print('Periodo => ${periodoState.periodo?.periodo}');

    final isCompleted = total == leidos;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        //backgroundColor: Color(0xFFF8F7F7),
        drawer: const CustomDrawer(),
        appBar: AppBar(
          title: const Text("Lecturas de Consumo"),
          actions: [
            IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: () {
                if (!isCompleted) {
                  return Notifications.show(
                    context,
                    icon: Icons.check_circle,
                    title: '¡Lectura registrada con éxito!',
                    message:
                        'Todas las lecturas asignadas han sido completadas y registradas correctamente. No hay tareas pendientes.',
                  );
                }

                ref.read(searchLecturaProvider.notifier).reset();
                context.push('/lecturas/search');
              },
            ),
          ],
        ),
        body: _buildBody(periodoState.status, periodoState, ref),
        //body:
        /* body: Column(
          children: [
            Text(
              'Bienvenido 👋',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Verifica si tienes medidores asignados para comenzar.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const Spacer(),

            //Center(child: CircularProgressIndicator()),
            ElevatedButton.icon(
              icon: Icon(Icons.download),
              label: Text('Descargar medidores'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {},
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No tienes medidores asignados o el periodo está inactivo.',
                    ),
                  ),
                ],
              ),
            ),
            // const SizedBox(height: 24),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Lectura actual',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('No se ha tomado foto'),
            Container(
              decoration: BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                // child: Image.file(File(_fotoPath!), height: 150),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.camera_alt),
              label: Text('Tomar foto'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {},
            ),
            //const Spacer(),
            ElevatedButton.icon(
              icon: Icon(Icons.save),
              label: Text('Guardar lectura'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {},
            ),

            FilledButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Descargar Medidores'),
              onPressed: () {}, 
            ),
             LinearProgressIndicator(),
            //if (downloadState.hasError) ErrorText(error: downloadState.error),
          ],
        ), */
      ),
    );
  }
}

Widget _buildBody(
  SearchStatus status,
  PeriodoState periodoState,
  WidgetRef ref,
) {
  switch (status) {
    /* case SearchStatus.loading:
      return _Loading(); */ // Key única

    case SearchStatus.loading:
      return _LoadingScreen(periodoState: periodoState);

    case SearchStatus.initial:
      return _Loading();
    case SearchStatus.loaded:
      return _ContenidoPrincipal(
        ref: ref,
        periodoActivo: periodoState.periodo!.periodo,
        total: periodoState.periodo?.total ?? 0,
        leidos: periodoState.periodo?.totalLectura ?? 0,
        pendientes: periodoState.pendientes ?? 0,
        progreso: periodoState.progreso ?? 0,
      );
    case SearchStatus.empty:
      return _AlertaSinAsignaciones(ref: ref);
    case SearchStatus.error:
      return _Error(
        title: 'Error',
        message: periodoState.errorMessage ?? '',
        onRetry: () => ref.read(periodoProvider.notifier).loadPeriodo(),
      );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

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
    /* return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Lottie.asset(
          'assets/animations/loading.json',
          height: 300,
          repeat: true, // Para que se repita indefinidamente
          animate: true, // Para que se reproduzca
        ),
        //const SizedBox(height: 20),
        // Mensaje para el usuario
        const Text('Cargando su contenido...', style: TextStyle(fontSize: 18)),
        /* tieneAsignaciones
            ? _ContenidoPrincipal(
                ref: ref,
                periodoActivo: periodoState.periodo!.periodo,
                total: totalAsignados,
                leidos: leidos,
                pendientes: pendientes,
                progreso: progreso,
              )
            : _AlertaSinAsignaciones(ref: ref), */
      ],
    ); */
  }
}

class _ContenidoPrincipal extends StatelessWidget {
  final WidgetRef ref;
  final String periodoActivo;
  final int total, leidos, pendientes;
  final double progreso;

  const _ContenidoPrincipal({
    required this.ref,
    required this.periodoActivo,
    required this.total,
    required this.leidos,
    required this.pendientes,
    required this.progreso,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = total == leidos;
    return RefreshIndicator(
      onRefresh: () async => ref.read(periodoProvider.notifier).loadPeriodo(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            //_DescargaIncompletaIndicator(),
            //_SyncPendingIndicator(pendingCount: 50),
            _PeriodoCard(periodoActivo: periodoActivo),
            const SizedBox(height: 20),
            _SearchBarSection(
              ref: ref,
              sheetContext: context,
              isCompleted: isCompleted,
            ),

            //_OfflineIndicator(pendingSyncs: 10),
            const SizedBox(height: 20),
            _ResumenCard(
              total: total,
              leidos: leidos,
              pendientes: pendientes,
              progreso: progreso,
            ),
            const SizedBox(height: 20),
            // const _AccesosRapidos(),
            //const SizedBox(height: 24),
            //const _CardEstadoDelDia(),
            const AyudaLecturaSteps(),
          ],
        ),
      ),
    );
  }
}

class _OfflineIndicator extends StatelessWidget {
  final int pendingSyncs;

  const _OfflineIndicator({required this.pendingSyncs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        border: Border.all(color: Colors.amber),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off, color: Colors.amber[700]),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              pendingSyncs > 0
                  ? 'Modo offline - $pendingSyncs lecturas pendientes de sync'
                  : 'Modo offline - Trabajando localmente',
              style: TextStyle(color: Colors.amber[800]),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodoCard extends StatelessWidget {
  final String periodoActivo;
  const _PeriodoCard({required this.periodoActivo});

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
      padding: const EdgeInsets.all(20),
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
                  periodoActivo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Colors.white, size: 40),
        ],
      ),
    );
  }
}

class _SearchBarSection extends StatelessWidget {
  final BuildContext sheetContext;
  final WidgetRef ref;
  final bool isCompleted;
  const _SearchBarSection({
    required this.ref,
    required this.sheetContext,
    required this.isCompleted,
  });

  void _openQrScanner() {
    if (isCompleted) {
      return Notifications.show(
        sheetContext,
        icon: Icons.check_circle,
        title: '¡Lectura registrada con éxito!',
        message:
            'Todas las lecturas asignadas han sido completadas y registradas correctamente. No hay tareas pendientes.',
      );
    }

    ref.read(searchLecturaQrProvider.notifier).reset();
    showModalBottomSheet(
      context: sheetContext,
      isScrollControlled: true,
      isDismissible: false,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const QrScannerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (isCompleted) {
                return Notifications.show(
                  context,
                  icon: Icons.check_circle,
                  title: '¡Lectura registrada con éxito!',
                  message:
                      'Todas las lecturas asignadas han sido completadas y registradas correctamente. No hay tareas pendientes.',
                );
              }

              ref.read(searchLecturaProvider.notifier).reset();
              context.push('/lecturas/search');
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: BoxBorder.all(color: Colors.grey.shade300, width: 1),
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
                  Icon(Icons.search, color: Colors.grey),
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
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _openQrScanner(),
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.indigo,
              /* gradient: LinearGradient(
                colors: [Colors.indigo, Colors.indigoAccent],
              ), */
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.all(8),
            child: const Icon(
              Icons.barcode_reader,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ],
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

class _AlertaSinAsignaciones extends StatelessWidget {
  final WidgetRef ref;
  const _AlertaSinAsignaciones({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // SVG ilustración
                SvgPicture.asset(
                  'assets/svg/addUsers.svg', // Asegúrate de colocar el SVG en assets
                  height: 200,
                ),
                const SizedBox(height: 32),

                // Título
                const Text(
                  "Sin periodo de lectura activo",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2E45),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Subtítulo
                const Text(
                  "No tienes asignaciones disponibles actualmente. Espera a que el administrador habilite un nuevo periodo o asignación.",
                  style: TextStyle(fontSize: 16, color: Color(0xFF1A2E45)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Botón
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      // Acción para revisar el formulario
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.indigo),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Revisar formulario',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        //color: Color(0xFF1A2E45),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    /* return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.19),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  height: 160,
                  width: 160,
                  decoration: BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.calendar_month_rounded,
                      size: 90,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                /* Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.amber[700]),
                    const SizedBox(width: 8),
                    const Text(
                      "Sin periodo de lectura activo",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ), */
                const Text(
                  "Sin periodo de lectura activo",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    //color: Color(0xFF3B3B3B),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "No tienes asignaciones disponibles actualmente. Espera a que el administrador habilite un nuevo periodo o asignación.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF707070),
                    fontSize: 14,
                    //height: 1.4,
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        ref.read(periodoProvider.notifier).loadPeriodo(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 6,
                      shadowColor: Colors.indigo.withValues(alpha: .4),
                    ),

                    child: const Text(
                      "Reintentar",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ); */
  }
}

class AyudaLecturaSteps extends StatelessWidget {
  const AyudaLecturaSteps({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = [
      {
        'title': 'Seleccione el medidor',
        'description':
            'Verifique que está registrando la lectura del medidor correcto revisando la clave catastral y dirección.',
        'icon': Icons.water_drop_outlined,
        'optional': false,
      },
      {
        'title': 'Registre la lectura actual',
        'description':
            'Ingrese el valor numérico que muestra el medidor en este momento. Este campo es obligatorio.',
        'icon': Icons.edit_note_outlined,
        'optional': false,
      },
      /* {
        'title': 'Agregue una foto del medidor',
        'description':
            'Puede tomar una fotografía como evidencia de la lectura registrada.',
        'icon': Icons.photo_camera_outlined,
        'optional': true,
      }, */
      {
        'title': 'Revise y envíe',
        'description':
            'Verifique que toda la información sea correcta antes de enviar el registro.',
        'icon': Icons.send_rounded,
        'optional': false,
      },
    ];

    return Card(
      elevation: 5,
      color: Colors.white,
      shadowColor: Colors.indigo.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      //margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Guía para registrar lecturas",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(steps.length, (index) {
              final step = steps[index];
              final isLast = index == steps.length - 1;
              return _StepItem(
                index: index + 1,
                title: step['title'] as String,
                description: step['description'] as String,
                icon: step['icon'] as IconData,
                optional: step['optional'] as bool,
                showConnector: !isLast,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final int index;
  final String title;
  final String description;
  final IconData icon;
  final bool optional;
  final bool showConnector;

  const _StepItem({
    required this.index,
    required this.title,
    required this.description,
    required this.icon,
    required this.optional,
    required this.showConnector,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Círculo numerado con degradado
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo, Colors.indigo.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (showConnector)
              Container(
                width: 2,
                height: 50,
                color: Colors.indigo.withValues(alpha: 0.3),
              ),
          ],
        ),
        const SizedBox(width: 14),
        // Contenido del paso
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    /*  Icon(icon, color: Colors.indigoAccent, size: 20),
                    const SizedBox(width: 6), */
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                    ),
                    if (optional)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "OPCIONAL",
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Error extends StatelessWidget {
  final String message;
  final String title;
  final VoidCallback? onRetry;
  const _Error({required this.message, required this.title, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeInUp(
              duration: const Duration(milliseconds: 700),
              child: Container(
                /* decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.1),
                  ), */
                padding: const EdgeInsets.all(32),
                child: Lottie.asset(
                  'assets/animations/error.json',
                  height: 160,
                  repeat: true,
                ),
              ),
            ),
            const SizedBox(height: 10),
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            FadeInUp(
              duration: const Duration(milliseconds: 800),
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            if (onRetry != null)
              FadeInUp(
                duration: const Duration(milliseconds: 900),
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: color,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    shadowColor: color.withValues(alpha: 0.4),
                    elevation: 6,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  final PeriodoState periodoState;

  const _LoadingScreen({required this.periodoState});

  @override
  Widget build(BuildContext context) {
    final tienePeriodo = periodoState.periodo != null;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset('assets/animations/loading.json', height: 200),
        Text(
          tienePeriodo
              ? '📥 Descargando lecturas asignadas...'
              : 'Buscando periodo activo...',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (tienePeriodo) ...[
          SizedBox(height: 10),
          Text(
            'Periodo: ${periodoState.periodo!.periodo}',
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 20),
          LinearProgressIndicator(),
        ],
      ],
    );
  }
}

// NUEVO: INDICADOR DE DESCARGA INCOMPLETA
class _DescargaIncompletaIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange[700]),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Descarga incompleta. Algunos datos pueden faltar.',
              style: TextStyle(color: Colors.orange[800]),
            ),
          ),
        ],
      ),
    );
  }
}
