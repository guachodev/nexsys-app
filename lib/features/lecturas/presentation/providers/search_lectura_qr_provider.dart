import 'package:flutter_riverpod/legacy.dart';
import 'package:nexsys_app/core/errors/errors.dart';
import 'package:nexsys_app/features/auth/presentation/presentation.dart';
import 'package:nexsys_app/features/lecturas/data/data.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';

final searchLecturaQrProvider =
    StateNotifierProvider<SearchLecturaQrNotifier, SearchLecturaQrState>((ref) {
      final repo = LecturasRepositoryImpl();

      final authState = ref.watch(authProvider);
      return SearchLecturaQrNotifier(repo: repo, userId: authState.user!.id);
    });

class SearchLecturaQrNotifier extends StateNotifier<SearchLecturaQrState> {
  final LecturasRepositoryImpl repo;
  final int userId;
  SearchLecturaQrNotifier({required this.repo, required this.userId})
    : super(SearchLecturaQrState.initial());

  Future<void> searchByQr(String medidor) async {
    state = state.copyWith(status: SearchLecturaQrStatus.loading);
    try {
      //await Future.delayed(Duration(seconds: 5));
      final result = await repo.searchLecturas(medidor,userId);
      if (result.isEmpty) {
        state = state.copyWith(
          status: SearchLecturaQrStatus.error,
          message: 'No existe un medidor con ese código.',
        );
      } else {
        state = state.copyWith(
          status: SearchLecturaQrStatus.success,
          lectura: result.first,
        );
      }
    } on CustomError catch (e) {
      state = state.copyWith(
        status: SearchLecturaQrStatus.error,
        message: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        status: SearchLecturaQrStatus.error,
        message: 'Ocurrió un error inesperado',
      );
    }
  }

  void reset() => state = SearchLecturaQrState.initial();
}

enum SearchLecturaQrStatus { idle, loading, success, error }

class SearchLecturaQrState {
  final SearchLecturaQrStatus status;
  final String message;
  final Lectura? lectura;

  SearchLecturaQrState({required this.status, this.message = '', this.lectura});

  factory SearchLecturaQrState.initial() =>
      SearchLecturaQrState(status: SearchLecturaQrStatus.idle);

  SearchLecturaQrState copyWith({
    SearchLecturaQrStatus? status,
    String? message,
    Lectura? lectura,
  }) => SearchLecturaQrState(
    status: status ?? this.status,
    message: message ?? this.message,
    lectura: lectura ?? this.lectura,
  );
}
