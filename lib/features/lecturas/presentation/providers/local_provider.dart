import 'package:flutter_riverpod/legacy.dart';
import 'package:nexsys_app/features/lecturas/data/data.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';

final lecturasLocalProvider =
    StateNotifierProvider<LecturasLocalNotifier, List<Lectura>>((ref) {
  return LecturasLocalNotifier();
});

class LecturasLocalNotifier extends StateNotifier<List<Lectura>> {
  LecturasLocalNotifier() : super([]) {
    cargarLecturas();
  }

  Future<void> cargarLecturas() async {
    final data = await LecturaDao.buscarTodas();
    state = data;
  }

  Future<void> filtrarPorRegistrado(int valor) async {
    final data = await LecturaDao.buscarPorRegistrado(valor);
    state = data;
  }

  Future<void> filtrarPorSincronizado(int valor) async {
    final data = await LecturaDao.buscarPorSincronizado(valor);
    state = data;
  }

  
}
