import 'package:nexsys_app/core/database/database.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';
import 'package:sqflite/sqflite.dart';

class NovedadDao {
  static Future<void> insertOrUpdateNovedades(List<Novedad> novedades) async {
    final db = await DatabaseProvider.db;
    final batch = db.batch();

    for (var n in novedades) {
      batch.insert('novedad', {
        'id': n.id,
        'detalle': n.detalle,
        'defecto': n.isDefault ? 1 : 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit();
  }

  Future<void> insertOrUpdate(Novedad n) async {
    final db = await DatabaseProvider.db;
    await db.insert('novedad', {
      'id': n.id,
      'detalle': n.detalle,
      'defecto': n.isDefault ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Novedad>> getAll() async {
    final db = await DatabaseProvider.db;
    final result = await db.query('novedad');
    return result.map((e) => Novedad.fromMap(e)).toList();
  }
}
