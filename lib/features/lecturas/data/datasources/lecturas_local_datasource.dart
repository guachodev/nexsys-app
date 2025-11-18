import 'package:nexsys_app/core/services/services.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';

class LecturasLocalDatasource {
  Future<List<Lectura>> getLecturas() async {
    return await LocalDatabaseService.getAllLecturas();
  }

  Future<void> saveLectura(Lectura lectura) async {
    await LocalDatabaseService.insertOrUpdateLectura(lectura);
  }

  Future<void> saveLecturas(List<Lectura> lecturas) async {
    for (var l in lecturas) {
      await LocalDatabaseService.insertOrUpdateLectura(l);
    }
  }

  Future<void> markAsSynced(int id) async {
    await LocalDatabaseService.markAsSynced(id);
  }

  Future<List<Lectura>> getPendingSync() async {
    return await LocalDatabaseService.getPendingSync();
  }

  Future<Map<String, Object?>?> getPeriodo() async {
    return await LocalDatabaseService.getPeriodo();
  }

   Future<void> savePeriodo(Periodo periodo) async {
    await LocalDatabaseService.insertOrUpdatePeriodo(periodo);
  }
}
