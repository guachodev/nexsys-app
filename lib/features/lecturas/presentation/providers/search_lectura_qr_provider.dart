import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:nexsys_app/core/errors/errors.dart';
import 'package:nexsys_app/features/auth/presentation/presentation.dart';
import 'package:nexsys_app/features/lecturas/data/data.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';
import 'package:nexsys_app/features/lecturas/presentation/presentation.dart';

final searchLecturaQrProvider =
    StateNotifierProvider<SearchLecturaQrNotifier, SearchLecturaQrState>((ref) {
      final repo = LecturasRepositoryImpl();
      final authState = ref.watch(authProvider);
      return SearchLecturaQrNotifier(
        repo: repo,
        userId: authState.user!.id,
        ref: ref,
      );
    });

class SearchLecturaQrNotifier extends StateNotifier<SearchLecturaQrState> {
  final LecturasRepositoryImpl repo;
  final int userId;
  final Ref ref;
  SearchLecturaQrNotifier({
    required this.repo,
    required this.userId,
    required this.ref,
  }) : super(SearchLecturaQrState.initial());

  Future<void> searchByQr(String medidor) async {
    state = state.copyWith(status: SearchLecturaQrStatus.loading);
    try {
      //await Future.delayed(Duration(seconds: 5));
      final result = await repo.searchLecturas(medidor, userId);

      if (result.isEmpty) {
        state = state.copyWith(
          status: SearchLecturaQrStatus.error,
          message:
              'No se encontró un medidor con esta cuenta. Intenta nuevamente.',
        );
      } else {
        final lectura = result.first;
        final rutasState = ref.read(rutasProvider);
        final ruta = rutasState.rutas.firstWhere(
          (r) => r.id == lectura.rutaId,
          orElse: () =>
              Ruta(id: -999, detalle: '', sectorId: -1, cerrado: false),
        );

        if (ruta.cerrado) {
          state = state.copyWith(
            status: SearchLecturaQrStatus.error,
            message:
                'No se puede registrar lectura porque la ruta está cerrada.',
          );
          return;
        }
        state = state.copyWith(
          status: SearchLecturaQrStatus.success,
          lectura: lectura,
        );
      }
    } on CustomError catch (e) {
      state = state.copyWith(
        status: SearchLecturaQrStatus.error,
        message: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: SearchLecturaQrStatus.error,
        message: e.toString(),
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
