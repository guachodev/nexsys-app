import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

class LecturaScreen extends ConsumerWidget {
  final Lectura lectura;

  const LecturaScreen({super.key, required this.lectura});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lecturaState = ref.watch(lecturaProvider(lectura));
    ref.listen<LecturaFormState>(lecturaFormProvider(lectura), (
      previous,
      next,
    ) {
      if (next.isPosting && (previous?.isPosting ?? false) == false) {
        Loader.openFullLoading(context);
      }

      if (!next.isPosting && (previous?.isPosting ?? true) == true) {
        Loader.stopLoading(context);
      }
    });
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: Text('Registrar lectura ${lectura.id}')),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                AlertBanner(),
                _InfoMedidor(lectura: lecturaState.lectura!),
                _FormView(lecturaState: lecturaState),
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
    return Container(
      margin: const EdgeInsets.only(top: 6),
      child: Column(
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
      ),
    );
  }
}

class _FormView extends ConsumerWidget {
  final LecturaState lecturaState;
  const _FormView({required this.lecturaState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lecturaForm = ref.watch(lecturaFormProvider(lecturaState.lectura!));
    final novedades = [
      {"id": null, "name": "Seleccionar...", "default": false},
      {"id": 8, "name": "CAMBIO DE MEDIDOR", "default": false},
      {"id": 1, "name": "ERROR DE DIGITACION", "default": false},
      {"id": 6, "name": "LECTURA INICIAL", "default": false},
      {"id": 4, "name": "MEDIDOR MANIPULADO", "default": false},
      {
        "id": 3,
        "name":
            "MEDIDOR NO VISIBLE 1145314532012 ASDEWE 1456165435111456 ERWSFXSDF SDFSSFD",
        "default": false,
      },
      {"id": 2, "name": "PERRO BRAVO", "default": false},
      {"id": 7, "name": "REUBICAR MEDIDOR", "default": false},
      {"id": 5, "name": "SIN NOVEDAD", "default": true},
    ].map((e) => NovedadMapper.jsonToEntity(e)).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: EdgeInsets.zero,
      child: Column(
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
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            initialValue: lecturaForm.lecturaActual.value?.toString() ?? '',
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
            //initialValue: novedades.firstWhere((m) => m.isDefault == true),
            onChanged: (novedad) {
              ref
                  .read(lecturaFormProvider(lecturaState.lectura!).notifier)
                  .onNovedadChanged(novedad.id);
            },
          ),

          const SizedBox(height: AppDesignTokens.spacingL),
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
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Foto del medidor",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(height: 4),

          /* PhotoViewerWithActions(
            initialImageUrl: lecturaForm.image,
            onTakePhoto: () async {
              final photoPath = await CameraService().takePhoto();
              if (photoPath != null) {
                ref
                    .read(lecturaFormProvider(lecturaState.lectura!).notifier)
                    .updateLecturaImage(photoPath);
              }
            },
            showDeleteButton: false,
            onDeletePhoto: () => ref
                .read(lecturaFormProvider(lecturaState.lectura!).notifier)
                .cleanLecturaImage(),
          ), */
          /* Row(
            children: [
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: lecturaForm.image == null && lecturaForm.image!.isEmpty
                        ? Colors.indigo
                        : Colors.grey,
                    foregroundColor: lecturaForm.image == null && lecturaForm.image!.isEmpty
                        ? Colors.white
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        lecturaForm.image == null && lecturaForm.image!.isEmpty
                            ? Icons.camera_alt
                            : Icons.camera_alt_outlined,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        lecturaForm.image == null && lecturaForm.image!.isEmpty
                            ? 'Tomar foto'
                            : 'Cambiar foto',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              if (lecturaForm.image != null &&
                  lecturaForm.image!.isNotEmpty) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    ref
                        .read(
                          lecturaFormProvider(lecturaState.lectura!).notifier,
                        )
                        .cleanLecturaImage();
                  },
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade600),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.photo_rounded, color: Colors.indigo),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.indigo.shade50,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ],
          ), */
         /*  GestureDetector(
            onTap: () async {
              final ImagePicker picker = ImagePicker();

              // Abrir cámara
              final pickedFile = await picker.pickImage(
                source: ImageSource.camera,
                preferredCameraDevice: CameraDevice.rear,
                imageQuality: 70,
              );

              // Si el usuario cancela
              if (pickedFile == null) return;

              // Actualizar estado
              ref
                  .read(lecturaFormProvider(lecturaState.lectura!).notifier)
                  .updateLecturaImage(pickedFile.path);
            },
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: (lecturaForm.image == null || lecturaForm.image!.isEmpty)
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_rounded,
                          color: Colors.grey.shade400,
                          size: 50,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Tocar para agregar foto",
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          'Toca para tomar foto',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'La foto es obligatoria para el registro',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: FadeInImage(
                        fit: BoxFit.cover,
                        height: 200,
                        fadeOutDuration: const Duration(milliseconds: 100),
                        fadeInDuration: const Duration(milliseconds: 200),
                        image: FileImage(File(lecturaForm.image!)),
                        placeholder: const AssetImage(
                          'assets/images/loading-image.webp',
                        ),
                      ),
                    ),
            ),
          ),
           */const SizedBox(height: AppDesignTokens.spacingL),
          FilledButton(
            onPressed: () async {
              if (lecturaState.lectura == null) return;
              ref
                  .read(lecturaFormProvider(lecturaState.lectura!).notifier)
                  .onFormSubmit()
                  .then((value) {
                    if (!value) return;
                    if (value) {
                      SnackbarService.success(
                        context,
                        "Lectura registrada con éxito",
                      );
                      if (context.mounted) {
                        context.pop();
                      }
                      ref
                          .read(searchLecturaProvider.notifier)
                          .deleteById(lecturaForm.id);
                    } else {
                      SnackbarService.error(
                        context,
                        "Error al registrar la lectura",
                      );
                    }
                  });
            },
            style: FilledButton.styleFrom(
              //backgroundColor: _canSubmit() ? Colors.blue.shade600 : Colors.grey.shade400,
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
      ),
    );
  }

  /* Future<void> _takePhoto() async {
    final photoPath = await CameraService().takePhoto();
    if (photoPath != null) {
      debugPrint(photoPath);
      //setState(() => _currentPhotoPath = photoPath);
      ref.read(lecturaFormProvider(lectura).notifier)
          .updateLecturaImage(photoPath);
      // Mostrar snackbar de confirmación
      /*  ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade400),
              const SizedBox(width: 8),
              const Text('Foto tomada exitosamente'),
            ],
          ),
          backgroundColor: Colors.green.shade50,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: AppDesignTokens.borderRadiusMedium,
          ),
        ),
      ); */
    }
  } */
}

// Widget adicional para labels requeridos
class RequiredFieldLabel extends StatelessWidget {
  final String text;

  const RequiredFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextInputType keyboardType;
  final String? suffixText;
  final int? maxLines;
  final int? maxLength;
  final bool isRequired;
  final String? initialValue;
  final String? errorMessage;
  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.suffixText,
    this.maxLines = 1,
    this.maxLength,
    this.isRequired = false,
    this.initialValue,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        TextFormField(
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          initialValue: initialValue,
          decoration: InputDecoration(
            errorText: errorMessage,
            hintText: hintText,
            suffixIcon: suffixText != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      suffixText!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
        ),
      ],
    );
  }
}
