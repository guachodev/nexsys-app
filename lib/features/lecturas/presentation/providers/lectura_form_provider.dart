import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:formz/formz.dart';
import 'package:nexsys_app/core/services/services.dart';
import 'package:nexsys_app/features/auth/presentation/presentation.dart';
import 'package:nexsys_app/features/lecturas/data/dao/lectura_dao.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';
import 'package:nexsys_app/shared/inputs/inputs.dart';

import 'lecturas_provider.dart';

final lecturaFormProvider = StateNotifierProvider.autoDispose
    .family<LecturaFormNotifier, LecturaFormState, Lectura>((ref, lectura) {
      final updateCallback = ref.watch(lecturasProvider.notifier).updateProduct;
      final auth = ref.watch(authProvider).user!;
      return LecturaFormNotifier(
        lectura: lectura,
        responsableId: auth.empleadoId,
        onSubmitCallback: updateCallback,
      );
    });

class LecturaFormNotifier extends StateNotifier<LecturaFormState> {
  final Future<bool> Function(Map<String, dynamic> lecturaLike)?
  onSubmitCallback;
  final int responsableId;

  LecturaFormNotifier({
    required Lectura lectura,
    required this.responsableId,
    this.onSubmitCallback,
  }) : super(
         LecturaFormState(
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
           baseId: lectura.baseId!,
           observacion: lectura.observacion,
           rutaId: lectura.rutaId,
           sector: lectura.sector,
           periodo: lectura.periodo,
         ),
       );

  void onNovedadChanged(int? value) {
    final newNovedad = NovedadInput.dirty(value);
    state = state.copyWith(
      novedadId: newNovedad,
      isFormValid: Formz.validate([newNovedad, state.lecturaActual]),
    );
  }

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

    // ✔ Novedad segura para validación
    final novedadForValidation =
        state.novedadId ?? const NovedadInput.pure(null);

    state = state.copyWith(
      lecturaActual: newLecturaActual,
      consumo: consumo,
      isFormValid: Formz.validate([newLecturaActual, novedadForValidation]),
    );
  }

  Future<bool> onFormSubmit(bool? editado) async {
    _touchedEverything();

    if (!state.isFormValid) return false;
    if (onSubmitCallback == null) return false;

    state = state.copyWith(isPosting: true);
    try {
      final Map<String, dynamic> lecturaLike = {
        'id': state.id,
        'baseId': state.baseId,
        'lectura_actual': state.lecturaActual.value,
        'descripcion': state.observacion,
        'imagenes': state.imagenes,
        'consumo': state.consumo,
        'novedad_id': state.novedadId?.value,
        'empleado_id': responsableId,
        'rutaId': state.rutaId,
        'sector': state.sector,
        'periodo': state.periodo,
        'editado': editado,
      };

      // 📍 Solo si NO es edición
      if (editado != true) {
        final position = await LocationService.getCurrentPosition();
        lecturaLike.addAll({
          'fecha_lectura': DateTime.now().toIso8601String(),
          'latitud': position?.latitude,
          'longitud': position?.longitude,
        });
      }

      debugPrint("📍 Lectura enviada: $lecturaLike");

      await onSubmitCallback!(lecturaLike);

      //state = state.copyWith(isPosting: false);
      return true;
    } catch (_) {
      state = state.copyWith(isPosting: false);
      return false;
    }
  }

  void stop() {
    state = state.copyWith(isPosting: false);
  }

  void onDescriptionChanged(String description) {
    state = state.copyWith(observacion: description);
  }

  void addLecturaImage(String path) {
    final updatedList = [path, ...state.imagenes];
    state = state.copyWith(imagenes: updatedList);
  }

  Future<void> removeLecturaImage(String path, bool deleteFromDb) async {
    if (deleteFromDb) {
      await LecturaDao.deleteByPath(path);
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }

    final updatedList = state.imagenes.where((img) => img != path).toList();
    state = state.copyWith(imagenes: updatedList);
  }

  void clearAllImages() {
    state = state.copyWith(imagenes: []);
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
      novedadId: NovedadInput.dirty(novedadId ?? nuevaLectura.novedadId),
      baseId: nuevaLectura.baseId!,
      imagenes: nuevaLectura.imagenes,
      observacion: '',
      consumo: 0,
      isFormValid: false,
      rutaId: -1,
      sector: '',
      periodo: '',
    );
  }
}

class LecturaFormState {
  final bool isFormValid;
  final int id;
  final int baseId;
  final int rutaId;
  final String medidor;
  final String cuenta;
  final String propietario;
  final String cedula;
  final String sector;
  final String periodo;
  final int lecturaAnterior;
  final LecturaActual lecturaActual;
  final String? observacion;
  final int consumo;
  final NovedadInput? novedadId;
  final bool isPosting;
  final List<String> imagenes;

  LecturaFormState({
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
    required this.baseId,
    required this.rutaId,
    required this.sector,
    required this.periodo,
  });

  LecturaFormState copyWith({
    bool? isFormValid,
    int? id,
    int? baseId,
    int? rutaId,
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
    String? sector,
    String? periodo,
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
      imagenes: imagenes ?? this.imagenes,
      isPosting: isPosting ?? this.isPosting,
      baseId: baseId ?? this.baseId,
      rutaId: rutaId ?? this.rutaId,
      sector: sector ?? this.sector,
      periodo: periodo ?? this.periodo,
    );
  }
}
