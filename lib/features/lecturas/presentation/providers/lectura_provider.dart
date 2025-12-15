import 'package:flutter_riverpod/legacy.dart';
import 'package:nexsys_app/features/auth/presentation/presentation.dart';
import 'package:nexsys_app/features/lecturas/data/data.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';
import 'package:nexsys_app/features/lecturas/presentation/presentation.dart';

final currentLecturaProvider = StateProvider<Lectura?>((ref) => null);

final lecturaProvider = StateNotifierProvider.autoDispose
    .family<LecturaNotifier, LecturaState, String>((ref, lecturaId) {
      final repo = LecturasRepositoryImpl();
      final user = ref.watch(authProvider).user;
      final ruta = ref.watch(rutasProvider).rutaSeleccionada;
      return LecturaNotifier(
        lecturaId: lecturaId,
        repo: repo,
        token: user!.token,
        userId: user.id,
        rutaId: ruta!.id,
      );
    });

class LecturaNotifier extends StateNotifier<LecturaState> {
  final LecturasRepositoryImpl repo;
  final String token;
  final int userId;
  final int rutaId;

  LecturaNotifier({
    required String lecturaId,
    required this.repo,
    required this.token,
    required this.userId,
    required this.rutaId,
  }) : super(LecturaState(id: lecturaId)) {
    loadLectura();
  }

  Lectura newEmptyLectura() {
    return Lectura(
      id: -1,
      medidor: '',
      cuenta: 0,
      propietario: '',
      cedula: '',
      lecturaAnterior: 0,
      novedadId: -1,
      rutaId: -1,
      promedioConsumo: 0,
      sector: 'Sin ruta',
      periodo: ''
    );
  }


  Future<void> loadLectura() async {
    try {
      state = state.copyWith(isLoading: true);

      if (state.id == 'new') {
        state = state.copyWith(isLoading: false, lectura: newEmptyLectura());
        return;
      }

      if (state.id == 'ruta') {
        final lectura = await repo.getLecturaOrden(userId, rutaId);
        state = state.copyWith(isLoading: false, lectura: lectura);
        return;
      }

      final lectura = await repo.getLecturaById(int.parse(state.id));

      state = state.copyWith(isLoading: false, lectura: lectura);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

class LecturaState {
  final String id;
  final Lectura? lectura;
  final bool isLoading;
  final String errorMessage;

  LecturaState({
    required this.id,
    this.lectura,
    this.isLoading = true,
    this.errorMessage = '',
  });

  LecturaState copyWith({
    String? id,
    Lectura? lectura,
    bool? isLoading,
    String? errorMessage,
  }) => LecturaState(
    id: id ?? this.id,
    lectura: lectura ?? this.lectura,
    isLoading: isLoading ?? this.isLoading,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}
