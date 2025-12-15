import '../entities/lectura.dart';
import '../entities/periodo.dart';

abstract class LecturasDatasource {
  Future<Periodo?> getPeriodoActivo(String token, int userId);
  Future<List<Lectura>> searchLecturas(String query);
  Future<Map<String, dynamic>> descargarLecturasAsignadas(
    String periodoId,
    String token,
  );
}
