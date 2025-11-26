import 'package:flutter_riverpod/legacy.dart';
import 'package:nexsys_app/features/lecturas/data/data.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';
import 'package:nexsys_app/features/lecturas/presentation/presentation.dart';

final lecturasLocalProvider =
    StateNotifierProvider<LecturasLocalNotifier, List<Lectura>>((ref) {
      final periodo = ref.watch(periodoProvider);
      return LecturasLocalNotifier(userId: periodo.periodo!.userId!);
    });

class LecturasLocalNotifier extends StateNotifier<List<Lectura>> {
  final int userId;

  LecturasLocalNotifier({required this.userId}) : super([]) {
    cargarLecturas();
  }

  Future<void> cargarLecturas() async {
    final data = await LecturaDao.buscarTodas(userId);
    state = data;
  }

  Future<void> filtrarPorRegistrado(int valor) async {
    final data = await LecturaDao.buscarPorRegistrado(valor, userId);
    state = data;
  }

  Future<void> filtrarPorSincronizado(int valor) async {
    final data = await LecturaDao.buscarPorSincronizado(valor);
    state = data;
  }
}
