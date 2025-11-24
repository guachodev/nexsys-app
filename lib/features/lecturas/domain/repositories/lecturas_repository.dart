import '../domain.dart';

abstract class LecturasRepository {
  Future<Periodo?> getPeriodoActivo(String token);
  Future<List<Lectura>> searchLecturas(String query);
  Future<DescargaResponse> descargarLecturasAsignadas(
    String periodoId,
    String token,
  );
  Future<Lectura?> getLecturaById(int id);
  Future<void> updateLectura(Map<String, dynamic> lecturaLike, String token);
  Future<List<Lectura>> getLecturasPendiente();
  Future<List<Lectura>> getLecturasRegistradas();
}
