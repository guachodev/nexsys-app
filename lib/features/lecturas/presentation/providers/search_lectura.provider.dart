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
      return SearchLecturaNotifier(lecturasRepository: lecturasRepository, token: authState.user!.token);
    });

class SearchLecturaNotifier extends StateNotifier<SearchLecturaState> {
  final LecturasRepository lecturasRepository;
   final String token;
  Timer? _debounceTimer;
  SearchLecturaNotifier( {required this.lecturasRepository,required this.token})
    : super(SearchLecturaState());

  reset() {
    state = state.copyWith(
      status: SearchStatus.initial,
      lecturas: [],
      errorMessage: null,
      query: '',
    );
  }

  deleteById(int id) {
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

  void updateQuery(String value) {
    if (value.isEmpty) {
      state = state.copyWith(query: value, status: SearchStatus.initial);
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: 500),
      () => searchMoviesByQuery(value),
    );
  }

  Future<void> searchMoviesByQuery(String query) async {
    try {
      state = state.copyWith(status: SearchStatus.loading, query: query);

      final lecturas = await lecturasRepository.searchLecturas(query,token);

      if (lecturas.isEmpty) {
        state = state.copyWith(status: SearchStatus.empty, lecturas: []);
        return;
      }

      state = state.copyWith(
        status: SearchStatus.loaded,
        query: state.query,
        lecturas: [...lecturas],
      );
    } on CustomError catch (e) {
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

  const SearchLecturaState({
    this.status = SearchStatus.initial,
    this.query = '',
    this.lecturas = const [],
    this.errorMessage,
  });

  SearchLecturaState copyWith({
    SearchStatus? status,
    String? query,
    List<Lectura>? lecturas,
    String? errorMessage,
  }) {
    return SearchLecturaState(
      status: status ?? this.status,
      query: query ?? this.query,
      lecturas: lecturas ?? this.lecturas,
      errorMessage: errorMessage,
    );
  }
}
