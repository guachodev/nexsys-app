import 'package:flutter/material.dart';
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

    Periodo? periodoRemoto;
    Periodo? periodoLocal = await local.getPeriodo(userId);

    // 1️⃣ Intentar obtener periodo remoto solo si hay internet
    if (hasNet) {
      try {
        periodoRemoto = await remote.getPeriodoActivo(token);
      } catch (e) {
         return null;
        //throw Exception('Error cargar periodo api:');
      }
    }

    // 2️⃣ Si no hay periodo remoto → el backend cerró oficialmente
    if (periodoRemoto == null) {
      if (periodoLocal != null) {
        final actualizado = periodoLocal.copyWith(cerrado: true);
        await local.savePeriodo(actualizado, userId);

        return await _calcularAvance(actualizado);
      }
      return null;
    }

    // 3️⃣ Si no existe periodo local → es primera vez
    if (periodoLocal == null) {
      final nuevo = periodoRemoto.copyWith(
        userId: userId,
        cerrado: false,
        descargado: false,
      );
      await local.savePeriodo(nuevo, userId);
      return await _calcularAvance(nuevo);
    }

    // 4️⃣ El backend trae un periodo distinto → periodo nuevo
    if (periodoLocal.id != periodoRemoto.id) {
      final nuevo = periodoRemoto.copyWith(
        userId: userId,
        cerrado: false,
        descargado: false,
      );
      await local.savePeriodo(nuevo, userId);
      // await local.clearMedidores(); // según tu flujo

      return await _calcularAvance(nuevo);
    }

    // 5️⃣ Mismo periodo → solo actualizar metadatos desde backend
    final actualizado = periodoLocal.copyWith(
      name: periodoRemoto.name,
      fecha: periodoRemoto.fecha,

      // Mantener flags locales
      cerrado: periodoLocal.cerrado,
      descargado: periodoLocal.descargado,
      descargable: periodoRemoto.descargable,
    );

    await local.savePeriodo(actualizado, userId);

    return await _calcularAvance(actualizado);
  }

  @override
  Future<List<Lectura>> searchLecturas(String query, int userId) async {
    return await local.buscarPorCuenta(query, userId);
  }

  @override
  Future<DescargaResponse> descargarLecturasAsignadas(
    String periodoId,
    String token,
    int userId,
  ) async {
    try {
      final data = await remote.descargarLecturasAsignadas(periodoId, token);
      final response = DescargaResponse.fromJson(data);
      await local.eliminarData(userId);
      await local.saveRutas(response.rutas, userId);
      await local.saveNovedades(response.novedades);
      await local.saveLecturas(response.lecturas, userId);
      return response;
    } catch (_) {
      throw Exception('Error al descargar lecturas asignadas');
    }
  }

  @override
  Future<Lectura?> getLecturaById(int id) {
    return local.lecturaById(id);
  }

  Future<Lectura?> getLecturaOrden(int userId, int rutaId) {
    return local.lecturaOrden(userId, rutaId);
  }

  Future<int?> getLecturaIdOrdenNext(int userId, int rutaId) {
    return local.lecturaIdOrdenNext(userId, rutaId);
  }

  @override
  Future<void> updateLectura(
    Map<String, dynamic> lecturaLike,
    String token,
    int userId,
  ) async {
    try {
      final hasNet = await ConnectivityService.hasConnection();
      final int lecturaId = lecturaLike['id'];
      final int baseId = lecturaLike['baseId'];

      // 1️⃣ Guardar SIEMPRE en local
      await local.updateLectura(lecturaLike, baseId);

      // 2️⃣ Guardar imágenes en local
      final imagenes = List<String>.from(lecturaLike['imagenes'] ?? []);

      for (final path in imagenes) {
        await local.insertImageIfNotExists(lecturaId, userId, path);
      }

      // 3️⃣ Sincronizar si hay internet
      if (!hasNet) return;

      // 3.1️⃣ Sincronizar lectura
      await remote.updateLectura(lecturaLike, token);

      // 3.2️⃣ Sincronizar imágenes
      if (imagenes.isNotEmpty) {
        await sincronizarImagenesDeLectura(
          lecturaId,
          token,
          lecturaLike['sector'],
          lecturaLike['periodo'],
        );
      }

      // 3.3️⃣ Marcar como sincronizada SOLO si todo salió bien
      await local.lecturaSincronizada(baseId);
    } catch (e, stack) {
      debugPrint('❌ Error updateLectura: $e');
      debugPrintStack(stackTrace: stack);
      rethrow;
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
          'consumo': lectura.consumo,
          'novedad_id': lectura.novedadId,
          'fecha_lectura': lectura.fechaLectura,
          'empleado_id': lectura.lectorId,
          'latitud': lectura.latitud,
          'longitud': lectura.longitud,
        };

        // 1️⃣ Sincronizar lectura
        await remote.updateLectura(lecturaLike, token);

        // 2️⃣ Sincronizar imágenes asociadas
        await sincronizarImagenesDeLectura(
          lectura.id,
          token,
          lectura.sector,
          lectura.periodo,
        );

        // 3️⃣ Marcar la lectura como sincronizada
        await local.lecturaSincronizada(lectura.baseId!);
        exitosas++;
      } catch (e) {
        debugPrint("❌ Error sincronizando lectura ${lectura.id}: $e");
        await local.marcarLecturaComoError(lectura.id);
      }
    }

    /*for (final lectura in pendientes) {
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
        print(lectura.baseId);
        //debugPrint(lecturaLike as String?);
        print(lecturaLike);
        await remote.updateLectura(lecturaLike, token);
        await local.lecturaSincronizada(lectura.baseId!);
        exitosas++;
      } catch (_) {
        // no marcamos error global, solo omitimos una lectura
      }
    }*/

    return exitosas;
  }

  Future<void> sincronizarImagenesDeLectura(
    int lecturaId,
    String token,
    String sector,
    String periodo,
  ) async {
    final imgs = await local.getImagenesPendientes(lecturaId);

    for (final img in imgs) {
      try {
        final remoteId = await remote.uploadLecturaImage(
          lecturaId: lecturaId,
          localPath: img.path,
          token: token,
          sector: sector,
          periodo: periodo,
        );

        if (remoteId != null) {
          await local.marcarImagenSincronizada(img.id, remoteId);
        }
      } catch (e) {
        debugPrint("❌ Error enviando imagen ${img.path}: $e");
      }
    }
  }

  Future<String> exportarLecturas() async {
    // Obtener JSON desde la base SQLite local
    final json = await local.exportLecturasToJson();

    // Guardar en carpeta Downloads (nuevo método)
    final filePath = await local.saveJsonFileInDownloads(json);

    return filePath;
  }

  @override
  Future<List<Lectura>> searchLecturasByRuta(
    String query,
    int rutaId,
    int userId,
  ) async {
    final lecturas = await local.buscarPorCuentaByRutaId(query, rutaId, userId);
    return lecturas;
  }
}
