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
          CREATE TABLE periodo (
            id INTEGER PRIMARY KEY,
            nombre TEXT,
            descargado INTEGER,
            fecha TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE novedad (
            id INTEGER PRIMARY KEY,
            detallle TEXT,
            defecto INTEGER
          );
        ''');
        await db.execute('''
          CREATE TABLE ruta (
          id INTEGER PRIMARY KEY,
          sector_id INTEGER,
          detalle TEXT
        );
        ''');
        await db.execute('''
        CREATE TABLE lecturas (
        id INTEGER PRIMARY KEY,
        medidor TEXT,
        cuenta INTEGER,
        propietario TEXT,
        cedula TEXT,
        lecturaAnterior INTEGER,
        lecturaActual INTEGER,
        consumo INTEGER,
        observacion TEXT,
        novedadId INTEGER,
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
          'cuenta': lectura.cuenta,
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

  static Future<void> insertOrUpdatePeriodo(Periodo periodo) async {
    final db = await database;

    await db.insert('periodo', {
      'id': periodo.id,
      'nombre': periodo.name,
      'descargado': periodo.dowload! ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
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

  static Future<void> insertOrUpdateLecturas(List<Lectura> lecturas) async {
    final db = await database;
    final batch = db.batch();

    for (var lectura in lecturas) {
      batch.insert('lecturas', {
        'id': lectura.id,
        'medidor': lectura.medidor,
        'cuenta': lectura.cuenta,
        'propietario': lectura.propietario,
        'lecturaAnterior': lectura.lecturaAnterior,
        'lecturaActual': lectura.lecturaActual,
        'consumo': lectura.consumo,
        'observacion': lectura.observacion,
        'imagenes': lectura.imagenes.join(','), // guardado en CSV
        'latitud': lectura.latitud,
        'longitud': lectura.longitud,
        'synced': 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  /// Periodo
  static Future<Map<String, Object?>?> getPeriodo() async {
    final db = await database;
    final result = await db.query('periodo', limit: 1);

    if (result.isEmpty) return null;

    return result.first;
  }

  static Future<void> clearPeriodo() async {
    final db = await database;
    await db.delete('periodo');
  }

  /// novedad
  static Future<void> insertOrUpdateNovedades(List<Novedad> novedades) async {
    final db = await database;
    final batch = db.batch();

    for (var n in novedades) {
      batch.insert('novedad', {
        'id': n.id,
        'detallle': n.detalle,
        'defecto': n.isDefault ? 1 : 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit();
  }

  static Future<void> insertOrUpdateNovedad(Novedad novedad) async {
    final db = await database;

    await db.insert('novedad', {
      'id': novedad.id,
      'detallle': novedad.detalle,
      'defecto': novedad.isDefault ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// ruta
  static Future<void> insertOrUpdateRutas(List<Ruta> rutas) async {
    final db = await database;
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

  static Future<void> insertOrUpdateRuta(Ruta ruta) async {
    final db = await database;

    await db.insert('ruta', {
      'id': ruta.id,
      'sector_id': ruta.sectorId,
      'detalle': ruta.detalle,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
