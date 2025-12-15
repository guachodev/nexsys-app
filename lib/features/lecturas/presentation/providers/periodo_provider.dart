import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:nexsys_app/core/constants/enums.dart';
import 'package:nexsys_app/features/auth/presentation/presentation.dart';
import 'package:nexsys_app/features/lecturas/data/data.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';

final periodoProvider = StateNotifierProvider<PeriodoNotifier, PeriodoState>((
  ref,
) {
  final lecturasRepository = LecturasRepositoryImpl();
  final authState = ref.watch(authProvider);
  return PeriodoNotifier(
    lecturasRepository: lecturasRepository,
    token: authState.user!.token,
    userId: authState.user!.id,
    ref: ref,
  );
});

class PeriodoNotifier extends StateNotifier<PeriodoState> {
  final LecturasRepositoryImpl lecturasRepository;
  final String token;
  final int userId;
  final Ref ref;

  PeriodoNotifier({
    required this.lecturasRepository,
    required this.token,
    required this.userId,
    required this.ref,
  }) : super(PeriodoState()) {
    //loadPeriodo();
  }

  Future<void> loadPeriodo() async {
    state = state.copyWith(status: SearchStatus.loading);

    try {
      final periodo = await lecturasRepository.getPeriodoActivo(token, userId);
      if (periodo == null) {
        state = state.copyWith(status: SearchStatus.empty);
        return;
      }

      // 🔄 refrescar rutas desde BD
      //ref.read(rutasProvider.notifier).cargarRutas();

      state = state.copyWith(status: SearchStatus.loaded, periodo: periodo);
    } catch (e) {
      debugPrint('Error periodo $e');
      state = state.copyWith(
        status: SearchStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> marcarDescargado() async {
    if (state.periodo == null) return;
    final updated = state.periodo!.copyWith(descargado: true);
    await lecturasRepository.updatePeriodo(updated, updated.userId!);
    state = state.copyWith(periodo: updated);
    refreshAvance();
  }

  Future<void> resetearDescargado() async {
    if (state.periodo == null) return;
    final updated = state.periodo!.copyWith(descargado: false);
    await lecturasRepository.updatePeriodo(updated, updated.userId!);
    state = state.copyWith(periodo: updated);
    refreshAvance();
  }

  Future<void> refreshAvance() async {
    final periodoActual = state.periodo;
    if (periodoActual == null) return;

    // calcular avance usando el repo
    final actualizado = await lecturasRepository.calcularAvancePeriodo(
      periodoActual,
    );

    state = state.copyWith(periodo: actualizado);
  }

  Future<void> filterByRuta(int rutaId) async {
    final periodoActual = state.periodo;
    if (periodoActual == null) return;

    // calcular avance usando el repo
    final actualizado = await lecturasRepository.calcularAvancePeriodoById(
      periodoActual,
      rutaId,
    );

    state = state.copyWith(periodo: actualizado);
  }
}

class PeriodoState {
  final Periodo? periodo;
  final SearchStatus status;
  final String? errorMessage;

  PeriodoState({
    this.periodo,
    this.status = SearchStatus.initial,
    this.errorMessage = '',
  });

  PeriodoState copyWith({
    Periodo? periodo,
    SearchStatus? status,
    String? errorMessage,
  }) => PeriodoState(
    periodo: periodo ?? this.periodo,
    status: status ?? this.status,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}
