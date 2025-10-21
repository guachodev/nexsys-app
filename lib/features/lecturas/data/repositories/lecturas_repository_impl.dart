import 'package:nexsys_app/features/lecturas/data/data.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';

class LecturasRepositoryImpl extends LecturasRepository {
  final LecturasDatasource datasource;

  LecturasRepositoryImpl({LecturasDatasource? datasource})
    : datasource = datasource ?? LecturasDatasourceImpl();

  @override
  Future<List<Lectura>> getLecturaAsignadasByPage({
    int limit = 10,
    int offset = 0,
  }) {
    return datasource.getLecturaAsignadasByPage(limit: limit, offset: offset);
  }

  @override
  Future<void> updateLectura(Map<String, dynamic> lecturaLike, String token) {
    return datasource.updateLectura(lecturaLike, token);
  }

  @override
  Future<List<Lectura>> searchLecturas(String query,String token) {
    return datasource.searchLecturas(query, token);
  }

  @override
  Future<Periodo?> getPeriodoActivo(String token) {
    return datasource.getPeriodoActivo(token);
  }

  @override
  Future<Lectura?> searchLecturasByMedidor(String medidor,String token) {
    return datasource.searchLecturasByMedidor(medidor, token);
  }
}
