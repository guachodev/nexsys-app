import 'package:flutter_riverpod/legacy.dart';
import 'package:formz/formz.dart';
import 'package:nexsys_app/core/services/services.dart';
import 'package:nexsys_app/features/auth/presentation/presentation.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart' hide Novedad;
import 'package:nexsys_app/features/lecturas/presentation/presentation.dart';
import 'package:nexsys_app/shared/inputs/inputs.dart';

final lecturaFormProvider =
    StateNotifierProvider.family<
      LecturaFormNotifier,
      LecturaFormState,
      Lectura
    >((ref, lectura) {
      final updateCallback = ref.watch(lecturasProvider.notifier).updateProduct;
      final authState = ref.watch(authProvider); // tu valor por defecto
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
    int? defaultNovedadId,
  }) : super(
         LecturaFormState(
           id: lectura.id,
           lecturaAnterior: lectura.lecturaAnterior,
           medidor: lectura.medidor,
           cuenta: lectura.cuenta.toString(),
           propietario: lectura.propietario,
           cedula: lectura.cedula,
           consumo: 0,
           lecturaActual: LecturaActual.pure(
             lecturaAnterior: lectura.lecturaAnterior,
           ),
           novedadId: Novedad.dirty(25), // ✅ Aquí asignamos la novedad por defecto
           observacion: '',
           images: [],
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
        'imagenes': state.images,
        'consumo': state.consumo,
        'novedad_id': state.novedadId?.value,
        'fecha_lectura': DateTime.now().toString(),
        'empleado_id': userId,
        'latitud': position?.latitude,
        'longitud': position?.longitude,
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

  void loadNewLectura(Lectura nuevaLectura, int? novedadId) {
    state = LecturaFormState(
      id: nuevaLectura.id,
      isPosting: false,
      lecturaAnterior: nuevaLectura.lecturaAnterior,
      medidor: nuevaLectura.medidor,
      cuenta: nuevaLectura.cuenta.toString(),
      propietario: nuevaLectura.propietario,
      cedula: nuevaLectura.cedula,
      lecturaActual: LecturaActual.pure(
        lecturaAnterior: nuevaLectura.lecturaAnterior,
      ),
      novedadId: Novedad.dirty(novedadId),
    );
  }

  void reset() {
    state = LecturaFormState(
      id: -1,
      medidor: '',
      cuenta: '',
      propietario: '',
      cedula: '',
      lecturaAnterior: 0,
      lecturaActual: LecturaActual.pure(lecturaAnterior: 0),
      novedadId: Novedad.pure(),
      observacion: '',
      consumo: 0,
      images: [],
      isPosting: false,
    );
  }

  void onDescriptionChanged(String description) {
    state = state.copyWith(observacion: description);
  }

  void addLecturaImage(String path) {
    final updatedList = [path, ...state.images];
    state = state.copyWith(images: updatedList);
  }

  void removeLecturaImage(String path) {
    final updatedList = state.images.where((img) => img != path).toList();
    state = state.copyWith(images: updatedList);
  }

  void clearAllImages() {
    state = state.copyWith(images: []);
  }

  Future<void> setDefaultNovedadFromApi() async {
    if (state.novedadId?.value != null) return;

    try {
      //final defaultNovedadId = await ();
      state = state.copyWith(novedadId: Novedad.dirty(25));
    } catch (e) {
      // manejar error si la consulta falla
    }
  }
}

class LecturaFormState {
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
  final Novedad? novedadId;
  final List<String> images;
  final bool isPosting;

  LecturaFormState({
    this.isFormValid = false,
    required this.id,
    required this.medidor,
    required this.cuenta,
    required this.propietario,
    required this.cedula,
    required this.lecturaAnterior,
    this.lecturaActual = const LecturaActual.pure(),
    this.novedadId,
    this.observacion,
    this.consumo = 0,
    this.images = const [],
    this.isPosting = false,
  }) {
    //lecturaActual = LecturaActual.pure();
  }

  LecturaFormState copyWith({
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
    Novedad? novedadId,
    List<String>? images,
    bool? isPosting,
  }) {
    return LecturaFormState(
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
      images: images ?? this.images,
      isPosting: isPosting ?? this.isPosting,
    );
  }

  @override
  String toString() {
    return '''
LecturaFormState(
  isFormValid: $isFormValid,
  id: $id,
  medidor: $medidor,
  cuenta: $cuenta,
  propietario: $propietario,
  cedula: $cedula,
  lecturaAnterior: $lecturaAnterior,
  lecturaActual: $lecturaActual,
  observacion: $observacion,
  consumo: $consumo,
  novedadId: $novedadId,
  images: $images,
  isPosting: $isPosting
)''';
  }
}
