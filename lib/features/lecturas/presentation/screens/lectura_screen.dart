import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nexsys_app/core/constants/constants.dart';
import 'package:nexsys_app/core/services/services.dart';
import 'package:nexsys_app/core/theme/theme.dart';
import 'package:nexsys_app/core/utils/utils.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';
import 'package:nexsys_app/features/lecturas/presentation/presentation.dart';
import 'package:nexsys_app/shared/widgets/widgets.dart';

import '../widgets/chip_info.dart';
import '../widgets/info_row.dart';
import '../widgets/novedad_selector.dart';

class LecturaScreen extends ConsumerWidget {
  final String lecturaId;
  final LecturaModo modo;

  const LecturaScreen({super.key, required this.lecturaId, required this.modo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lecturaState = ref.watch(lecturaProvider(lecturaId));
    final novedadState = ref.watch(novedadesProvider);

    return Scaffold(
      appBar: BarApp(
        title: (modo == LecturaModo.registrar || modo == LecturaModo.ruta)
            ? 'Registrar Lectura'
            : 'Editar lectura',
        actions: [
          ?(lecturaState.lectura == null)
              ? null
              : IconButton(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 100,
                    );
                    if (image != null) {
                      // 📌 Nueva lógica: comprimir + guardar oculto
                      final storedPath = await ImageService.saveAsWebP(
                        image.path,
                        lecturaState.lectura!.id,
                      );

                      ref
                          .read(
                            lecturaFormProvider(lecturaState.lectura!).notifier,
                          )
                          .addLecturaImage(storedPath);
                    }
                  },
                  icon: const Icon(Icons.camera_alt_outlined),
                ),
        ],
      ),
      body:
          lecturaState.isLoading ||
              novedadState.status == SearchStatus.initial ||
              novedadState.status == SearchStatus.loading
          ? LoadingIndicator(subtitle: "Cargando lectura...")
          : lecturaState.errorMessage.isNotEmpty
          ? Center(child: Text("Error: ${lecturaState.errorMessage}"))
          : (lecturaState.lectura == null)
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Tada(
                      child: Icon(
                        Icons.check_circle_outline,
                        color: Colors.green.shade600,
                        size: 100,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '¡Todas las lecturas han sido registradas!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
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
            )
          : _buildContent(
              context,
              ref,
              lecturaState.lectura!,
              modo,
              novedadState.novedades,
            ),
      floatingActionButton: lecturaState.lectura == null
          ? null
          : _BotonSave(lectura: lecturaState.lectura!, modo: modo),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    Lectura lectura,
    final LecturaModo modo,
    List<Novedad> novedades,
  ) {
    final form = ref.watch(lecturaFormProvider(lectura));
    return _ProductView(
      lectura: lectura,
      novedades: novedades,
      modo: modo,
      form: form,
    );
  }
}

class _ProductView extends ConsumerWidget {
  final Lectura lectura;
  final LecturaFormState form;
  final List<Novedad> novedades;
  final LecturaModo modo;

  const _ProductView({
    required this.lectura,
    required this.form,
    required this.novedades,
    required this.modo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(lecturaFormProvider(lectura), (prev, next) {
      if (next.isPosting && !(prev?.isPosting ?? false)) {
        Loader.openFullLoading(context);
      } else if (!next.isPosting && (prev?.isPosting ?? true)) {
        Loader.stopLoading(context);
      }
    });
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if ((modo == LecturaModo.ruta)) _HeaderRuta(lectura: lectura),
          //const SizedBox(height: 10),
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
                      //InfoRow(label: "", value: lectura.sector),
                      InfoRow(
                        label: "Cuenta:",
                        value: lectura.cuenta.toString(),
                      ),
                      InfoRow(label: "Medidor:", value: lectura.medidor),
                      InfoRow(
                        label: "Promedio (m³):",
                        value: lectura.promedioConsumo.toString(),
                      ),
                      InfoRow(label: "Cédula:", value: lectura.cedula),
                      InfoRow(
                        label: "Propietario:",
                        value: lectura.propietario,
                      ),
                      if (lectura.direccion != null)
                        InfoRow(label: "Dirección:", value: lectura.direccion!),
                    ],
                  ),
                ),
              ],
            ),
          ),

          _ProductInformation(
            lectura: lectura,
            novedades: novedades,
            form: form,
            modo: modo,
          ),
          const SizedBox(height: 4),
          _ImagenesLectura(lectura: lectura, modo: modo),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _HeaderRuta extends StatelessWidget {
  const _HeaderRuta({required this.lectura});

  final Lectura lectura;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(4),
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
              lectura.sector,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.primary.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductInformation extends ConsumerWidget {
  final Lectura lectura;
  final List<Novedad> novedades;
  final LecturaFormState form;
  final LecturaModo modo;
  const _ProductInformation({
    required this.lectura,
    required this.novedades,
    required this.form,
    required this.modo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Novedad defaultNovedad;
    final int? selectedNovedadId = form.novedadId?.value ?? lectura.novedadId;
    defaultNovedad = novedades.firstWhere(
      (m) => m.id == selectedNovedadId,
      orElse: () {
        // si no encontramos el id registrado, usamos la novedad por defecto (si existe)
        final defaultFromList = novedades.firstWhere(
          (m) => m.isDefault == true,
          orElse: () =>
              Novedad(id: -1, detalle: 'Sin registros', isDefault: false),
        );
        return defaultFromList;
      },
    );

    final editado = modo == LecturaModo.editar;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ChipInfo(
                label: "Lect. anterior (m³)",
                value: "${form.lecturaAnterior}",
                icon: Icons.water_drop_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ChipInfo(
                label: "Consumo (m³)",
                value: "${form.consumo}",
                icon: Icons.show_chart_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        CustomTextFormField(
          label: 'Lectura actual',
          autofocus: modo == LecturaModo.editar ? false : true,
          floating: true,
          hintText: '0',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          initialValue: form.lecturaActual.value?.toString() ?? '',
          onFieldSubmitted: (_) => ref
              .read(lecturaFormProvider(lectura).notifier)
              .onFormSubmit(editado),
          onChanged: (value) {
            ref
                .read(lecturaFormProvider(lectura).notifier)
                .onLecturaActualChanged(int.tryParse(value));
          },
          errorMessage: form.lecturaActual.errorMessage,
          prefixIcon: Icon(Icons.speed_rounded),
        ),
        const SizedBox(height: 12),
        NovedadSelector(
          label: 'Novedad',
          isSearch: true,
          hintText: 'Seleccionar novedad..',
          items: novedades,
          errorText: form.novedadId?.errorMessage,
          initialValue: defaultNovedad,
          onChanged: (novedad) {
            ref
                .read(lecturaFormProvider(lectura).notifier)
                .onNovedadChanged(novedad.id);
          },
        ),
        const SizedBox(height: 12),
        CustomTextFormField(
          label: 'Observaciones',
          hintText: 'Mas detalle...',
          maxLines: 3,
          initialValue: form.observacion ?? '',
          keyboardType: TextInputType.multiline,
          onChanged: ref
              .read(lecturaFormProvider(lectura).notifier)
              .onDescriptionChanged,
        ),
      ],
    );
  }
}

class _BotonSave extends ConsumerWidget {
  final Lectura lectura;
  final LecturaModo modo;
  const _BotonSave({required this.lectura, required this.modo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editado = modo == LecturaModo.editar;
    return FloatingActionButton.extended(
      label: Text(
        modo == LecturaModo.editar ? "Actualizar" : "Registrar lectura",
      ),
      icon: const Icon(Icons.save),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      onPressed: () async {
        final formNotifier = ref.read(lecturaFormProvider(lectura).notifier);

        final success = await formNotifier.onFormSubmit(editado);

        if (!context.mounted) return;

        if (!success) {
          Notifications.error(context, "Complete todos los campos.");
          return;
        }

        if (modo == LecturaModo.registrar) {
          // actualizar avance y cerrar
          Notifications.success(context, "Se registro correctamente.");
          ref.read(searchLecturaProvider.notifier).deleteById(lectura.id);
          ref.read(periodoProvider.notifier).refreshAvance();
          formNotifier.stop();
          context.pop();
        } else if (modo == LecturaModo.editar) {
          Notifications.success(context, "Se actualizó correctamente.");
          ref.read(periodoProvider.notifier).refreshAvance();
          ref.read(lecturasRegistradoslProvider.notifier).filtrarPorRegistrado(1);
          formNotifier.stop();
          context.pop();
        } else if (modo == LecturaModo.ruta) {
          // NO cerrar; cargar siguiente medidor en la ruta
          Notifications.success(
            context,
            "Lectura guardada. Cargando siguiente...",
          );
          ref.read(periodoProvider.notifier).filterByRuta(lectura.rutaId);

          // 🔥 Cargar el siguiente medidor DESDE EL SERVICIO
          final repo = ref.read(lecturasRepositoryProvider);

          final next = await repo.getLecturaOrden(lectura.rutaId);
          if (context.mounted) {
            if (next == null) {
              Notifications.success(context, "No hay más lecturas.");
              context.pop();
              return;
            }

            if (!context.mounted) return;
            formNotifier.stop();
            // 👉 Redireccionar al siguiente medidor
            context.pushReplacement('/lectura/$next', extra: LecturaModo.ruta);
          }
        }
      },
    );
  }
}

class _ImagenesLectura extends ConsumerWidget {
  final Lectura lectura;
  final LecturaModo modo;
  const _ImagenesLectura({required this.lectura, required this.modo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lecturaForm = ref.watch(lecturaFormProvider(lectura));
    final notifier = ref.read(lecturaFormProvider(lectura).notifier);
    final editado = modo == LecturaModo.editar;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Fotos del medidor (opcional)",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              final picker = ImagePicker();
              final XFile? image = await picker.pickImage(
                source: ImageSource.camera,
                imageQuality: 100,
              );
              if (image != null) {
                // 📌 Nueva lógica: comprimir + guardar oculto
                final storedPath = await ImageService.saveAsWebP(
                  image.path,
                  lectura.id,
                );

                notifier.addLecturaImage(storedPath);
              }
            },
            icon: const Icon(
              Icons.camera_alt_outlined,
              color: AppColors.primary,
            ),
            label: const Text(
              "Tomar foto",
              style: TextStyle(color: AppColors.primary),
            ),
            /* style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Radio del botón
              ),
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 6),
            ), */
          ),
        ),
        const SizedBox(height: 4),
        lecturaForm.imagenes.isEmpty
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
                  itemCount: lecturaForm.imagenes.length,
                  // ignore: unnecessary_underscores
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final path = lecturaForm.imagenes[index];
                    late ImageProvider imageProvider;
                    if (path.startsWith('http')) {
                      imageProvider = NetworkImage(path);
                    } else {
                      imageProvider = FileImage(File(path));
                    }
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
                              image: imageProvider,
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
                                  notifier.removeLecturaImage(path, editado),
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
