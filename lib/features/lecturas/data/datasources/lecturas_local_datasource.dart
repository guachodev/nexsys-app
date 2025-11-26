import 'dart:io';

import 'package:nexsys_app/features/lecturas/data/data.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class LecturasLocalDatasourceImpl extends LocalLecturasDatasource {
  Future<bool> _solicitarPermisoStorage() async {
    if (Platform.isAndroid) {
      // Android 11+ (API 30+) requiere MANAGE_EXTERNAL_STORAGE
      if (await Permission.manageExternalStorage.isDenied) {
        final status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) return false;
      }

      // Android 10 o inferior (WRITE/READ)
      final storageStatus = await Permission.storage.request();
      if (!storageStatus.isGranted) return false;

      return true;
    }

    // iOS no necesita permisos para escribir
    return true;
  }

  Future<Directory> _getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      // Carpeta pública de descargas
      return Directory('/storage/emulated/0/Download');
    }

    // iOS/macOS
    return await getDownloadsDirectory() ??
        await getApplicationDocumentsDirectory();
  }

  @override
  Future<void> savePeriodo(Periodo periodo, int userId) async {
    await PeriodoDao.insertOrUpdatePeriodo(periodo, userId);
  }

  @override
  Future<Periodo?> getPeriodo(int userId) async {
    return await PeriodoDao.getPeriodo(userId);
  }

  @override
  Future<List<Lectura>> buscarPorCuenta(String numeroCuenta) async {
    return await LecturaDao.buscarPorCuenta(numeroCuenta);
  }

  Future<List<Lectura>> buscarPorCuentaByRutaId(String numeroCuenta, int rutaId) async {
    return await LecturaDao.buscarPorCuentaByRutaId(numeroCuenta,rutaId);
  }

  // ─── RUTAS ────────────────────────────────────────────────────────────────
  @override
  Future<void> saveRutas(List<Ruta> rutas, int userId) async {
    await RutaDao.insertOrUpdateRutas(rutas, userId);
  }

  // ─── NOVEDADES ────────────────────────────────────────────────────────────
  @override
  Future<void> saveNovedades(List<Novedad> novedades) async {
    await NovedadDao.insertOrUpdateNovedades(novedades);
  }

  // ─── LECTURAS ────────────────────────────────────────────────────────────────
  @override
  Future<void> saveLecturas(List<Lectura> lecturas, int userId) async {
    await LecturaDao.insertOrUpdateLecturas(lecturas, userId);
  }

  @override
  Future<Lectura?> lecturaById(int id) async {
    return await LecturaDao.getById(id);
  }

  @override
  Future<void> updateLectura(
    Map<String, dynamic> lecturaLike,
    int lecturaId,
    int userId,
  ) async {
    await LecturaDao.updateLectura(lecturaLike, lecturaId,userId);
  }

  Future<List<Lectura>> getLecturasPendientes() async {
    return await LecturaDao.getPendingSync();
  }

  Future<int> countTotal(int userId) async {
    return await LecturaDao.getTotalMedidores(userId);
  }

  Future<int> countLeidos(int userId) async {
    return await LecturaDao.getMedidoresLeidos(userId);
  }

  Future<int> countTotalByRuta(int userId, int rutaId) async {
    return await LecturaDao.getTotalMedidoresByRutaId(userId, rutaId);
  }

  Future<int> countLeidosByRuta(int userId, int rutaId) async {
    return await LecturaDao.getMedidoresLeidosByRutaId(userId, rutaId);
  }

  @override
  Future<List<Lectura>> getLect() async {
    return await LecturaDao.getPendingSync();
  }

  @override
  Future<List<Lectura>> getLecturasPendiente() async {
    return await LecturaDao.getPendingSync();
  }

  @override
  Future<List<Lectura>> getLecturasRegistradas() async {
    return await LecturaDao.getRegistrados();
  }

  Future<void> resetearLEcturas() async {
    return await LecturaDao.resetLecturas();
  }

  Future<void> lecturaSincronizada(int lecturaId) async {
    return await LecturaDao.marcarSincronizada(lecturaId);
  }

  Future<String> exportLecturasToJson() async {
    return await LecturaDao.exportLecturasToJson();
  }

  Future<void> eliminarData(int userId) async {
    return await LecturaDao.clearData(userId);
  }

  Future<String> saveJsonFileInDownloads(String jsonString) async {
    final permitido = await _solicitarPermisoStorage();
    if (!permitido) throw Exception("Permiso de almacenamiento denegado");

    final dir = await _getDownloadsDirectory();

    final String filename =
        "lecturas_${DateTime.now().millisecondsSinceEpoch}.json";

    final file = File("${dir.path}/$filename");

    await file.writeAsString(jsonString);

    return file.path;
  }
}
