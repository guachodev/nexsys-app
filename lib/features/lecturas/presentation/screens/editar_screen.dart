import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nexsys_app/core/services/services.dart';
import 'package:nexsys_app/core/theme/app_colors.dart';
import 'package:nexsys_app/core/utils/utils.dart';
import 'package:nexsys_app/features/lecturas/data/data.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';
import 'package:nexsys_app/features/lecturas/presentation/presentation.dart';
import 'package:nexsys_app/shared/widgets/widgets.dart';

import '../widgets/novedad_selector.dart';

class EditarScreen extends ConsumerWidget {
  final String productId;

  const EditarScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productState = ref.watch(productProvider(productId));

    ref.listen<ProductFormState>(productFormProvider(productState.lectura!), (
      prev,
      next,
    ) {
      if (next.isPosting && !(prev?.isPosting ?? false)) {
        Loader.openFullLoading(context);
      } else if (!next.isPosting && (prev?.isPosting ?? true)) {
        Loader.stopLoading(context);
      }
    });

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: BarApp(
          title: 'Editar Lectura',
          actions: [
            IconButton(
              onPressed: () async {
                final photoPath = await CameraGalleryServiceImpl()
                    .selectPhoto();
                if (photoPath == null) return;

                ref
                    .read(productFormProvider(productState.lectura!).notifier)
                    .updateProductImage(photoPath);
              },
              icon: Icon(Icons.photo_library_outlined),
            ),

            IconButton(
              onPressed: () async {
                /* final photoPath = await CameraPlusService().takePhoto();
                if (photoPath == null) return;

                ref
                    .read(productFormProvider(productState.lectura!).notifier)
                    .updateProductImage(photoPath); */
              },
              icon: Icon(Icons.camera_alt_outlined),
            ),
          ],
        ),

        body: productState.isLoading
            ? _FullScreenLoader()
            : _ProductView(lectura: productState.lectura!),
        floatingActionButton: _BotonSave(lectura: productState.lectura!),
      ),
    );
  }
}

class _BotonSave extends ConsumerWidget {
  final Lectura lectura;
  const _BotonSave({required this.lectura});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
      label: const Text('Actualizar lectura'),
      icon: const Icon(Icons.save_as_rounded),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      onPressed: () async {
        final formNotifier = ref.read(productFormProvider(lectura).notifier);

        final success = await formNotifier.onFormSubmit();

        if (!success) {
          SnackbarService.error(context, "Complete todos los campos.");
          return;
        }
        //ref.read(searchLecturaProvider.notifier).deleteById(lectura.id);
        //ref.read(periodoProvider.notifier).refreshAvance();
        ref.read(lecturasLocalProvider.notifier).cargarLecturas();
        SnackbarService.success(context, "Se actualizo correctamente.");
        context.pop();

      },
    );
  }
}

class _FullScreenLoader extends StatelessWidget {
  const _FullScreenLoader();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

class _ProductView extends ConsumerWidget {
  final Lectura lectura;

  const _ProductView({required this.lectura});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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
                    bottom: BorderSide(color: Colors.grey.shade400, width: 1.2),
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
                    InfoRow(label: "Cuenta:", value: lectura.cuenta.toString()),
                    InfoRow(label: "Medidor:", value: lectura.medidor),
                    InfoRow(
                      label: "Promedio (m³):",
                      value: lectura.cuenta.toString(),
                    ),
                    InfoRow(label: "Cédula:", value: lectura.cedula),
                    InfoRow(label: "Propietario:", value: lectura.propietario),
                  ],
                ),
              ),
            ],
          ),
        ),

        _ProductInformation(lectura: lectura),
        const SizedBox(height: 4),
        _ImagenesLectura(lectura: lectura),
        const SizedBox(height: 50),
      ],
    );
  }
}

class _ProductInformation extends ConsumerWidget {
  final Lectura lectura;
  const _ProductInformation({required this.lectura});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lecturaForm = ref.watch(productFormProvider(lectura));
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

    /* if (lecturaForm.novedadId?.value == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(productFormProvider(lectura).notifier)
            .onNovedadChanged(defaultNovedad.id);
      });
    } */

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          autofocus: false,
          floating: true,
          hintText: '0',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          initialValue: lecturaForm.lecturaActual.value?.toString() ?? '',
          onFieldSubmitted: (_) =>
              ref.read(productFormProvider(lectura).notifier).onFormSubmit(),
          onChanged: (value) {
            ref
                .read(productFormProvider(lectura).notifier)
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
                .read(productFormProvider(lectura).notifier)
                .onNovedadChanged(novedad.id);
          },
        ),
        const SizedBox(height: 12),
        CustomTextFormField(
          label: 'Observaciones',
          hintText: 'Mas detalle...',
          maxLines: 3,
          initialValue: lecturaForm.observacion ?? '',
          keyboardType: TextInputType.multiline,
          onChanged: ref
              .read(productFormProvider(lectura).notifier)
              .onDescriptionChanged,
        ),
      ],
    );
  }
}

class _ImagenesLectura extends ConsumerWidget {
  final Lectura lectura;
  const _ImagenesLectura({required this.lectura});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lecturaForm = ref.watch(productFormProvider(lectura));
    final notifier = ref.read(productFormProvider(lectura).notifier);

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
