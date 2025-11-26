import '../domain.dart';

abstract class LecturasRepository {
  Future<Periodo?> getPeriodoActivo(String token, int userId);
  Future<List<Lectura>> searchLecturas(String query);
  Future<List<Lectura>> searchLecturasByRuta(String query, int rutaId);
  Future<DescargaResponse> descargarLecturasAsignadas(
    String periodoId,
    String token,
    int userId,
  );
  Future<Lectura?> getLecturaById(int id);
  Future<void> updateLectura(Map<String, dynamic> lecturaLike, String token);
  Future<List<Lectura>> getLecturasPendiente();
  Future<List<Lectura>> getLecturasRegistradas();
}
