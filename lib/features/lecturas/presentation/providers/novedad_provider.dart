import 'package:flutter_riverpod/legacy.dart';
import 'package:nexsys_app/core/constants/constants.dart';
import 'package:nexsys_app/features/lecturas/data/data.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';

final novedadesProvider =
    StateNotifierProvider<NovedadesNotifier, NovedadState>((ref) {
      return NovedadesNotifier();
    });

class NovedadesNotifier extends StateNotifier<NovedadState> {
  NovedadesNotifier() : super(NovedadState()) {
    loadNovedades();
  }

  Future<void> loadNovedades() async {
    try {
      final result = await NovedadDao.getAll();
      if (result.isEmpty) {
        state = state.copyWith(status: SearchStatus.empty);
        return;
      }
      state = state.copyWith(novedades: result, status: SearchStatus.loaded);
    } catch (e) {
      state = state.copyWith(
        status: SearchStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

class NovedadState {
  final List<Novedad> novedades;
  final SearchStatus status;
  final String? errorMessage;

  const NovedadState({
    this.novedades = const [],
    this.status = SearchStatus.initial,
    this.errorMessage,
  });

  NovedadState copyWith({
    List<Novedad>? novedades,
    SearchStatus? status,
    String? errorMessage,
  }) {
    return NovedadState(
      novedades: novedades ?? this.novedades,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
