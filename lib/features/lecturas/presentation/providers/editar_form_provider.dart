import 'package:flutter_riverpod/legacy.dart';
import 'package:formz/formz.dart';
import 'package:nexsys_app/core/services/services.dart';
import 'package:nexsys_app/features/auth/presentation/presentation.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';
import 'package:nexsys_app/features/lecturas/presentation/presentation.dart';
import 'package:nexsys_app/shared/inputs/inputs.dart';

final productFormProvider = StateNotifierProvider.autoDispose
    .family<ProductFormNotifier, ProductFormState, Lectura>((ref, product) {
      // final createUpdateCallback = ref.watch( productsRepositoryProvider ).createUpdateProduct;
      //final createUpdateCallback = ref.watch( productsProvider.notifier ).createOrUpdateProduct;
      final updateCallback = ref.watch(lecturasProvider.notifier).updateProduct;
      final authState = ref.watch(authProvider); // tu valor por defecto

      return ProductFormNotifier(
        lectura: product,
        onSubmitCallback: updateCallback,
        userId: authState.user!.id,
      );
    });

class ProductFormNotifier extends StateNotifier<ProductFormState> {
  final Future<bool> Function(Map<String, dynamic> lecturaLike)?
  onSubmitCallback;

  final int userId;

  ProductFormNotifier({
    this.onSubmitCallback,
    required this.userId,
    required Lectura lectura,
  }) : super(
         ProductFormState(
           id: lectura.id,
           medidor: lectura.medidor,
           cuenta: lectura.cuenta.toString(),
           propietario: lectura.propietario,
           cedula: lectura.cedula,
           lecturaAnterior: lectura.lecturaAnterior,
           consumo: lectura.consumo ?? 0,
           lecturaActual: lectura.lecturaActual != null
               ? LecturaActual.dirty(
                   lectura.lecturaActual!,
                   lecturaAnterior: lectura.lecturaAnterior,
                 )
               : LecturaActual.pure(lecturaAnterior: lectura.lecturaAnterior),
           imagenes: lectura.imagenes,
           novedadId: NovedadInput.dirty(lectura.novedadId),
         ),
       );

  void updateProductImage(String path) {
    state = state.copyWith(imagenes: [...state.imagenes, path]);
  }

  void _touchedEverything() {
    final lecturaActualTouched = LecturaActual.dirty(
      state.lecturaActual.value,
      lecturaAnterior: state.lecturaAnterior,
    );

    final novedadTouched = NovedadInput.dirty(state.novedadId?.value);

    state = state.copyWith(
      lecturaActual: lecturaActualTouched,
      novedadId: novedadTouched,
      isFormValid: Formz.validate([lecturaActualTouched, novedadTouched]),
    );
  }

  void onLecturaActualChanged(int? value) {
    final newLecturaActual = LecturaActual.dirty(
      value,
      lecturaAnterior: state.lecturaAnterior,
    );

    // Calcular consumo automáticamente
    final consumo = (value != null && value > state.lecturaAnterior)
        ? value - state.lecturaAnterior
        : 0;

    state = state.copyWith(
      lecturaActual: newLecturaActual,
      consumo: consumo,
      isFormValid: Formz.validate([newLecturaActual, ?state.novedadId]),
    );
  }

  void onNovedadChanged(int? value) {
    final newNovedad = NovedadInput.dirty(value);
    state = state.copyWith(
      novedadId: newNovedad,
      isFormValid: Formz.validate([newNovedad, state.lecturaActual]),
    );
  }

  Future<bool> onFormSubmit() async {
    _touchedEverything();

    if (!state.isFormValid) return false;
    if (onSubmitCallback == null) return false;

    try {
      state = state.copyWith(isPosting: true);
      // 🔍 Obtener geolocalización actual
      final position = await LocationService.getCurrentPosition();

      final lecturaLike = {
        'id': state.id,
        'lectura_actual': state.lecturaActual.value,
        'descripcion': state.observacion,
        'imagenes': state.imagenes,
        'consumo': state.consumo,
        'novedad_id': state.novedadId?.value,
        'fecha_lectura': DateTime.now().toString(),
        'empleado_id': userId,
        'latitud': position?.latitude,
        'longitud': position?.longitude,
        'images': state.imagenes,
      };

      //debugPrint("📍 Lectura con ubicación: $lecturaLike");
      await onSubmitCallback!(lecturaLike);
      state = state.copyWith(isPosting: false);
      return true;
    } catch (_) {
      state = state.copyWith(isPosting: false);
      return false;
    }
  }

  void onDescriptionChanged(String description) {
    state = state.copyWith(observacion: description);
  }

  void addLecturaImage(String path) {
    final updatedList = [path, ...state.imagenes];
    state = state.copyWith(imagenes: updatedList);
  }

  void removeLecturaImage(String path) {
    final updatedList = state.imagenes.where((img) => img != path).toList();
    state = state.copyWith(imagenes: updatedList);
  }

  void clearAllImages() {
    state = state.copyWith(imagenes: []);
  }
}

class ProductFormState {
  final bool isFormValid;
  final int id;
  final String medidor;
  final String cuenta;
  final String propietario;
  final String cedula;
  final int lecturaAnterior;
  final LecturaActual lecturaActual;
  final String? observacion;
  final int consumo;
  final NovedadInput? novedadId;
  final bool isPosting;
  final List<String> imagenes;

  ProductFormState({
    this.isFormValid = false,
    required this.id,
    required this.medidor,
    required this.cuenta,
    required this.propietario,
    required this.cedula,
    required this.lecturaAnterior,
    this.novedadId,
    this.lecturaActual = const LecturaActual.pure(),
    this.observacion,
    this.consumo = 0,
    this.imagenes = const [],
    this.isPosting = false,
  });

  ProductFormState copyWith({
    bool? isFormValid,
    int? id,
    String? medidor,
    String? cuenta,
    String? propietario,
    String? cedula,
    int? lecturaAnterior,
    LecturaActual? lecturaActual,
    String? observacion,
    int? consumo,
    NovedadInput? novedadId,
    List<String>? imagenes,
    bool? isPosting,
  }) {
    return ProductFormState(
      isFormValid: isFormValid ?? this.isFormValid,
      id: id ?? this.id,
      medidor: medidor ?? this.medidor,
      cuenta: cuenta ?? this.cuenta,
      propietario: propietario ?? this.propietario,
      cedula: cedula ?? this.cedula,
      lecturaAnterior: lecturaAnterior ?? this.lecturaAnterior,
      lecturaActual: lecturaActual ?? this.lecturaActual,
      observacion: observacion ?? this.observacion,
      consumo: consumo ?? this.consumo,
      novedadId: novedadId ?? this.novedadId,
      imagenes: imagenes ?? this.imagenes,
      isPosting: isPosting ?? this.isPosting,
    );
  }
}
