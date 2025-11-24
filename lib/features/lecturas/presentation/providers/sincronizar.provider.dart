import 'package:flutter_riverpod/legacy.dart';
import 'package:nexsys_app/core/constants/constants.dart';
import 'package:nexsys_app/features/auth/presentation/presentation.dart';
import 'package:nexsys_app/features/lecturas/data/data.dart';

final sincronizacionProvider =
    StateNotifierProvider<SincronizacionNotifier, SincronizacionState>((ref) {
      final authState = ref.watch(authProvider);
      final repo = LecturasRepositoryImpl();

      return SincronizacionNotifier(
        repository: repo,
        token: authState.user!.token,
      );
    });

class SincronizacionNotifier extends StateNotifier<SincronizacionState> {
  final LecturasRepositoryImpl repository;
  final String token;

  SincronizacionNotifier({required this.repository, required this.token})
    : super(SincronizacionState());

  void _setLoading() {
    state = state.copyWith(status: SearchStatus.loading);
  }

  void _setSuccess(int count) {
    state = state.copyWith(
      status: SearchStatus.loaded,
      sincronizadas: count,
      error: null,
    );
  }

  void _setError(String msg) {
    state = state.copyWith(status: SearchStatus.error, error: msg);
  }

  Future<bool> sincronizar() async {
    _setLoading();

    try {
      final count = await repository.sincronizarLecturas(token);
      _setSuccess(count);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }
}

class SincronizacionState {
  final SearchStatus status;
  final int sincronizadas;
  final String? error;

  SincronizacionState({
    this.status = SearchStatus.initial,
    this.sincronizadas = 0,
    this.error,
  });

  SincronizacionState copyWith({
    SearchStatus? status,
    int? sincronizadas,
    String? error,
  }) {
    return SincronizacionState(
      status: status ?? this.status,
      sincronizadas: sincronizadas ?? this.sincronizadas,
      error: error,
    );
  }
}
