import 'package:nexsys_app/core/database/database.dart';
import 'package:sqflite/sqflite.dart';

import '../../domain/domain.dart';

class PeriodoDao {
  static Future<void> insertOrUpdatePeriodo(Periodo periodo, int userId) async {
    final db = await DatabaseProvider.db;

    await db.insert('periodo', {
      'periodoId': periodo.id,
      'usuarioId': userId,
      'nombre': periodo.name,
      'fecha': periodo.fecha,
      'descargado': periodo.descargado ? 1 : 0,
      'cerrado': periodo.cerrado ? 1 : 0,
      'descargable': periodo.descargable ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<Periodo?> getPeriodo(int userId) async {
    final db = await DatabaseProvider.db;
    final res = await db.query(
      'periodo',
      where: 'usuarioId=?',
      whereArgs: [userId],
      limit: 1,
    );
    if (res.isEmpty) return null;
    final row = res.first;
    return Periodo(
      id: row['periodoId'] as int,
      name: row['nombre'] as String,
      fecha: row['fecha'] != null ? row['fecha'] as String : '',
      descargado: row['descargado'] == 1,
      cerrado: row['cerrado'] == 1,
      userId: row['usuarioId'] as int,
      descargable: row['descargable'] == 1,
    );
  }
}
