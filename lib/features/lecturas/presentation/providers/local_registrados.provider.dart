import 'package:flutter_riverpod/legacy.dart';
import 'package:nexsys_app/core/constants/constants.dart';
import 'package:nexsys_app/core/errors/errors.dart';
import 'package:nexsys_app/features/auth/presentation/presentation.dart';
import 'package:nexsys_app/features/lecturas/data/data.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';

final lecturasRegistradoslProvider =
    StateNotifierProvider<LecturasRegistradosNotifier, LocalRegistradoState>((
      ref,
    ) {
      final authState = ref.watch(authProvider);
      return LecturasRegistradosNotifier(userId: authState.user!.id);
    });

class LecturasRegistradosNotifier extends StateNotifier<LocalRegistradoState> {
  final int userId;
  LecturasRegistradosNotifier({required this.userId})
    : super(LocalRegistradoState());

  Future<void> filtrarPorRegistrado(int valor) async {
    try {
      state = state.copyWith(status: SearchStatus.loading);

      List<Lectura> result;

      if (state.selectedRutaId != null && state.selectedRutaId != -1) {
        // Busca por ruta seleccionada
        result = await LecturaDao.buscarPorRegistrado(valor, userId);
      } else {
        result = await LecturaDao.buscarPorRegistrado(valor, userId);
      }

      if (result.isEmpty) {
        state = state.copyWith(status: SearchStatus.empty, lecturas: []);
        return;
      }

      state = state.copyWith(status: SearchStatus.loaded, lecturas: result);
    } on CustomError catch (e) {
      state = state.copyWith(
        status: SearchStatus.error,
        errorMessage: e.message,
      );
    }
  }

  void selectRuta(int? rutaId) {
    state = state.copyWith(selectedRutaId: rutaId);
    filtrarPorRegistrado(1);
  }
}

class LocalRegistradoState {
  final SearchStatus status;
  final List<Lectura> lecturas;
  final String? errorMessage;
  final int? selectedRutaId;

  const LocalRegistradoState({
    this.status = SearchStatus.initial,
    this.lecturas = const [],
    this.errorMessage,
    this.selectedRutaId,
  });

  LocalRegistradoState copyWith({
    SearchStatus? status,
    List<Lectura>? lecturas,
    String? errorMessage,
    int? selectedRutaId,
  }) {
    return LocalRegistradoState(
      status: status ?? this.status,
      lecturas: lecturas ?? this.lecturas,
      errorMessage: errorMessage,
      selectedRutaId: selectedRutaId ?? this.selectedRutaId,
    );
  }
}
