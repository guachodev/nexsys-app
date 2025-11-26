import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
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
      userId: authState.user!.id
    );
  },
);

class LecturasNotifier extends StateNotifier<LecturasState> {
  final LecturasRepositoryImpl lecturasRepository;
  final String token;
  final int userId;

  LecturasNotifier({
    required this.lecturasRepository,
    required this.token,
    required this.userId,
  }) : super(LecturasState());

  Future<bool> updateProduct(Map<String, dynamic> productLike) async {
    try {
      await lecturasRepository.updateLectura(productLike, token, userId);
      return true;
    } catch (e) {
      debugPrint('Error $e');
      return false;
    }
  }

  Future<bool> resetearLecturas(Periodo periodo) async {
    try {
      await lecturasRepository.reseterLecturas(periodo);
      return true;
    } catch (e) {
      debugPrint('Error $e');
      return false;
    }
  }

  Future<String?> exportarLecturas() async {
    try {
      final path = await lecturasRepository.exportarLecturas();
      return path;
    } catch (e) {
      debugPrint("Error al exportar $e");
      return null;
    }
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
