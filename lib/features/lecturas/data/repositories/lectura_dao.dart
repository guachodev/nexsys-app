import 'dart:convert';

import 'package:nexsys_app/core/database/database.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';
import 'package:sqflite/sqflite.dart';

class LecturaDao {
  static Future<void> insertOrUpdateLecturas(List<Lectura> lecturas) async {
    final db = await DatabaseProvider.db;
    final batch = db.batch();

    for (var lectura in lecturas) {
      batch.insert('lecturas', {
        'id': lectura.id,
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

  static Future<Lectura?> getById(int id) async {
    final db = await DatabaseProvider.db;
    final res = await db.query('lecturas', where: 'id = ?', whereArgs: [id]);

    if (res.isEmpty) return null;
    return Lectura.fromMap(res.first);
  }

  static Future<void> updateLectura(
    Map<String, dynamic> lecturaLike,
    int lecturaId,
  ) async {
    final db = await DatabaseProvider.db;

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
      where: 'id = ?',
      whereArgs: [lecturaId], // importante
    );
  }

  static Future<List<Lectura>> buscarTodas() async {
    final db = await DatabaseProvider.db;
    final result = await db.query('lecturas');
    return result.map((e) => Lectura.fromMap(e)).toList();
  }

  static Future<List<Lectura>> buscarPorRegistrado(int valor) async {
    final db = await DatabaseProvider.db;
    final result = await db.query(
      'lecturas',
      where: 'registrado = ?',
      whereArgs: [valor],
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

  static Future<int> getTotalMedidores() async {
    final db = await DatabaseProvider.db;
    final res = await db.rawQuery('SELECT COUNT(*) AS total FROM lecturas');
    return Sqflite.firstIntValue(res) ?? 0;
  }

  static Future<int> getMedidoresLeidos() async {
    final db = await DatabaseProvider.db;
    final res = await db.rawQuery(
      'SELECT COUNT(*) AS leidos FROM lecturas WHERE registrado = 1',
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

  static Future<void> clearData() async {
    final db = await DatabaseProvider.db;
    await db.delete('lecturas');
    await db.delete('ruta');
  }
}
