import 'package:nexsys_app/core/database/database.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';
import 'package:sqflite/sqflite.dart';

class RutaDao {
  static Future<void> insertOrUpdateRutas(List<Ruta> rutas, int userId) async {
    final db = await DatabaseProvider.db;
    final batch = db.batch();

    for (var r in rutas) {
      batch.insert('ruta', {
        'rutaId': r.id,
        'usuarioId': userId,
        'sector_id': r.sectorId,
        'detalle': r.detalle,
        'cerrado': 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit();
  }

  static Future<List<Ruta>> getAll(int userId) async {
    final db = await DatabaseProvider.db;
    final result = await db.query(
      'ruta',
      where: 'usuarioId = ?',
      whereArgs: [userId],
    );
    return result.map((e) => Ruta.fromMap(e)).toList();
  }

  static Future<int> marcarRutaCerrada({
    required int rutaId,
    required int userId,
    required bool cerrado,
  }) async {
    final db = await DatabaseProvider.db;

    return await db.update(
      'ruta',
      {'cerrado': cerrado ? 0 : 1},
      where: 'rutaId = ? AND usuarioId = ?',
      whereArgs: [rutaId, userId],
    );
  }
}
