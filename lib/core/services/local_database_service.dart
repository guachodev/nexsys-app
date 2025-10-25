import 'package:nexsys_app/features/lecturas/domain/domain.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'nexsys_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE lecturas (
          id INTEGER PRIMARY KEY,
          medidor TEXT,
          catastro TEXT,
          propietario TEXT,
          lecturaAnterior INTEGER,
          lecturaActual INTEGER,
          consumo INTEGER,
          observacion TEXT,
          imagenes TEXT,
          latitud REAL,
          longitud REAL,
          synced INTEGER DEFAULT 0
        );
        ''');
      },
    );
  }

  static Future<void> insertOrUpdateLectura(Lectura lectura) async {
    final db = await database;

    await db
        .insert('lecturas', {
          'id': lectura.id,
          'medidor': lectura.medidor,
          'catastro': lectura.catastro,
          'propietario': lectura.propietario,
          'lecturaAnterior': lectura.lecturaAnterior,
          'lecturaActual': lectura.lecturaActual,
          'consumo': lectura.consumo,
          'observacion': lectura.observacion,
          'imagenes': lectura.imagenes.join(','),
          'latitud': lectura.latitud,
          'longitud': lectura.longitud,
          'synced': 0,
        }, conflictAlgorithm: ConflictAlgorithm.replace)
        .then((value) {
          print('database $value');
        });
  }

  static Future<List<Lectura>> getAllLecturas() async {
    final db = await database;
    final result = await db.query('lecturas');
    print(result);
    return result.map((e) => Lectura.fromMap(e)).toList();
  }

  static Future<List<Lectura>> getPendingSync() async {
    final db = await database;
    final result = await db.query(
      'lecturas',
      where: 'synced = ?',
      whereArgs: [0],
    );
    return result.map((e) => Lectura.fromMap(e)).toList();
  }

  static Future<void> markAsSynced(int id) async {
    final db = await database;
    await db.update(
      'lecturas',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
