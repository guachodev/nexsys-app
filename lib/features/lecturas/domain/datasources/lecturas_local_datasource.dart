import '../entities/lectura.dart';

abstract class LocalLecturasDatasource {
  Future<void> saveLecturas(List<Lectura> lecturas);
  Future<List<Lectura>> getAllLecturas();
  Future<void> saveLecturaPendiente(Map<String, dynamic> lecturaLike);
  Future<List<Map<String, dynamic>>> getLecturasPendientes();
  Future<void> deleteLecturaPendiente(int id);
}
