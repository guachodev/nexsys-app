import 'package:flutter_riverpod/legacy.dart';
import 'package:nexsys_app/features/lecturas/data/data.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';

final lecturasRegistradoslProvider =
    StateNotifierProvider<LecturasRegistradosNotifier, List<Lectura>>((ref) {
      return LecturasRegistradosNotifier();
    });

class LecturasRegistradosNotifier extends StateNotifier<List<Lectura>> {
  LecturasRegistradosNotifier() : super([]) {
    filtrarPorRegistrado(1);
  }

 
  Future<void> filtrarPorRegistrado(int valor) async {
    final data = await LecturaDao.buscarPorRegistrado(valor);
    state = data;
  }

}
