import '../domain.dart';

abstract class LecturasRepository {
  Future<Periodo?> getPeriodoActivo(String token, int userId);
  Future<List<Lectura>> searchLecturas(String query, int userId);
  Future<List<Lectura>> searchLecturasByRuta(
    String query,
    int rutaId,
    int userId,
  );
  Future<List<Lectura>> searchLecturasByRutas(
    String query,
    List<int> rutasIds,
    int userId,
  );
  Future<DescargaResponse> descargarLecturasAsignadas(
    String periodoId,
    String token,
    int userId,
  );
  Future<Lectura?> getLecturaById(int id);
  Future<void> updateLectura(
    Map<String, dynamic> lecturaLike,
    String token,
    int userId,
  );
  Future<List<Lectura>> getLecturasPendiente();
  Future<List<Lectura>> getLecturasRegistradas();
}
