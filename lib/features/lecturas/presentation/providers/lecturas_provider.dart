import 'package:flutter_riverpod/legacy.dart';
import 'package:nexsys_app/core/errors/errors.dart';
import 'package:nexsys_app/features/auth/presentation/presentation.dart';
import 'package:nexsys_app/features/lecturas/data/data.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';

final lecturasProvider = StateNotifierProvider<LecturasNotifier, LecturasState>(
  (ref) {
    final lecturasRepository = LecturasRepositoryImpl();
    final authState = ref.watch(authProvider);
    return LecturasNotifier(
      lecturasRepository: lecturasRepository,
      token: authState.user!.token,
    );
  },
);

class LecturasNotifier extends StateNotifier<LecturasState> {
  final LecturasRepositoryImpl lecturasRepository;
  final String token;

  LecturasNotifier({required this.lecturasRepository, required this.token})
    : super(LecturasState());

  Future<bool> updateProduct(Map<String, dynamic> productLike) async {
    try {
      await lecturasRepository.updateLectura(productLike, token);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future loadNextPage() async {
    try {
      if (state.isLoading || state.isLastPage) return;

      state = state.copyWith(isLoading: true);

      final lecturas = await lecturasRepository.getLecturaAsignadasByPage(
        limit: state.limit,
        offset: state.offset,
      );

      if (lecturas.isEmpty) {
        state = state.copyWith(isLoading: false, isLastPage: true);
        return;
      }

      state = state.copyWith(
        isLastPage: false,
        isLoading: false,
        offset: state.offset + 10,
        lecturas: [...state.lecturas, ...lecturas],
      );
    } on CustomError catch (e) {
      state = state.copyWith(
        isLastPage: false,
        isLoading: false,
        errorMessage: e.message,
      );
    }
  }

  Future<List<Lectura>> searchMoviesByQuery(String query) async {
    final List<Lectura> lecturas = await lecturasRepository.searchLecturas(
      query,
      token,
    );
    return lecturas;
  }

  Future<Lectura?> searchLecturaByMedidor(String medidor) async {
    final List<Lectura> lecturas = await lecturasRepository.searchLecturas(
      medidor,
      token,
    );

    if (lecturas.isEmpty) return null;

    return lecturas.first;
  }
}

class LecturasState {
  final bool isLastPage;
  final int limit;
  final int offset;
  final bool isLoading;
  final List<Lectura> lecturas;
  final String errorMessage;

  LecturasState({
    this.isLastPage = false,
    this.limit = 10,
    this.offset = 0,
    this.isLoading = false,
    this.lecturas = const [],
    this.errorMessage = '',
  });

  LecturasState copyWith({
    bool? isLastPage,
    int? limit,
    int? offset,
    bool? isLoading,
    List<Lectura>? lecturas,
    String? errorMessage,
  }) => LecturasState(
    isLastPage: isLastPage ?? this.isLastPage,
    limit: limit ?? this.limit,
    offset: offset ?? this.offset,
    isLoading: isLoading ?? this.isLoading,
    lecturas: lecturas ?? this.lecturas,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}
