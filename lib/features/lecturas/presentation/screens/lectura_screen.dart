import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nexsys_app/core/constants/constants.dart';
import 'package:nexsys_app/core/services/services.dart';
import 'package:nexsys_app/core/utils/utils.dart';
import 'package:nexsys_app/features/lecturas/data/data.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';
import 'package:nexsys_app/features/lecturas/presentation/presentation.dart';
import 'package:nexsys_app/shared/widgets/widgets.dart';

import '../widgets/item_info.dart';
import '../widgets/metric_card.dart';
import '../widgets/motivo_selector.dart';

class LecturaScreen extends ConsumerStatefulWidget {
  final Lectura lecturaInicial;

  const LecturaScreen({super.key, required this.lecturaInicial});

  @override
  ConsumerState<LecturaScreen> createState() => _LecturaScreenState();
}

class _LecturaScreenState extends ConsumerState<LecturaScreen> {
  @override
  void initState() {
    super.initState();

    // Aseguramos que la lectura inicial se establezca después del primer frame
    Future.microtask(() {
      final current = ref.read(currentLecturaProvider);
      if (current == null) {
        ref.read(currentLecturaProvider.notifier).state = widget.lecturaInicial;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lecturaActual = ref.watch(currentLecturaProvider);
    final isConnected = ref.watch(connectivityProvider);

    print("Estado conexion $isConnected");

    // Si no hay más lecturas, mostramos mensaje en lugar del formulario
    if (lecturaActual == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: const Text('Registrar lectura')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.green.shade600,
                  size: 80,
                ),
                const SizedBox(height: 20),
                const Text(
                  '¡Todas las lecturas han sido registradas!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'No tienes lecturas pendientes por registrar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final lecturaState = ref.watch(lecturaProvider(lecturaActual));

    ref.listen<LecturaFormState>(lecturaFormProvider(lecturaActual), (
      previous,
      next,
    ) {
      if (next.isPosting && !(previous?.isPosting ?? false)) {
        Loader.openFullLoading(context);
      } else if (!next.isPosting && (previous?.isPosting ?? true)) {
        Loader.stopLoading(context);
      }
    });

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: const Text('Registrar lectura')),

        /* appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            color: isConnected ? Colors.green : Colors.red,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(isConnected ? 'Registrar lectura' : 'Sin conexión'),
            ),
          ),
        ), */
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                AlertBanner(),
                SizedBox(height: 6),
                _InfoMedidor(lectura: lecturaState.lectura!),
                _FormView(
                  key: ValueKey(lecturaState.lectura!.id),
                  lecturaState: lecturaState,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoMedidor extends StatelessWidget {
  const _InfoMedidor({required this.lectura});
  final Lectura lectura;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ItemInfo(
          icon: Icons.calendar_month,
          label: 'Periodo',
          value: lectura.periodo,
          color: Colors.indigo,
        ),
        ItemInfo(
          icon: Icons.person_outline,
          label: 'Propietario',
          value: lectura.propietario,
          subvalue: lectura.cedula,
          color: Colors.purple.shade600,
        ),
        ItemInfo(
          icon: Icons.key,
          label: 'Clave Catastral',
          value: lectura.catastro,
          color: Colors.green.shade600,
        ),
        ItemInfo(
          icon: Icons.water_drop_outlined,
          label: 'Número de Medidor',
          value: lectura.medidor,
          highlightValue: true,
          color: Colors.blue.shade600,
        ),
      ],
    );
  }
}

class _FormView extends ConsumerWidget {
  final LecturaState lecturaState;
  //const _FormView({required this.lecturaState});
  const _FormView({super.key, required this.lecturaState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lecturaForm = ref.watch(lecturaFormProvider(lecturaState.lectura!));
    final novedades = [
      {"id": null, "name": "Seleccionar...", "default": false},
      {"id": 8, "name": "CAMBIO DE MEDIDOR", "default": false},
      {"id": 1, "name": "ERROR DE DIGITACION", "default": false},
      {"id": 6, "name": "LECTURA INICIAL", "default": false},
      {"id": 4, "name": "MEDIDOR MANIPULADO", "default": false},
      {"id": 3, "name": "MEDIDOR NO VISIBLE", "default": false},
      {"id": 2, "name": "PERRO BRAVO", "default": false},
      {"id": 7, "name": "REUBICAR MEDIDOR", "default": false},
      {"id": 5, "name": "SIN NOVEDAD", "default": true},
    ].map((e) => NovedadMapper.jsonToEntity(e)).toList();

    final defaultNovedad = novedades.firstWhere((m) => m.isDefault == true);

    // 🔹 Si el formulario no tiene novedad aún, aplicamos la por defecto
    if (lecturaForm.novedadId?.value == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(lecturaFormProvider(lecturaState.lectura!).notifier)
            .onNovedadChanged(defaultNovedad.id);
      });
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'LECTURA ANTERIOR',
                value: '${lecturaForm.lecturaAnterior} m³',
                subtitle: 'Último registro',
                primaryColor: Colors.blue,
              ),
            ),
            const SizedBox(width: AppDesignTokens.spacingS),
            Expanded(
              child: MetricCard(
                title: 'CONSUMO PROMEDIO',
                value: '${lecturaForm.consumo} m³',
                subtitle: 'Por período',
                primaryColor: Colors.teal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        CustomTextFormField(
          label: 'Lectura actual',
          autofocus: true,
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
          suffixIcon: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'm³',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        NovedadSelector(
          label: 'Novedad',
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
        const SizedBox(height: 10),
        CustomTextFormField(
          label: 'Observaciones',
          hintText: '...',
          maxLines: 3,
          initialValue: lecturaForm.observacion ?? '',
          keyboardType: TextInputType.multiline,
          onChanged: ref
              .read(lecturaFormProvider(lecturaState.lectura!).notifier)
              .onDescriptionChanged,
        ),
        const SizedBox(height: 10),
        _ImagenLectura(lectura: lecturaState.lectura!),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () async {
            final currentContext = context;
            final lecturaActual = lecturaState.lectura;
            if (lecturaActual == null) return;

            final formNotifier = ref.read(
              lecturaFormProvider(lecturaActual).notifier,
            );

            final success = await formNotifier.onFormSubmit();

            // Verificar si el widget sigue montado antes de usar context
            if (!currentContext.mounted) return;

            if (!success) {
              SnackbarService.error(
                currentContext,
                "Por favor ingrese todos los campos del formulario.",
              );
              return;
            }

            // Eliminar la lectura actual
            ref
                .read(searchLecturaProvider.notifier)
                .deleteById(lecturaActual.id);

            // Obtener la siguiente
            final next = ref
                .read(searchLecturaProvider.notifier)
                .nextLectura(lecturaActual.id);

            if (next == null) {
              SnackbarService.show(
                currentContext,
                message: "No hay más lecturas pendientes.",
              );

              // Actualizamos después del frame para evitar el error
              Future.microtask(() {
                ref.read(currentLecturaProvider.notifier).state = null;
              });
              return;
            }

            ref.read(currentLecturaProvider.notifier).state = next;
            formNotifier.loadNewLectura(next, defaultNovedad.id);

            SnackbarService.success(
              context,
              "Lectura registrada y cargada la siguiente",
            );
          },
          style: FilledButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: AppDesignTokens.borderRadiusMedium,
            ),
            elevation: 2,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'REGISTRAR LECTURA',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _ImagenLectura extends ConsumerWidget {
  final Lectura lectura;
  const _ImagenLectura({required this.lectura});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lecturaForm = ref.watch(lecturaFormProvider(lectura));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Foto del medidor (opcional)",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),

        GestureDetector(
          onTap: () async {
            final picker = ImagePicker();
            //final source = ImageSource.camera;
            /* await showModalBottomSheet<ImageSource>(
              context: context,
              builder: (ctx) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.camera_alt_outlined),
                      title: const Text('Tomar foto'),
                      onTap: () => Navigator.pop(ctx, ImageSource.camera),
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo_library_outlined),
                      title: const Text('Elegir de galería'),
                      onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                    ),
                  ],
                ),
              ),
            );*/

            final image = await picker.pickImage(
              source: ImageSource.camera,
              imageQuality: 80,
            );

            if (image != null) {
              ref
                  .read(lecturaFormProvider(lectura).notifier)
                  .updateLecturaImage(image.path);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey.shade400,
                style: lecturaForm.image == null || lecturaForm.image!.isEmpty
                    ? BorderStyle.solid
                    : BorderStyle.none,
              ),
              boxShadow: [
                if (lecturaForm.image != null && lecturaForm.image!.isNotEmpty)
                  const BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
              ],
            ),

            // 👇 Si hay imagen, usa FadeInImage
            child: lecturaForm.image != null && lecturaForm.image!.isNotEmpty
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: FadeInImage(
                          placeholder: const AssetImage(
                            'assets/images/loading-image.webp',
                          ),
                          image: FileImage(File(lecturaForm.image!)),
                          fit: BoxFit.cover,
                          fadeInDuration: const Duration(milliseconds: 300),
                          fadeOutDuration: const Duration(milliseconds: 150),
                          placeholderFit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.black45,
                          radius: 20,
                          child: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () {
                              ref
                                  .read(lecturaFormProvider(lectura).notifier)
                                  .cleanLecturaImage();
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_rounded,
                          size: 70,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Tomar o adjuntar foto",
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
