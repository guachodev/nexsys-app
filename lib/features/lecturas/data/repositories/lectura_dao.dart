import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:nexsys_app/core/database/database.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';
import 'package:sqflite/sqflite.dart';

class LecturaDao {
  static Future<void> insertOrUpdateLecturas(
    List<Lectura> lecturas,
    int userId,
  ) async {
    final db = await DatabaseProvider.db;
    final batch = db.batch();

    for (var lectura in lecturas) {
      batch.insert('lecturas', {
        'lecturaId': lectura.id,
        'usuarioId': userId,
        'medidor': lectura.medidor,
        'cuenta': lectura.cuenta,
        'cedula': lectura.cedula,
        'propietario': lectura.propietario,
        'lecturaAnterior': lectura.lecturaAnterior,
        'lecturaActual': lectura.lecturaActual,
        'consumo': lectura.consumo ?? 0,
        'observacion': lectura.observacion,
        'imagenes': jsonEncode(lectura.imagenes), // guardado en CSV
        'latitud': lectura.latitud,
        'longitud': lectura.longitud,
        'rutaId': lectura.rutaId,
        'promedioConsumo': lectura.promedioConsumo,
        'sincronizado': 0,
        'registrado': 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  Future<void> insertOrUpdate(Lectura lectura) async {
    final db = await DatabaseProvider.db;
    await db.insert(
      'lecturas',
      lectura.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Lectura>> getAll() async {
    final db = await DatabaseProvider.db;
    final result = await db.query('lecturas');
    return result.map((e) => Lectura.fromMap(e)).toList();
  }

  static Future<List<Lectura>> getPendingSync() async {
    final db = await DatabaseProvider.db;
    final result = await db.query(
      'lecturas',
      where: 'registrado = 1 and sincronizado = ?',
      whereArgs: [0],
    );
    return result.map((e) => Lectura.fromMap(e)).toList();
  }

  static Future<List<Lectura>> getRegistrados() async {
    final db = await DatabaseProvider.db;
    final result = await db.query(
      'lecturas',
      where: 'registrado = ?',
      whereArgs: [0],
    );
    return result.map((e) => Lectura.fromMap(e)).toList();
  }

  static Future<List<Lectura>> buscarPorCuenta(String numeroCuenta) async {
    final db = await DatabaseProvider.db;
    final result = await db.query(
      'lecturas',
      where: 'registrado=0 and cuenta LIKE ?',
      whereArgs: ['%$numeroCuenta%'], // permite búsqueda parcial
    );

    return result.map((e) => Lectura.fromMap(e)).toList();
  }

  static Future<List<Lectura>> buscarPorCuentaByRutaId(
    String numeroCuenta,
    int rutaId,
  ) async {
    final db = await DatabaseProvider.db;
    final result = await db.query(
      'lecturas',
      where: 'registrado=0 and rutaId = ? and cuenta LIKE ?',
      whereArgs: [rutaId, '%$numeroCuenta%'], // permite búsqueda parcial
    );

    return result.map((e) => Lectura.fromMap(e)).toList();
  }

  static Future<Lectura?> getById(int id) async {
    final db = await DatabaseProvider.db;
    final res = await db.query('lecturas', where: 'lecturaId = ?', whereArgs: [id]);
    if (res.isEmpty) return null;
    debugPrint(res.first.toString());
    return Lectura.fromMap(res.first);
  }

  static Future<void> updateLectura(
    Map<String, dynamic> lecturaLike,
    int lecturaId,
    int userId,
  ) async {
    final db = await DatabaseProvider.db;
    print(lecturaId);
    print(userId);
    final data = {
      'lecturaActual': lecturaLike['lectura_actual'], // ✔ nombre correcto
      'observacion': lecturaLike['descripcion'], // ✔ mapeo correcto
      'imagenes': jsonEncode(lecturaLike['imagenes']), // ✔ lista → texto
      'consumo': lecturaLike['consumo'], // ✔ ok
      'novedadId': lecturaLike['novedad_id'], // ✔ nombre real
      'fechaLectura': lecturaLike['fecha_lectura'],
      'lectorId': lecturaLike['empleado_id'],
      'latitud': lecturaLike['latitud'], // ✔ existe
      'longitud': lecturaLike['longitud'], // ✔ existe
      'registrado': 1, // opcional
    };

    await db.update(
      'lecturas',
      data,
      where: 'lecturaId = ? and usuarioId = ?',
      whereArgs: [lecturaId, userId], // importante
    );
  }

  static Future<List<Lectura>> buscarTodas(int userId) async {
    final db = await DatabaseProvider.db;
    final result = await db.query(
      'lecturas',
      where: 'usuarioId = ?',
      whereArgs: [userId],
    );
    return result.map((e) => Lectura.fromMap(e)).toList();
  }

  static Future<List<Lectura>> buscarPorRegistrado(
    int valor,
    int userId,
  ) async {
    final db = await DatabaseProvider.db;
    final result = await db.query(
      'lecturas',
      where: 'registrado = ? and usuarioId = ?',
      whereArgs: [valor, userId],
    );
    return result.map((e) => Lectura.fromMap(e)).toList();
  }

  static Future<List<Lectura>> buscarPorSincronizado(int valor) async {
    final db = await DatabaseProvider.db;
    final result = await db.query(
      'lecturas',
      where: 'sincronizado = ?',
      whereArgs: [valor],
    );
    return result.map((e) => Lectura.fromMap(e)).toList();
  }

  static Future<int> getTotalMedidores(int userId) async {
    final db = await DatabaseProvider.db;
    final res = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM lecturas WHERE usuarioId = ?',
      [userId],
    );
    return Sqflite.firstIntValue(res) ?? 0;
  }

  static Future<int> getTotalMedidoresByRutaId(int userId, int rutaId) async {
    final db = await DatabaseProvider.db;
    final res = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM lecturas WHERE usuarioId = ? and rutaId = ?',
      [userId, rutaId],
    );
    return Sqflite.firstIntValue(res) ?? 0;
  }

  static Future<int> getMedidoresLeidos(int userId) async {
    final db = await DatabaseProvider.db;
    final res = await db.rawQuery(
      'SELECT COUNT(*) AS leidos FROM lecturas WHERE registrado = 1 AND usuarioId = ?',
      [userId],
    );
    return Sqflite.firstIntValue(res) ?? 0;
  }

  static Future<int> getMedidoresLeidosByRutaId(int userId, int rutaId) async {
    final db = await DatabaseProvider.db;
    final res = await db.rawQuery(
      'SELECT COUNT(*) AS leidos FROM lecturas WHERE registrado = 1 AND usuarioId = ? and rutaId = ?',
      [userId, rutaId],
    );
    return Sqflite.firstIntValue(res) ?? 0;
  }

  static Future<void> resetLecturas() async {
    final db = await DatabaseProvider.db;
    await db.update('lecturas', {'registrado': 0, 'sincronizado': 0});
  }

  static Future<void> marcarSincronizada(int id) async {
    final db = await DatabaseProvider.db;
    await db.update(
      'lecturas',
      {'sincronizado': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<String> exportLecturasToJson() async {
    final db = await DatabaseProvider.db;
    final data = await db.query('lecturas');
    return jsonEncode(data);
  }

  static Future<void> clearData(int userId) async {
    final db = await DatabaseProvider.db;
    await db.delete('lecturas', where: 'usuarioId = ?', whereArgs: [userId]);
    await db.delete('ruta', where: 'usuarioId = ?', whereArgs: [userId]);
  }
}
