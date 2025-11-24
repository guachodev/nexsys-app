import 'package:nexsys_app/features/lecturas/domain/domain.dart';

abstract class LocalLecturasDatasource {
  Future<void> savePeriodo(Periodo periodo);

  Future<Periodo?> getPeriodo();
  Future<List<Lectura>> buscarPorCuenta(String numeroCuenta);

  // ─── RUTAS ────────────────────────────────────────────────────────────────
  Future<void> saveRutas(List<Ruta> rutas);

  // ─── NOVEDADES ────────────────────────────────────────────────────────────
  Future<void> saveNovedades(List<Novedad> novedades);

  // ─── LECTURAS ────────────────────────────────────────────────────────────────
  Future<void> saveLecturas(List<Lectura> lecturas);

  Future<Lectura?> lecturaById(int id);

  Future<void> updateLectura(Map<String, dynamic> lecturaLike, int lecturaId);

  Future<List<Lectura>> getLect();
  Future<List<Lectura>> getLecturasPendiente();
  Future<List<Lectura>> getLecturasRegistradas();
}
