import 'package:flutter_riverpod/legacy.dart';
import 'package:nexsys_app/core/constants/constants.dart';
import 'package:nexsys_app/features/auth/presentation/presentation.dart';
import 'package:nexsys_app/features/lecturas/data/data.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';

final periodoProvider =
    StateNotifierProvider.autoDispose<PeriodoNotifier, PeriodoState>((ref) {
      final lecturasRepository = LecturasRepositoryImpl();
       final authState = ref.watch(authProvider);
      return PeriodoNotifier(lecturasRepository: lecturasRepository, token: authState.user!.token);
    });

class PeriodoNotifier extends StateNotifier<PeriodoState> {
  final LecturasRepositoryImpl lecturasRepository;
 final String token;
  PeriodoNotifier( {required this.lecturasRepository,required this.token,}) : super(PeriodoState()) {
    loadPeriodo();
  }

  Future<void> loadPeriodo() async {
    try {
      state = state.copyWith( status: SearchStatus.loading);
      final periodo = await lecturasRepository.getPeriodoActivo(token);
      
      if (periodo == null || periodo.total <= 0) {
        state = state.copyWith(
        
          periodo: null,
          status: SearchStatus.empty,
          pendientes: 0,
          progreso: 0.0,
        );
        return;
      }

      state = state.copyWith(
        periodo: periodo,
        status: SearchStatus.loaded,
        pendientes: periodo.total - periodo.totalLectura,
        progreso: (periodo.totalLectura / periodo.total).isNaN
            ? 0
            : periodo.totalLectura / periodo.total,
        
      );
    } catch (e) {
      state = state.copyWith(
        periodo: null,
        status: SearchStatus.error,
        errorMessage: e.toString(),
        
      );
    }
  }
}

class PeriodoState {
  final Periodo? periodo;
  final SearchStatus status;
  final int? pendientes;
  final double? progreso;
  final String? errorMessage;

  PeriodoState({
    this.periodo,
    this.pendientes = 0,
    this.progreso = 0.0,
    this.status = SearchStatus.initial,
    this.errorMessage = '',
  });

  PeriodoState copyWith({
    Periodo? periodo,
    int? pendientes,
    double? progreso,
    SearchStatus? status,
    String? errorMessage,
  }) => PeriodoState(
    periodo: periodo ?? this.periodo,
    status: status ?? this.status,
    pendientes: pendientes ?? this.pendientes,
    progreso: progreso ?? this.progreso,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}
