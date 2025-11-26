import 'package:flutter_riverpod/legacy.dart';
import 'package:nexsys_app/features/auth/presentation/presentation.dart';
import 'package:nexsys_app/features/lecturas/data/data.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';

final lecturasRegistradoslProvider =
    StateNotifierProvider<LecturasRegistradosNotifier, List<Lectura>>((ref) {
     final authState = ref.watch(authProvider);
      return LecturasRegistradosNotifier(userId: authState.user!.id);
    });

class LecturasRegistradosNotifier extends StateNotifier<List<Lectura>> {
  final int userId;
  LecturasRegistradosNotifier({required this.userId}) : super([]) {
    filtrarPorRegistrado(1);
  }

  Future<void> filtrarPorRegistrado(int valor) async {
    final data = await LecturaDao.buscarPorRegistrado(valor,userId);
    state = data;
  }
}
