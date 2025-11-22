import '../entities/lectura.dart';
import '../entities/periodo.dart';

abstract class LecturasDatasource {
  Future<List<Lectura>> getLecturaAsignadasByPage({
    int limit = 10,
    int offset = 0,
  });

  Future<Periodo?> getPeriodoActivo(String token);

  Future<void> updateLectura(Map<String, dynamic> lecturaLike, String token);
  Future<List<Lectura>> searchLecturas(String query,String token);
  Future<Lectura?> searchLecturasByMedidor(String medidor,String token);

  Future<Map<String, dynamic>> descargarLecturasAsignadas(String periodoId,String token);
}
