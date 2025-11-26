import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nexsys_app/core/services/services.dart';
import 'package:nexsys_app/core/theme/theme.dart';
import 'package:nexsys_app/core/utils/utils.dart';
import 'package:nexsys_app/features/lecturas/data/data.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';
import 'package:nexsys_app/features/lecturas/presentation/presentation.dart';
import 'package:nexsys_app/shared/widgets/widgets.dart';

import '../widgets/novedad_selector.dart';

class LecturaScreen extends ConsumerStatefulWidget {
  final int lecturaId;

  const LecturaScreen({super.key, required this.lecturaId});

  @override
  ConsumerState<LecturaScreen> createState() => _LecturaScreenState();
}

class _LecturaScreenState extends ConsumerState<LecturaScreen> {
  @override
  void initState() {
    super.initState();
    /* WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(lecturaFormProvider(lectura).notifier)
       .setDefaultNovedadFromApi();
  }); */
    // Cargar lectura inicial EN BASE AL ID
    Future.microtask(() {
      ref.read(currentLecturaProvider.notifier).state = widget.lecturaId;
      ref.read(saveLecturaProvider.notifier).state = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentId = ref.watch(currentLecturaProvider);
    final succes = ref.watch(saveLecturaProvider);

    if (currentId == null) {
      //return const _FinLecturasView();
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (succes) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: const Text('Registrar lectura')),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ícono animado
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(30),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green.shade700,
                      size: 90,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Text(
                    '¡Lectura registrada!',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "La lectura fue registrada correctamente.",
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        // backgroundColor: Colors.blue.shade800,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Registrar nueva lectura',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
    }

    // <<<--- AQUÍ SE BUSCA EN SQLITE AUTOMÁTICAMENTE
    final lecturaState = ref.watch(lecturaProvider(currentId));

    if (lecturaState.isLoading || lecturaState.lectura == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final lectura = lecturaState.lectura!;

    // Listener del formulario
    ref.listen<LecturaFormState>(lecturaFormProvider(lectura), (prev, next) {
      if (next.isPosting && !(prev?.isPosting ?? false)) {
        Loader.openFullLoading(context);
      } else if (!next.isPosting && (prev?.isPosting ?? true)) {
        Loader.stopLoading(context);
      }
    });

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: BarApp(title: 'Registrar lectura'),
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    /* Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: Colors.blue[700],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text("Los campos con (*) son obligatorios"),
                          ),
                        ],
                      ),
                    ),
 */
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .2),
                            blurRadius: 12,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- CABECERA ---
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey.shade400,
                                  width: 1.2,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: Colors.amber.shade700,
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Información del medidor",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // --- CONTENIDO ---
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InfoRow(
                                  label: "Cuenta:",
                                  value: lectura.cuenta.toString(),
                                ),
                                InfoRow(
                                  label: "Medidor:",
                                  value: lectura.medidor,
                                ),
                                InfoRow(
                                  label: "Promedio (m³):",
                                  value: lectura.cuenta.toString(),
                                ),
                                InfoRow(
                                  label: "Cédula:",
                                  value: lectura.cedula,
                                ),
                                InfoRow(
                                  label: "Propietario:",
                                  value: lectura.propietario,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _FormView(
                      key: ValueKey(lecturaState.lectura!.id),
                      lecturaState: lecturaState,
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          ),
        ),
        //bottomNavigationBar: _BotonRegistrar(lectura: lectura),
        floatingActionButton: _BotonRegistrar(lectura: lectura),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

class _FormView extends ConsumerWidget {
  final LecturaState lecturaState;
  const _FormView({super.key, required this.lecturaState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lecturaForm = ref.watch(lecturaFormProvider(lecturaState.lectura!));
    /*final novedades = ref.watch(novedadesProvider);

    // Novedad por defecto (solo si el estado está vacío)
    final defaultNovedad = novedades.firstWhere(
      (m) => m.isDefault,
      orElse: () => Novedad(id: -1, detalle: 'Ninguna', isDefault: false),
    );*/
    final novedades = [
      // {"id": null, "name": "Seleccionar...", "default": false},
      {"id": 1, "name": "CC | CASA CERRADA", "default": false},
      {"id": 14, "name": "CM | CON MATERIALES", "default": false},
      {"id": 11, "name": "CO | CORTADO", "default": false},
      {"id": 16, "name": "E | ELIMINAR", "default": false},
      {"id": 23, "name": "LE | LECTURA ESTACIONADA", "default": false},
      {"id": 9, "name": "LO | LUNA OPACA", "default": false},
      {"id": 4, "name": "MAR | MEDIDOR A REVISAR", "default": false},
      {"id": 17, "name": "MCCC | MEDIDOR COMPRADO CASA EN", "default": false},
      {"id": 8, "name": "MD | MEDIDOR DAÑADO", "default": false},
      {"id": 24, "name": "MM | MEDIDOR MANIPULADO", "default": false},
      {"id": 5, "name": "MMR | MEDIDOR MARCA AL REVES", "default": false},
      {"id": 20, "name": "MN | MEDIDOR NUEVO", "default": false},
      {"id": 22, "name": "MO | MEDIDOR OBSTRUIDO", "default": false},
      {"id": 19, "name": "MRPC | MEDIDOR RETIRADO POR COR", "default": false},
      {"id": 21, "name": "NL | NO LOCALIZADO", "default": false},
      {"id": 13, "name": "NV | NO VIVE", "default": false},
      {"id": 2, "name": "PB | PERRO BRAVO", "default": false},
      {"id": 15, "name": "SL | SIN LECTURA", "default": false},
      {"id": 18, "name": "SLV | SIN LECTURA VEHICULO", "default": false},
      {"id": 3, "name": "SM | SIN MEDIDOR", "default": false},
      {"id": 25, "name": "SN | SIN NOVEDAD", "default": true},
      {"id": 6, "name": "SS | SIN SERVICIO", "default": false},
      {"id": 7, "name": "99 | Solo FACTURACION", "default": false},
      {"id": 10, "name": "TA | TAPONADO", "default": false},
      {"id": 12, "name": "T | TERRENO", "default": false},
    ].map((e) => NovedadMapper.jsonToEntity(e)).toList();

    final defaultNovedad = novedades.firstWhere((m) => m.isDefault == true);

    if (lecturaForm.novedadId?.value == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(lecturaFormProvider(lecturaState.lectura!).notifier)
            .onNovedadChanged(defaultNovedad.id);
      });
    }
    //ref.watch(lecturaFormProvider(lecturaState.lectura!, defaultNovedad.id));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: ChipInfo(
                label: "Lect. anterior (m³)",
                value: "${lecturaForm.lecturaAnterior}",
                icon: Icons.water_drop_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ChipInfo(
                label: "Consumo (m³)",
                value: "${lecturaForm.consumo}",
                icon: Icons.show_chart_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        CustomTextFormField(
          label: 'Lectura actual',
          autofocus: true,
          floating: true,
          hintText: '0',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          initialValue: lecturaForm.lecturaActual.value?.toString() ?? '',
          onFieldSubmitted: (_) => ref
              .read(lecturaFormProvider(lecturaState.lectura!).notifier)
              .onFormSubmit(),
          onChanged: (value) {
            ref
                .read(lecturaFormProvider(lecturaState.lectura!).notifier)
                .onLecturaActualChanged(int.tryParse(value));
          },
          errorMessage: lecturaForm.lecturaActual.errorMessage,
          prefixIcon: Icon(Icons.speed_rounded),
        ),
        const SizedBox(height: 12),
        NovedadSelector(
          label: 'Novedad',
          isSearch: true,
          hintText: 'Seleccionar novedad..',
          items: novedades,
          errorText: lecturaForm.novedadId?.errorMessage,
          initialValue: defaultNovedad,
          onChanged: (novedad) {
            ref
                .read(lecturaFormProvider(lecturaState.lectura!).notifier)
                .onNovedadChanged(novedad.id);
          },
        ),
        const SizedBox(height: 12),
        CustomTextFormField(
          label: 'Observaciones',
          hintText:
              'Agregue observaciones adicionales adicionales si es necesario...',
          maxLines: 3,
          initialValue: lecturaForm.observacion ?? '',
          keyboardType: TextInputType.multiline,
          onChanged: ref
              .read(lecturaFormProvider(lecturaState.lectura!).notifier)
              .onDescriptionChanged,
        ),
        const SizedBox(height: 4),
        _ImagenesLectura(lectura: lecturaState.lectura!),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _BotonRegistrar extends ConsumerWidget {
  final Lectura lectura;

  const _BotonRegistrar({required this.lectura});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .20),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.transparent, // El Container maneja el color
          foregroundColor: Colors.white,
          elevation: 0, // Sombra manejada por el Container

          heroTag: "fab_registrar",

          label: Padding(
            padding: const EdgeInsets.all(12),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save),
                SizedBox(width: 8),
                Text(
                  "REGISTRAR LECTURA",
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ],
            ),
          ),

          onPressed: () async {
            final formNotifier = ref.read(
              lecturaFormProvider(lectura).notifier,
            );

            final success = await formNotifier.onFormSubmit();

            if (!success) {
              SnackbarService.error(context, "Complete todos los campos.");
              return;
            }

            formNotifier.reset();
            // Guardar / actualizar
            ref.read(searchLecturaProvider.notifier).deleteById(lectura.id);
            //ref.read(searchLecturaProvider.notifier).reset();
            ref.read(periodoProvider.notifier).refreshAvance();

            // Mostrar pantalla de éxito dentro del mismo widget
            // ref.read(currentLecturaProvider.notifier).state = null;
            ref.read(saveLecturaProvider.notifier).state = true;
          },
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LABEL (ancho mínimo)
          ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 97, // ajusta según tu diseño
            ),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(value, softWrap: true, overflow: TextOverflow.visible),
          ),
        ],
      ),
    );
  }
}

class ChipInfo extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const ChipInfo({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black26, width: 1.2),
        /* boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .2),
            blurRadius: 12,
            offset: const Offset(0, 1),
          ),
        ], */
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: Colors.blue.shade700),
          ),
          //Icon(icon, color: Colors.blue.shade700),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImagenesLectura extends ConsumerWidget {
  final Lectura lectura;
  const _ImagenesLectura({required this.lectura});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lecturaForm = ref.watch(lecturaFormProvider(lectura));
    final notifier = ref.read(lecturaFormProvider(lectura).notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Fotos del medidor (opcional)",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        Row(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text("Tomar foto"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade800, // Color de fondo
                foregroundColor: Colors.white,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Radio del botón
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 1,
                ),
              ),
              onPressed: () async {
                final picker = ImagePicker();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 50,
                );
                if (image != null) notifier.addLecturaImage(image.path);
              },
            ),
            /* const SizedBox(width: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text("Galería"),
              onPressed: () async {
                final picker = ImagePicker();
                final images = await picker.pickMultiImage(imageQuality: 80);
                for (final img in images) {
                  notifier.addLecturaImage(img.path);
                }
              },
            ),
           */
          ],
        ),
        const SizedBox(height: 4),
        lecturaForm.images.isEmpty
            ? Container(
                height: 150,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.blue.shade600,
                      size: 48,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "No hay fotos",
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                  ],
                ),
              )
            : SizedBox(
                height: 150,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true, // 👈 importante
                  // physics: const NeverScrollableScrollPhysics(),
                  itemCount: lecturaForm.images.length,
                  // ignore: unnecessary_underscores
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final path = lecturaForm.images[index];
                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: FadeInImage(
                              placeholder: const AssetImage(
                                'assets/images/loading-image.webp',
                              ),
                              image: FileImage(File(path)),
                              fit: BoxFit.cover,
                              width: 200,
                              height: 160,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.black45,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: 18,
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              onPressed: () =>
                                  notifier.removeLecturaImage(path),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
      ],
    );
  }
}
