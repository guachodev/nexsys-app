import 'dart:convert';

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
        'direccion': lectura.direccion,
        'sector': lectura.sector,
        'periodo': lectura.periodo,
        'orden': lectura.orden,
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

  static Future<List<Lectura>> buscarPorCuenta(
    String numeroCuenta,
    int userId,
  ) async {
    final db = await DatabaseProvider.db;
    final result = await db.query(
      'lecturas',
      where:
          'registrado=0 and usuarioId = ? and (cuenta LIKE ? OR medidor LIKE ?)',
      whereArgs: [
        userId,
        '%$numeroCuenta%',
        '%$numeroCuenta%',
      ], // permite búsqueda parcial
    );
    return result.map((e) => Lectura.fromMap(e)).toList();
  }

  static Future<List<Lectura>> buscarPorCuentaByRutaId(
    String numeroCuenta,
    int rutaId,
    int userId,
  ) async {
    final db = await DatabaseProvider.db;
    final result = await db.query(
      'lecturas',
      where:
          'registrado=0 and usuarioId = ? and rutaId = ? and (cuenta LIKE ? OR medidor LIKE ?)',
      whereArgs: [
        userId,
        rutaId,
        '%$numeroCuenta%',
        '%$numeroCuenta%',
      ], // permite búsqueda parcial
    );

    return result.map((e) => Lectura.fromMap(e)).toList();
  }

  static Future<List<Lectura>> buscarPorCuentaByRutas(
    String numeroCuenta,
    List<int> rutaIds,
    int userId,
  ) async {
    final db = await DatabaseProvider.db;

    // 🔒 Seguridad: si no hay rutas → no buscar
    if (rutaIds.isEmpty) return [];

    // Crear placeholders dinámicos (?, ?, ?)
    final placeholders = List.filled(rutaIds.length, '?').join(',');

    final result = await db.query(
      'lecturas',
      where:
          '''
      registrado = 0
      AND usuarioId = ?
      AND rutaId IN ($placeholders)
      AND (cuenta LIKE ? OR medidor LIKE ?)
    ''',
      whereArgs: [
        userId,
        ...rutaIds, // 👈 se expande aquí
        '%$numeroCuenta%',
        '%$numeroCuenta%',
      ],
    );

    return result.map((e) => Lectura.fromMap(e)).toList();
  }

  static Future<Lectura?> getById(int id) async {
    final db = await DatabaseProvider.db;
    final res = await db.query(
      'lecturas',
      where: 'lecturaId = ?',
      whereArgs: [id],
    );
    if (res.isEmpty) return null;
    return Lectura.fromMap(res.first);
  }

  static Future<Lectura?> getLecturaOrden(int userId, int rutaId) async {
    final db = await DatabaseProvider.db;
    final res = await db.query(
      'lecturas',
      where: 'usuarioId = ? and rutaId = ? and registrado=0',
      orderBy: '(orden IS NULL) ASC,(orden = 0) ASC,orden ASC',
      whereArgs: [userId, rutaId],
      limit: 1,
    );
    if (res.isEmpty) return null;
    return Lectura.fromMap(res.first);
  }

  static Future<int?> getLecturaIdOrdenNext(int userId, int rutaId) async {
    final db = await DatabaseProvider.db;
    final res = await db.query(
      'lecturas',
      columns: ['id', 'lecturaId'],
      where: 'usuarioId = ? and rutaId = ? and registrado=0',
      orderBy: '(orden IS NULL) ASC,(orden = 0) ASC,orden ASC',
      whereArgs: [userId, rutaId],
      limit: 1,
    );
    if (res.isEmpty) return null;
    return res.first['lecturaId'] as int;
  }

  static Future<void> updateLectura(
    Map<String, dynamic> lecturaLike,
    int localId,
  ) async {
    final db = await DatabaseProvider.db;
    final editado = lecturaLike['editado'] == true;

    if (editado) {
      await db.execute(
        '''
      UPDATE lecturas
      SET 
        lecturaActual = ?,
        observacion = ?,
        imagenes = ?,
        consumo = ?,
        novedadId = ?,
        lectorId = ?,
        registrado = 1
      WHERE id = ?;
      ''',
        [
          lecturaLike['lectura_actual'],
          lecturaLike['descripcion'],
          jsonEncode(lecturaLike['imagenes']),
          lecturaLike['consumo'],
          lecturaLike['novedad_id'],
          lecturaLike['empleado_id'],
          localId,
        ],
      );
    } else {
      await db.execute(
        '''
      UPDATE lecturas
      SET 
        lecturaActual = ?,
        observacion = ?,
        imagenes = ?,
        consumo = ?,
        novedadId = ?,
        fechaLectura = ?,
        lectorId = ?,
        latitud = ?,
        longitud = ?,
        registrado = 1,
        orden = (
          SELECT COALESCE(MAX(orden), 0) + 1
          FROM lecturas l2
          WHERE l2.usuarioId = lecturas.usuarioId
            AND l2.rutaId = lecturas.rutaId
        )
      WHERE id = ?;
      ''',
        [
          lecturaLike['lectura_actual'],
          lecturaLike['descripcion'],
          jsonEncode(lecturaLike['imagenes']),
          lecturaLike['consumo'],
          lecturaLike['novedad_id'],
          lecturaLike['fecha_lectura'],
          lecturaLike['empleado_id'],
          lecturaLike['latitud'],
          lecturaLike['longitud'],
          localId,
        ],
      );
    }
  }

  static Future<List<Lectura>> buscarTodas(int userId) async {
    final db = await DatabaseProvider.db;
    final result = await db.query(
      'lecturas',
      where: 'usuarioId = ?',
      whereArgs: [userId],
      orderBy: 'lecturaId asc',
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

  static Future<List<Lectura>> buscarPorSincronizado(
    int valor,
    int userId,
  ) async {
    final db = await DatabaseProvider.db;
    final result = await db.query(
      'lecturas',
      where: 'sincronizado = ? and usuarioId = ?',
      whereArgs: [valor, userId],
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

  static Future<void> insertImage({
    required int lecturaId,
    required int usuarioId,
    required String path,
  }) async {
    final db = await DatabaseProvider.db;

    // verificar si ya existe
    final res = await db.query(
      "lectura_images",
      where: "path = ? AND lecturaId = ? AND usuarioId = ?",
      whereArgs: [path, lecturaId, usuarioId],
    );

    if (res.isNotEmpty) return; // Ya existe → no insertar

    await db.insert("lectura_images", {
      "lecturaId": lecturaId,
      "usuarioId": usuarioId,
      "path": path,
      "remote_id": null,
      "sync_state": "pending",
      "updated_at": DateTime.now().millisecondsSinceEpoch,
    });
  }

  static Future<void> deleteByPath(String path) async {
    final db = await DatabaseProvider.db;
    await db.delete('lectura_images', where: 'path = ?', whereArgs: [path]);
  }

  static Future<void> marcarImagenSincronizada(
    int localImageId,
    int remoteId,
  ) async {
    final db = await DatabaseProvider.db;

    await db.update(
      'lectura_images',
      {
        "remote_id": remoteId,
        "sync_state": "synced",
        "updated_at": DateTime.now().millisecondsSinceEpoch,
      },
      where: "id = ?",
      whereArgs: [localImageId],
    );
  }

  static Future<List<LecturaImage>> getImagenesPendientes(int lecturaId) async {
    final db = await DatabaseProvider.db;

    final res = await db.query(
      'lectura_images',
      where: 'lecturaId = ? AND (sync_state = ? OR sync_state = ?)',
      whereArgs: [lecturaId, 'pending', 'deleted'],
    );

    return res.map((e) => LecturaImage.fromMap(e)).toList();
  }

  static Future<void> marcarLecturaComoError(int lecturaId) async {
    final db = await DatabaseProvider.db;

    await db.update(
      'lecturas',
      {
        "registrado": -1, // -1 = error
      },
      where: "lecturaId = ?",
      whereArgs: [lecturaId],
    );
  }

  static Future<int> getLastOrderForMonth(int userId, int rutaId) async {
    final db = await DatabaseProvider.db;

    final res = await db.rawQuery(
      """
      SELECT MAX(ordenRuta) as lastOrder
      FROM lecturas
      WHERE usuarioId = ? AND rutaId = ?
  """,
      [userId, rutaId],
    );

    final value = res.first['lastOrder'];
    return value == null ? 0 : value as int;
  }
}
