import 'package:nexsys_app/core/database/database.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';
import 'package:sqflite/sqflite.dart';

class RutaDao {
  static Future<void> insertOrUpdateRutas(List<Ruta> rutas) async {
    final db = await DatabaseProvider.db;
    final batch = db.batch();

    for (var r in rutas) {
      batch.insert('ruta', {
        'id': r.id,
        'sector_id': r.sectorId,
        'detalle': r.detalle,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit();
  }


  Future<List<Ruta>> getAll() async {
    final db = await DatabaseProvider.db;
    final result = await db.query('ruta');
    return result.map((e) => Ruta.fromMap(e)).toList();
  }
}
