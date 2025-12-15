import 'package:flutter_riverpod/legacy.dart';
import 'package:nexsys_app/core/constants/constants.dart';
import 'package:nexsys_app/features/auth/presentation/presentation.dart';
import 'package:nexsys_app/features/lecturas/data/data.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';

final rutasProvider = StateNotifierProvider<RutasNotifier, RutasState>((ref) {
  final authState = ref.watch(authProvider);
  return RutasNotifier(userId: authState.user!.id);
});

class RutasNotifier extends StateNotifier<RutasState> {
  final int userId;

  RutasNotifier({required this.userId}) : super(RutasState()) {
    cargarRutas();
  }

  Future<void> cargarRutas() async {
    state = state.copyWith(status: SearchStatus.loading);

    try {
      final result = await RutaDao.getAll(userId);

      if (result.isEmpty) {
        state = state.copyWith(status: SearchStatus.empty);
        return;
      }

      // Crear la opción "Todas"
      List<Ruta> rutasFinal;
      Ruta? rutaSeleccionada;

      if (result.length > 2) {
        final todas = Ruta(id: -1, detalle: "Todas las rutas", sectorId: -1);
        rutasFinal = [todas, ...result];
        rutaSeleccionada = todas; // default
      } else {
        rutasFinal = result;
        rutaSeleccionada = result.first; // o null, según tu lógica
      }

      state = state.copyWith(
        rutas: rutasFinal,
        rutaSeleccionada: rutaSeleccionada,
        status: SearchStatus.loaded,
      );
    } catch (e) {
      state = state.copyWith(
        status: SearchStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void setRutaSeleccionada(Ruta ruta) {
    state = state.copyWith(rutaSeleccionada: ruta);
  }
}

class RutasState {
  final List<Ruta> rutas;
  final SearchStatus status;
  final String? errorMessage;

  final Ruta? rutaSeleccionada;

  const RutasState({
    this.rutas = const [],
    this.status = SearchStatus.initial,
    this.errorMessage,
    this.rutaSeleccionada,
  });

  RutasState copyWith({
    List<Ruta>? rutas,
    SearchStatus? status,
    String? errorMessage,
    Ruta? rutaSeleccionada,
  }) {
    return RutasState(
      rutas: rutas ?? this.rutas,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      rutaSeleccionada: rutaSeleccionada ?? this.rutaSeleccionada,
    );
  }
}
