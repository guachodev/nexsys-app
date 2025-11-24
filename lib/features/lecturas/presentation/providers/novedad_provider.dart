import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:nexsys_app/features/lecturas/data/data.dart';

import '../../domain/entities/novedad.dart';

final novedadesProvider =
    StateNotifierProvider<NovedadesNotifier, List<Novedad>>((ref) {
      return NovedadesNotifier();
    });

class NovedadesNotifier extends StateNotifier<List<Novedad>> {
  NovedadesNotifier() : super([]) {
    loadNovedades();
  }

  Future<void> loadNovedades() async {
    final data = await NovedadDao.getAll();
    for (var l in data) {
      debugPrint("${l.id} - ${l.detalle} - ${l.isDefault}");
    }
    state = data;
  }
}
