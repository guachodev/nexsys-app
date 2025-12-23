import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static String backupFilename() {
    final now = DateTime.now();
    final formatted =
        "${now.year}${now.month.toString().padLeft(2, '0')}"
        "${now.day.toString().padLeft(2, '0')}"
        "${now.hour.toString().padLeft(2, '0')}"
        "${now.minute.toString().padLeft(2, '0')}"
        "${now.second.toString().padLeft(2, '0')}";

    return "backup_nexsysapp_$formatted.db";
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'nexsys_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<File> getDatabaseFile() async {
    final dbDir = await getDatabasesPath();
    final dbPath = join(dbDir, 'nexsys_app.db');
    return File(dbPath);
  }

  static Future<void> clearAllTables() async {
    final db = await DatabaseProvider.db;

    await db.transaction((txn) async {
      await txn.delete('lectura_images');
      await txn.delete('lecturas');
      await txn.delete('ruta');
      await txn.delete('periodo');
      await txn.delete('novedad');
    });
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Ejecutar scripts de creación de tablas
    await db.execute('''
          CREATE TABLE IF NOT EXISTS periodo (
            periodoId INTEGER,
            usuarioId INTEGER,
            nombre TEXT,
            cerrado INTEGER,
            descargado INTEGER,
            fecha TEXT,
            descargable INTGER,
            PRIMARY KEY (periodoId, usuarioId)
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
          rutaId INTEGER,
          usuarioId INTEGER,
          sector_id INTEGER,
          cerrado INTEGER,
          detalle TEXT,
          PRIMARY KEY (rutaId, usuarioId)
        );
        ''');

    await db.execute('''
        CREATE TABLE IF NOT EXISTS lecturas (
        id INTEGER PRIMARY KEY,
        lecturaId INTEGER,
        usuarioId INTEGER,
        medidor TEXT,
        cuenta INTEGER,
        propietario TEXT,
        sector TEXT,
        periodo TEXT,
        direccion TEXT,
        cedula TEXT,
        lecturaAnterior INTEGER DEFAULT 0,
        lecturaActual INTEGER DEFAULT 0,
        promedioConsumo INTEGER DEFAULT 0,
        orden INTEGER,
        fechaLectura TEXT,
        lectorId INTEGER,
        rutaId INTEGER,
        consumo INTEGER,
        observacion TEXT,
        novedadId INTEGER,
        imagenes TEXT,
        latitud REAL,
        longitud REAL,
        sincronizado INTEGER DEFAULT 0,        -- 0 = no sincronizado, 1 = sincronizado
        registrado INTEGER DEFAULT 0,    -- 0 = no registrado, 1 = registrado
        UNIQUE(lecturaId, usuarioId) 
        );
        ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS lectura_images (
        id INTEGER PRIMARY KEY,      -- UUID generado en el dispositivo
        lecturaId INTEGER NOT NULL,     -- lectura local o remota
        usuarioId INTEGER NOT NULL,     -- para separar datos por usuario
        path TEXT NOT NULL,       -- archivo local
        remote_id TEXT,                 -- ID que devuelve el backend
        sync_state TEXT NOT NULL,       -- pending, synced, deleted
        updated_at INTEGER NOT NULL,    -- timestamp unix
        FOREIGN KEY (lecturaId) REFERENCES lecturas(id)
      );
      ''');

    // Índices para consultas frecuentes
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_lecturas_cuenta ON lecturas(cuenta);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_lecturas_sincronizado ON lecturas(sincronizado);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_lecturas_registrado ON lecturas(registrado);',
    );
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      // Ejemplo: agregar nuevas columnas a lecturas
      /* await db.execute(
        'ALTER TABLE lecturas ADD COLUMN promedio INTEGER DEFAULT 0',
      ); */
      /* await db.execute(
        'ALTER TABLE lecturas ADD COLUMN nuevoCampo2 INTEGER DEFAULT 0',
      ); */
    }

    // Si en el futuro agregas más versiones:
    // if (oldVersion < 3) { ... }
  }
}
