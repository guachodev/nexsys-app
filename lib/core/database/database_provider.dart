import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'nexsys_app.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Ejecutar scripts de creación de tablas
    await db.execute('''
          CREATE TABLE IF NOT EXISTS periodo (
            id INTEGER PRIMARY KEY,
            nombre TEXT,
            cerrado INTEGER,
            descargado INTEGER,
            fecha TEXT
          )
        ''');

    await db.execute('''
          CREATE TABLE IF NOT EXISTS novedad (
            id INTEGER PRIMARY KEY,
            detalle TEXT,
            defecto INTEGER
          );
        ''');

    await db.execute('''
          CREATE TABLE IF NOT EXISTS ruta (
          id INTEGER PRIMARY KEY,
          sector_id INTEGER,
          detalle TEXT
        );
        ''');

    await db.execute('''
        CREATE TABLE IF NOT EXISTS lecturas (
        id INTEGER PRIMARY KEY,
        medidor TEXT,
        cuenta INTEGER,
        propietario TEXT,
        cedula TEXT,
        lecturaAnterior INTEGER,
        lecturaActual INTEGER,
        fechaLectura TEXT,
        lectorId INTEGER,
        consumo INTEGER,
        observacion TEXT,
        novedadId INTEGER,
        imagenes TEXT,
        latitud REAL,
        longitud REAL,
        sincronizado INTEGER DEFAULT 0,        -- 0 = no sincronizado, 1 = sincronizado
        registrado INTEGER DEFAULT 0     -- 0 = no registrado, 1 = registrado
        );
        ''');

    // Índices para consultas frecuentes
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_lecturas_cuenta ON lecturas(cuenta);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_lecturas_synced ON lecturas(sincronizado);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_lecturas_synced ON lecturas(registrado);',
    );
  }
}
