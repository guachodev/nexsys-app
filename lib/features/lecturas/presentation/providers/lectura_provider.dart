import 'package:flutter_riverpod/legacy.dart';
import 'package:nexsys_app/features/auth/presentation/presentation.dart';
import 'package:nexsys_app/features/lecturas/data/data.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';

final currentLecturaProvider = StateProvider<int?>((ref) => null);

final saveLecturaProvider = StateProvider<bool>((ref) => false);

final lecturaProvider = StateNotifierProvider.autoDispose
    .family<LecturaNotifier, LecturaState, int>((ref, lecturaId) {
      final repo = LecturasRepositoryImpl();
      final token = ref.watch(authProvider).user!.token;
      return LecturaNotifier(repo: repo, token: token, lecturaId: lecturaId);
    });

class LecturaNotifier extends StateNotifier<LecturaState> {
  final LecturasRepositoryImpl repo;
  final String token;
  final int lecturaId;

  LecturaNotifier({
    required this.repo,
    required this.token,
    required this.lecturaId,
  }) : super(LecturaState(id: lecturaId)) {
    loadLectura();
  }

  Future<void> loadLectura() async {
    try {
      state = state.copyWith(isLoading: true);

      final lectura = await repo.getLecturaById(lecturaId);

      state = state.copyWith(lectura: lectura, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

class LecturaState {
  final int id;
  final Lectura? lectura;
  final bool isLoading;
  final bool isSaving;
  final String errorMessage;

  LecturaState({
    required this.id,
    this.lectura,
    this.isLoading = true,
    this.isSaving = false,
    this.errorMessage = '',
  });

  LecturaState copyWith({
    int? id,
    Lectura? lectura,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
  }) => LecturaState(
    id: id ?? this.id,
    lectura: lectura ?? this.lectura,
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}
