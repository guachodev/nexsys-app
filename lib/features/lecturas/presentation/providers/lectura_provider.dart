import 'package:flutter_riverpod/legacy.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';

final currentLecturaProvider = StateProvider<Lectura?>((ref) => null);

final lecturaProvider = StateNotifierProvider.autoDispose
    .family<LecturaNotifier, LecturaState, Lectura>((ref, lectura) {
      return LecturaNotifier(lectura);
    });

class LecturaNotifier extends StateNotifier<LecturaState> {
  LecturaNotifier(Lectura lectura) : super(LecturaState(id: lectura.id)) {
    loadLectura(lectura);
  }

  loadLectura(Lectura lectura) {
    state = state.copyWith(isLoading: false, lectura: lectura);
  }
}

class LecturaState {
  final int id;
  final Lectura? lectura;
  final bool isLoading;
  final bool isSaving;

  LecturaState({
    required this.id,
    this.lectura,
    this.isLoading = true,
    this.isSaving = false,
  });

  LecturaState copyWith({
    int? id,
    Lectura? lectura,
    bool? isLoading,
    bool? isSaving,
  }) => LecturaState(
    id: id ?? this.id,
    lectura: lectura ?? this.lectura,
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
  );
}
