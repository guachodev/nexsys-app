import 'package:nexsys_app/core/services/services.dart';
import 'package:nexsys_app/features/lecturas/data/data.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';

class LecturasRepositoryImpl extends LecturasRepository {
  final LecturasDatasourceImpl remote;
  final LecturasLocalDatasourceImpl local;

  LecturasRepositoryImpl({
    LecturasDatasourceImpl? remote,
    LecturasLocalDatasourceImpl? local,
  }) : remote = remote ?? LecturasDatasourceImpl(),
       local = local ?? LecturasLocalDatasourceImpl();

  @override
  Future<Periodo?> getPeriodoActivo(String token, int userId) async {
    final hasNet = await ConnectivityService.hasConnection();
    Periodo? periodo;

    if (hasNet) {
      try {
        periodo = await remote.getPeriodoActivo(token);
      } catch (_) {
        periodo = null;
      }
    }

    final periodolocal = await local.getPeriodo(userId);

    // CASE 1: backend devuelve null → período cerrado oficialmente
    if (periodo == null) {
      if (periodolocal != null) {
        final updated = periodolocal.copyWith(cerrado: true);

        await local.savePeriodo(updated, userId);

        // actualizar avance
        return await _calcularAvance(updated);
      }
      return null;
    }

    // CASE 2: nuevo período
    if (periodolocal == null) {
      final nuevo = periodo.copyWith(
        cerrado: false,
        descargado: false,
        userId: userId,
      );
      await local.savePeriodo(nuevo, userId);

      return await _calcularAvance(nuevo);
    }

    // CASE 3: ID distinto → nuevo período
    if (periodolocal.id != periodo.id) {
      final nuevo = periodo.copyWith(
        cerrado: false,
        descargado: false,
        userId: userId,
      );

      await local.savePeriodo(nuevo, userId);
      //await local.clearMedidores();  // si lo ocupas habilítalo

      return await _calcularAvance(nuevo);
    }

    // CASE 4: mismo período
    final actualizado = periodolocal.copyWith(
      name: periodo.name,
      fecha: periodo.fecha,

      // mantener flags locales
      cerrado: periodolocal.cerrado,
      descargado: periodolocal.descargado,
    );

    await local.savePeriodo(actualizado, userId);

    return await _calcularAvance(actualizado);
  }

  @override
  Future<List<Lectura>> searchLecturas(String query) async {
    //final hasNet = await ConnectivityService.hasConnection();

    final lecturas = await local.buscarPorCuenta(query);
    //await local.saveLecturas(lecturas);
    //final all = await local.getLecturas();
    return lecturas;
  }

  @override
  Future<DescargaResponse> descargarLecturasAsignadas(
    String periodoId,
    String token,
    int userId,
  ) async {
    final data = await remote.descargarLecturasAsignadas(periodoId, token);
    final response = DescargaResponse.fromJson(data);
    await local.eliminarData(userId);
    await local.saveRutas(response.rutas, userId);
    await local.saveNovedades(response.novedades);
    await local.saveLecturas(response.lecturas, userId);
    return response;
  }

  @override
  Future<Lectura?> getLecturaById(int id) {
    return local.lecturaById(id);
  }

  @override
  Future<void> updateLectura(
    Map<String, dynamic> lecturaLike,
    String token,
  ) async {
    try {
      //final hasNet = await ConnectivityService.hasConnection();
      //final lectura = LecturaMapper.jsonToEntity(lecturaLike);
      await local.updateLectura(lecturaLike, lecturaLike['id']);

      /*if (hasNet) {
      await remote.updateLectura(lecturaLike, token);
      await local.markAsSynced(lectura.id);
    } else {
      await local.saveLectura(lectura);
    }*/
    } catch (e) {
      throw Exception('Error updating lectura: $e');
    }
  }

  @override
  Future<List<Lectura>> getLecturasPendiente() {
    return local.getLecturasPendientes();
  }

  @override
  Future<List<Lectura>> getLecturasRegistradas() {
    return local.getLecturasRegistradas();
  }

  Future<void> updatePeriodo(Periodo periodo, int userId) async {
    await local.savePeriodo(periodo, userId);
  }

  Future<Periodo> _calcularAvance(Periodo periodo) async {
    final total = await local.countTotal(periodo.userId!);
    final leidos = await local.countLeidos(periodo.userId!);

    final pendientes = total - leidos;
    final porcentaje = total == 0 ? 0 : (leidos / total * 100);

    final actualizado = periodo.copyWith(
      totalMedidores: total,
      medidoresLeidos: leidos,
      pendientes: pendientes,
      porcentajeAvance: porcentaje.toDouble(),
    );

    // Guarda el período actualizado en la base local
    //await local.savePeriodo(actualizado);

    return actualizado;
  }

  Future<Periodo> calcularAvancePeriodo(Periodo periodo) async {
    final total = await local.countTotal(periodo.userId!);
    final leidos = await local.countLeidos(periodo.userId!);

    final pendientes = total - leidos;
    final porcentaje = total == 0 ? 0 : (leidos / total * 100);

    final actualizado = periodo.copyWith(
      totalMedidores: total,
      medidoresLeidos: leidos,
      pendientes: pendientes,
      porcentajeAvance: porcentaje.toDouble(),
    );

    //await local.savePeriodo(actualizado);

    return actualizado;
  }

  Future<Periodo> calcularAvancePeriodoById(Periodo periodo, int rutaId) async {
    final total = await local.countTotalByRuta(periodo.userId!, rutaId);
    final leidos = await local.countLeidosByRuta(periodo.userId!, rutaId);

    final pendientes = total - leidos;
    final porcentaje = total == 0 ? 0 : (leidos / total * 100);

    final actualizado = periodo.copyWith(
      totalMedidores: total,
      medidoresLeidos: leidos,
      pendientes: pendientes,
      porcentajeAvance: porcentaje.toDouble(),
    );

    //await local.savePeriodo(actualizado);

    return actualizado;
  }

  Future<void> reseterLecturas(Periodo periodo) async {
    await local.resetearLEcturas();
    await calcularAvancePeriodo(periodo);
  }

  Future<int> sincronizarLecturas(String token) async {
    final pendientes = await local.getLecturasPendiente();

    if (pendientes.isEmpty) return 0;

    int exitosas = 0;

    for (final lectura in pendientes) {
      try {
        final lecturaLike = {
          'id': lectura.id,
          'lectura_actual': lectura.lecturaActual,
          'descripcion': lectura.observacion,
          //'imagenes': lectura.images ?? [],
          'consumo': lectura.consumo,
          'novedad_id': lectura.novedadId,
          'fecha_lectura': lectura.fechaLectura,
          'empleado_id': lectura.lectorId,
          'latitud': lectura.latitud,
          'longitud': lectura.longitud,
        };
        await remote.updateLectura(lecturaLike, token);
        await local.lecturaSincronizada(lectura.id);
        exitosas++;
      } catch (_) {
        // no marcamos error global, solo omitimos una lectura
      }
    }

    return exitosas;
  }

  Future<String> exportarLecturas() async {
    // Obtener JSON desde la base SQLite local
    final json = await local.exportLecturasToJson();

    // Guardar en carpeta Downloads (nuevo método)
    final filePath = await local.saveJsonFileInDownloads(json);

    return filePath;
  }
  
  @override
  Future<List<Lectura>> searchLecturasByRuta(String query, int rutaId) async {
   final lecturas = await local.buscarPorCuentaByRutaId(query, rutaId);
    return lecturas;
  }
}
