import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';
import 'package:nexsys_app/core/constants/constants.dart';
import 'package:nexsys_app/core/errors/errors.dart';
import 'package:nexsys_app/features/auth/presentation/presentation.dart';
import 'package:nexsys_app/features/lecturas/data/data.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';

final searchLecturaProvider =
    StateNotifierProvider<SearchLecturaNotifier, SearchLecturaState>((ref) {
      final lecturasRepository = LecturasRepositoryImpl();
      final authState = ref.watch(authProvider);
      return SearchLecturaNotifier(
        lecturasRepository: lecturasRepository,
        token: authState.user!.token,
      );
    });

class SearchLecturaNotifier extends StateNotifier<SearchLecturaState> {
  final LecturasRepository lecturasRepository;
  final String token;
  Timer? _debounceTimer;
  SearchLecturaNotifier({required this.lecturasRepository, required this.token})
    : super(SearchLecturaState());

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void reset() {
    state = state.copyWith(
      status: SearchStatus.initial,
      lecturas: [],
      errorMessage: null,
      query: '',
    );
  }

  void deleteById(int id) {
    final newLecturas = state.lecturas
        .where((element) => element.id != id)
        .toList();

    state = state.copyWith(
      //status: SearchStatus.initial,
      lecturas: newLecturas,
      errorMessage: null,
      //query: '',
    );
  }

  Lectura? nextLectura(int id) {
    final remainingLecturas = state.lecturas
        .where((element) => element.id != id)
        .toList();

    final next = remainingLecturas.isNotEmpty ? remainingLecturas.first : null;

    state = state.copyWith(lecturas: remainingLecturas, errorMessage: null);

    return next;
  }

  void updateQuery(String value) {
    // Cancelar cualquier búsqueda pendiente
    _debounceTimer?.cancel();

    if (value.isEmpty) {
      state = state.copyWith(
        query: "",
        status: SearchStatus.initial,
        lecturas: [],
        errorMessage: null,
      );
      return;
    }

    _debounceTimer = Timer(
      const Duration(milliseconds: 500),
      () => searchMoviesByQuery(value),
    );
  }

  void selectRuta(int? rutaId) {
    state = state.copyWith(selectedRutaId: rutaId);
    if (state.query.trim().isEmpty) {
      state = state.copyWith(status: SearchStatus.initial, lecturas: []);
      return;
    }
    searchMoviesByQuery(state.query);
  }

  Future<void> searchMoviesByQuery(String query) async {
    try {
      state = state.copyWith(status: SearchStatus.loading, query: query);
      if (query != state.query) return;
      List<Lectura> result;

      if (state.selectedRutaId != null && state.selectedRutaId != -1) {
        // Busca por ruta seleccionada
        result = await lecturasRepository.searchLecturasByRuta(
          state.query,
          state.selectedRutaId!,
        );
      } else {
        result = await lecturasRepository.searchLecturas(state.query);
      }

      if (result.isEmpty) {
        state = state.copyWith(status: SearchStatus.empty, lecturas: []);
        return;
      }

      state = state.copyWith(status: SearchStatus.loaded, lecturas: result);
    } on CustomError catch (e) {
      if (query != state.query) return;
      state = state.copyWith(
        status: SearchStatus.error,
        errorMessage: e.message,
      );
    }
  }
}

class SearchLecturaState {
  final SearchStatus status;
  final String query;
  final List<Lectura> lecturas;
  final String? errorMessage;
  final int? selectedRutaId;

  const SearchLecturaState({
    this.status = SearchStatus.initial,
    this.query = '',
    this.lecturas = const [],
    this.errorMessage,
    this.selectedRutaId,
  });

  SearchLecturaState copyWith({
    SearchStatus? status,
    String? query,
    List<Lectura>? lecturas,
    String? errorMessage,
    int? selectedRutaId,
  }) {
    return SearchLecturaState(
      status: status ?? this.status,
      query: query ?? this.query,
      lecturas: lecturas ?? this.lecturas,
      errorMessage: errorMessage,
      selectedRutaId: selectedRutaId ?? this.selectedRutaId,
    );
  }
}
