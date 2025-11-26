import 'dart:convert';

class Lectura {
  final int id;
  final String medidor;
  final int cuenta;
  final String propietario;
  final String cedula;
  final int lecturaAnterior;
  final int rutaId;
  final int promedioConsumo;
  final int? novedadId;
  final int? lecturaActual;
  final String? observacion;
  final String? fechaLectura;
  final int? lectorId;
  final int? consumo;
  final double? latitud;
  final double? longitud;
  final List<String> imagenes;
  final bool sincronizado;
  final bool registrado;

  Lectura({
    required this.id,
    required this.medidor,
    required this.cuenta,
    required this.propietario,
    required this.cedula,
    required this.lecturaAnterior,
    required this.rutaId,
    required this.promedioConsumo,
    this.novedadId,
    this.lecturaActual,
    this.observacion,
    this.consumo,
    this.latitud,
    this.longitud,
    this.imagenes = const [],
    this.sincronizado = true,
    this.fechaLectura,
    this.lectorId,
    this.registrado = false,
  });

  Lectura copyWith({
    int? id,
    String? medidor,
    int? cuenta,
    String? propietario,
    String? cedula,
    int? lecturaAnterior,
    int? lecturaActual,
    String? observacion,
    int? consumo,
    int? novedadId,
    double? latitud,
    double? longitud,
    List<String>? imagenes,
    bool? sincronizado,
    bool? registrado,
    String? fechaLectura,
    int? lectorId,
    int? rutaId,
    int? promedioConsumo,
  }) {
    return Lectura(
      id: id ?? this.id,
      medidor: medidor ?? this.medidor,
      cuenta: cuenta ?? this.cuenta,
      propietario: propietario ?? this.propietario,
      cedula: cedula ?? this.cedula,
      lecturaAnterior: lecturaAnterior ?? this.lecturaAnterior,
      lecturaActual: lecturaActual ?? this.lecturaActual,
      observacion: observacion ?? this.observacion,
      consumo: consumo ?? this.consumo,
      novedadId: novedadId ?? this.novedadId,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      imagenes: imagenes ?? this.imagenes,
      sincronizado: sincronizado ?? this.sincronizado,
      registrado: registrado ?? this.registrado,
      fechaLectura: fechaLectura ?? this.fechaLectura,
      lectorId: lectorId ?? this.lectorId,
      rutaId: rutaId ?? this.rutaId,
      promedioConsumo: promedioConsumo ?? this.promedioConsumo, 
    );
  }

  /// ✅ Para guardar en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medidor': medidor,
      'cuenta': cuenta,
      'propietario': propietario,
      'cedula': cedula,
      'lecturaAnterior': lecturaAnterior, // ✔ corregido
      'lecturaActual': lecturaActual, // ✔ corregido
      'observacion': observacion,
      'consumo': consumo,
      'novedadId': novedadId, // ✔ corregido
      'latitud': latitud,
      'longitud': longitud,
      'imagenes': jsonEncode(imagenes),
      'sincronizado': sincronizado ? 1 : 0,
      'registrado': registrado ? 1 : 0,
      'fechaLectura': fechaLectura,
      'lectorId': lectorId,
      'rutaId': rutaId,
      'promedioConsumo': promedioConsumo,
    };
  }

  /// ✅ Para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lectura_actual': lecturaActual,
      'descripcion': observacion,
      'consumo': consumo,
      'cedula': cedula,
      'novedad_id': novedadId,
      'fecha_lectura': DateTime.now().toIso8601String(),
      'latitud': latitud,
      'longitud': longitud,
      'imagenes': imagenes, // se usa solo si ya están en servidor
    };
  }

  factory Lectura.fromMap(Map<String, dynamic> map) {
    List<String> imagenesList = [];

    // decodificar imágenes
    final rawImagenes = map['imagenes'];
    if (rawImagenes != null) {
      try {
        final decoded = jsonDecode(rawImagenes);
        if (decoded is List) {
          imagenesList = List<String>.from(decoded);
        }
      } catch (_) {
        imagenesList = [rawImagenes.toString()];
      }
    }

    return Lectura(
      id: map['lecturaId'] as int,
      medidor: map['medidor'] as String,
      cuenta: map['cuenta'] as int,
      propietario: map['propietario'] as String,
      cedula: map['cedula'] as String,
      lecturaAnterior: map['lecturaAnterior'] as int, // ✔ correct key
      lecturaActual: map['lecturaActual'] as int?, // ✔ correct key
      observacion: map['observacion'] as String?,
      consumo: map['consumo'] as int?,
      novedadId: map['novedadId'] as int?, // ✔ correct key
      latitud: (map['latitud'] as num?)?.toDouble(),
      longitud: (map['longitud'] as num?)?.toDouble(),
      fechaLectura: map['fechaLectura'] as String?, // ✔ correct
      lectorId: map['lectorId'] as int?, // ✔ correct
      sincronizado: map['sincronizado'] == 1,
      registrado: map['registrado'] == 1,
      imagenes: imagenesList,
      rutaId: map['rutaId'],
      promedioConsumo: map['promedioConsumo'], 
    );
  }

  factory Lectura.fromJson(Map<String, dynamic> json) {
    return Lectura(
      id: json['id'],
      medidor: json['medidor'],
      cuenta: json['cuenta'],
      propietario: json['propietario'],
      cedula: json['cedula'],
      lecturaAnterior: json['lectura_anterior'],
      novedadId: json['novedadId'],
      rutaId: json['ruta_id'],
      promedioConsumo: json['proemdio'], 
    );
  }
}
