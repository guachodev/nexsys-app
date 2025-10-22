import 'package:flutter_riverpod/legacy.dart';
import 'package:formz/formz.dart';
import 'package:nexsys_app/core/services/services.dart';
import 'package:nexsys_app/features/auth/presentation/presentation.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart' hide Novedad;
import 'package:nexsys_app/features/lecturas/presentation/presentation.dart';
import 'package:nexsys_app/shared/shared.dart';

final lecturaFormProvider = StateNotifierProvider.autoDispose
    .family<LecturaFormNotifier, LecturaFormState, Lectura>((ref, lectura) {
      final updateCallback = ref.watch(lecturasProvider.notifier).updateProduct;
      final authState = ref.watch(authProvider);
      return LecturaFormNotifier(
        lectura: lectura,
        onSubmitCallback: updateCallback,
        userId: authState.user?.empleadoId,
      );
    });

class LecturaFormNotifier extends StateNotifier<LecturaFormState> {
  final Future<bool> Function(Map<String, dynamic> lecturaLike)?
  onSubmitCallback;

  final int? userId;

  LecturaFormNotifier({
    this.onSubmitCallback,
    required Lectura lectura,
    this.userId,
  }) : super(
         LecturaFormState(
           id: lectura.id,
           isPosting: false,
           lecturaAnterior: lectura.lecturaAnterior,
           medidor: lectura.medidor,
           catastro: lectura.catastro,
           propietario: lectura.propietario,
           cedula: lectura.cedula,
           periodo: lectura.periodo,
           lecturaActual: LecturaActual.pure(
             lecturaAnterior: lectura.lecturaAnterior,
           ),
           novedadId: Novedad.pure(),
         ),
       );

  void _touchedEverything() {
    final lecturaActualTouched = LecturaActual.dirty(
      state.lecturaActual.value,
      lecturaAnterior: state.lecturaAnterior,
    );

    final novedadTouched = Novedad.dirty(state.novedadId?.value);

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
      isFormValid: Formz.validate([
        newLecturaActual,
        if (state.novedadId != null) state.novedadId!,
      ]),
    );
  }

  void onNovedadChanged(int? value) {
    final newNovedad = Novedad.dirty(value);
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
        'image': state.image,
        'consumo': state.consumo,
        'novedad_id': state.novedadId?.value,
        'fecha_lectura': DateTime.now().toString(),
        'empleado_id': userId,
        'latitud': position?.latitude,
        'longitud': position?.longitude,
      };

      print("📍 Lectura con ubicación: $lecturaLike");
      await onSubmitCallback!(lecturaLike);
      state = state.copyWith(isPosting: false);
      return true;
    } catch (_) {
      state = state.copyWith(isPosting: false);
      return false;
    }
  }

  void loadNewLectura(Lectura nuevaLectura, int? novedadId) {
    state = LecturaFormState(
      id: nuevaLectura.id,
      isPosting: false,
      lecturaAnterior: nuevaLectura.lecturaAnterior,
      medidor: nuevaLectura.medidor,
      catastro: nuevaLectura.catastro,
      propietario: nuevaLectura.propietario,
      cedula: nuevaLectura.cedula,
      periodo: nuevaLectura.periodo,
      lecturaActual: LecturaActual.pure(
        lecturaAnterior: nuevaLectura.lecturaAnterior,
      ),
      novedadId: Novedad.dirty(novedadId),
    );
  }

  void onDescriptionChanged(String description) {
    state = state.copyWith(observacion: description);
  }

  void updateLecturaImage(String path) {
    state = state.copyWith(image: path);
  }

  void cleanLecturaImage() {
    state = state.copyWith(image: '');
  }
}

class LecturaFormState {
  final bool isFormValid;
  final int id;
  final String medidor;
  final String catastro;
  final String propietario;
  final String cedula;
  final String periodo;
  final int lecturaAnterior;
  final LecturaActual lecturaActual;
  final String? observacion;
  final int consumo;
  final Novedad? novedadId;
  final String? image;
  final bool isPosting;

  LecturaFormState({
    this.isFormValid = false,
    required this.id,
    required this.medidor,
    required this.catastro,
    required this.propietario,
    required this.cedula,
    required this.periodo,
    required this.lecturaAnterior,
    this.lecturaActual = const LecturaActual.pure(),
    this.novedadId,
    this.observacion,
    this.consumo = 0,
    this.image,
    this.isPosting = false,
  }) {
    //lecturaActual = LecturaActual.pure();
  }

  LecturaFormState copyWith({
    bool? isFormValid,
    int? id,
    String? medidor,
    String? catastro,
    String? propietario,
    String? cedula,
    String? periodo,
    int? lecturaAnterior,
    LecturaActual? lecturaActual,
    String? observacion,
    int? consumo,
    Novedad? novedadId,
    String? image,
    bool? isPosting,
  }) {
    return LecturaFormState(
      isFormValid: isFormValid ?? this.isFormValid,
      id: id ?? this.id,
      medidor: medidor ?? this.medidor,
      catastro: catastro ?? this.catastro,
      propietario: propietario ?? this.propietario,
      cedula: cedula ?? this.cedula,
      periodo: periodo ?? this.periodo,
      lecturaAnterior: lecturaAnterior ?? this.lecturaAnterior,
      lecturaActual: lecturaActual ?? this.lecturaActual,
      observacion: observacion ?? this.observacion,
      consumo: consumo ?? this.consumo,
      novedadId: novedadId ?? this.novedadId,
      image: image ?? this.image,
      isPosting: isPosting ?? this.isPosting,
    );
  }

  @override
  String toString() {
    return 'Lectura(id: $id, medidor: $medidor, propietario: $propietario)';
  }
}
