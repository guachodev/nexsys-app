import 'package:nexsys_app/core/services/services.dart';
import 'package:nexsys_app/features/lecturas/data/data.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';

import '../mappers/periodo_mapper.dart';

class LecturasRepositoryImpl extends LecturasRepository {
  final LecturasDatasourceImpl remote;
  final LecturasLocalDatasource local;

  LecturasRepositoryImpl({
    LecturasDatasourceImpl? remote,
    LecturasLocalDatasource? local,
  }) : remote = remote ?? LecturasDatasourceImpl(),
       local = local ?? LecturasLocalDatasource();

  @override
  Future<List<Lectura>> getLecturaAsignadasByPage({
    int limit = 10,
    int offset = 0,
  }) async {
    final hasNet = await ConnectivityService.hasConnection();
    if (hasNet) {
      final lecturas = await remote.getLecturaAsignadasByPage(
        limit: limit,
        offset: offset,
      );
      await local.saveLecturas(lecturas);
      return lecturas;
    } else {
      return await local.getLecturas();
    }
  }

  @override
  Future<void> updateLectura(
    Map<String, dynamic> lecturaLike,
    String token,
  ) async {
    final hasNet = await ConnectivityService.hasConnection();
    final lectura = LecturaMapper.jsonToEntity(lecturaLike);

    if (hasNet) {
      await remote.updateLectura(lecturaLike, token);
      await local.markAsSynced(lectura.id);
    } else {
      await local.saveLectura(lectura);
    }
  }

  @override
  Future<List<Lectura>> searchLecturas(String query, String token) async {
    final hasNet = await ConnectivityService.hasConnection();

    if (hasNet) {
      final lecturas = await remote.searchLecturas(query, token);
      await local.saveLecturas(lecturas);
      //final all = await local.getLecturas();
      return lecturas;
    } else {
      final all = await local.getLecturas();
      //print(all);
      return all.where((l) => l.medidor.contains(query)).toList();
    }
  }

  @override
  Future<Periodo?> getPeriodoActivo(String token) async {
    final hasNet = await ConnectivityService.hasConnection();
    if (hasNet) {
      final periodo = await remote.getPeriodoActivo(token);
      if (periodo != null) {
        await local.savePeriodo(periodo);
      } else {
        // periodo remoto NO existe → limpiamos base
        // await local.clearPeriodo();
        return null;
      }
    }
    final data = await local.getPeriodo();
    //print(data);
    if (data == null) return null;

    return PeriodoMapper.jsonTodb(data);
  }

  @override
  Future<Lectura?> searchLecturasByMedidor(String medidor, String token) async {
    final hasNet = await ConnectivityService.hasConnection();
    if (hasNet) {
      final lectura = await remote.searchLecturasByMedidor(medidor, token);
      if (lectura != null) await local.saveLectura(lectura);
      return lectura;
    } else {
      final lecturas = await local.getLecturas();
      try {
        return lecturas.firstWhere((l) => l.medidor == medidor);
      } catch (_) {
        return null;
      }
    }
  }
}
