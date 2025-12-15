import 'package:flutter_riverpod/legacy.dart';
import 'package:nexsys_app/core/constants/constants.dart';
import 'package:nexsys_app/features/lecturas/data/data.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';
import 'package:nexsys_app/features/lecturas/presentation/presentation.dart';

final lecturasLocalProvider =
    StateNotifierProvider<LecturasLocalNotifier, LecturasLocalState>((ref) {
      final periodo = ref.watch(periodoProvider);
      return LecturasLocalNotifier(userId: periodo.periodo!.userId!);
    });

class LecturasLocalNotifier extends StateNotifier<LecturasLocalState> {
  final int userId;

  LecturasLocalNotifier({required this.userId})
    : super(const LecturasLocalState()) {
    cargarLecturas();
  }

  Future<void> cargarLecturas() async {
    try {
      state = state.copyWith(status: SearchStatus.loading);

      final data = await LecturaDao.buscarTodas(userId);
      if (data.isEmpty) {
        state = state.copyWith(status: SearchStatus.empty, lecturas: []);
        return;
      }

      state = state.copyWith(status: SearchStatus.loaded, lecturas: data);
    } catch (e) {
      state = state.copyWith(
        status: SearchStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> cargarLecturasNoSincronizados() async {
    try {
      state = state.copyWith(status: SearchStatus.loading);
      
      final data = await LecturaDao.buscarPorSincronizado(0, userId);
      if (data.isEmpty) {
        state = state.copyWith(status: SearchStatus.empty, lecturas: []);
        return;
      }

      state = state.copyWith(status: SearchStatus.loaded, lecturas: data);
    } catch (e) {
      state = state.copyWith(
        status: SearchStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> filtrarPorRegistrado(int valor) async {
    try {
      state = state.copyWith(status: SearchStatus.loading);

      final data = await LecturaDao.buscarPorRegistrado(valor, userId);

      if (data.isEmpty) {
        state = state.copyWith(status: SearchStatus.empty, lecturas: []);
        return;
      }

      state = state.copyWith(status: SearchStatus.loaded, lecturas: data);
    } catch (e) {
      state = state.copyWith(
        status: SearchStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

class LecturasLocalState {
  final SearchStatus status;
  final List<Lectura> lecturas;
  final String? errorMessage;
  

  const LecturasLocalState({
    this.status = SearchStatus.initial,
    this.lecturas = const [],
    this.errorMessage,
  });

  LecturasLocalState copyWith({
    SearchStatus? status,
    List<Lectura>? lecturas,
    String? errorMessage,
  }) {
    return LecturasLocalState(
      status: status ?? this.status,
      lecturas: lecturas ?? this.lecturas,
      errorMessage: errorMessage,
    );
  }
}

/* import 'package:flutter_riverpod/legacy.dart';
import 'package:nexsys_app/features/lecturas/data/data.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';
import 'package:nexsys_app/features/lecturas/presentation/presentation.dart';

final lecturasLocalProvider =
    StateNotifierProvider<LecturasLocalNotifier, List<Lectura>>((ref) {
      final periodo = ref.watch(periodoProvider);
      return LecturasLocalNotifier(userId: periodo.periodo!.userId!);
    });

class LecturasLocalNotifier extends StateNotifier<List<Lectura>> {
  final int userId;

  LecturasLocalNotifier({required this.userId}) : super([]) {
    cargarLecturas();
  }

  Future<void> cargarLecturas() async {
    final data = await LecturaDao.buscarTodas(userId);
    state = data;
  }

  Future<void> filtrarPorRegistrado(int valor) async {
    final data = await LecturaDao.buscarPorRegistrado(valor, userId);
    state = data;
  }

  Future<void> filtrarPorSincronizado(int valor) async {
    final data = await LecturaDao.buscarPorSincronizado(valor);
    state = data;
  }
}
 */
