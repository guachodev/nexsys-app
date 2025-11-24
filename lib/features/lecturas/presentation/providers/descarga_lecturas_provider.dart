import 'package:flutter_riverpod/legacy.dart';
import 'package:nexsys_app/features/auth/presentation/presentation.dart';
import 'package:nexsys_app/features/lecturas/data/data.dart';

final descargaLecturasProvider =
    StateNotifierProvider<DescargaLecturasNotifier, DescargaLecturasState>((
      ref,
    ) {
      final lecturasRepository = LecturasRepositoryImpl();
      final authState = ref.watch(authProvider);

      return DescargaLecturasNotifier(
        lecturasRepository: lecturasRepository,
        token: authState.user!.token,
      );
    });

class DescargaLecturasNotifier extends StateNotifier<DescargaLecturasState> {
  final LecturasRepositoryImpl lecturasRepository;
  final String token;

  DescargaLecturasNotifier({
    required this.lecturasRepository,
    required this.token,
  }) : super(DescargaLecturasState());

  Future<void> descargarLecturas(String periodoId) async {
    try {
      state = state.copyWith(loading: true, error: null);

      await lecturasRepository.descargarLecturasAsignadas(
        periodoId,
        token,
      );

     /*  print("RUTAS: ${data.rutas.length}");
      print("NOVEDADES: ${data.novedades.length}");
      print("LECTURAS DESCARGADAS: ${data.lecturas.length}"); */

      // ⬇ Aquí guardas en SQLite
      //await guardarEnDatabase(respuesta);
      ///ref.read(periodoProvider.notifier).updateDowload();
      state = state.copyWith(loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  void reset() {
    state = DescargaLecturasState();
  }
}

class DescargaLecturasState {
  final bool loading;
  final String? error;

  DescargaLecturasState({this.loading = false, this.error});

  DescargaLecturasState copyWith({bool? loading, String? error}) =>
      DescargaLecturasState(
        loading: loading ?? this.loading,
        error: error ?? this.error,
      );
}
