import 'dart:convert';

class Lectura {
  final int id;
  final String medidor;
  final int cuenta;
  final String propietario;
  final String cedula;
  final int lecturaAnterior;
  final int? lecturaActual;
  final String? observacion;
  final String? fechaLectura;
  final int? lectorId;
  final int? consumo;
  final int? novedadId;
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
    this.lecturaActual,
    this.observacion,
    this.consumo,
    this.novedadId,
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
      'lectura_anterior': lecturaAnterior,
      'lectura_actual': lecturaActual,
      'observacion': observacion,
      'consumo': consumo,
      'novedad_id': novedadId,
      'latitud': latitud,
      'longitud': longitud,
      'imagenes': jsonEncode(imagenes),
      'sincronizado': sincronizado ? 1 : 0,
      'registrado': registrado ? 1 : 0,
      'fechaLectura': fechaLectura,
      'lectorId': lectorId,
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
    return Lectura(
      id: map['id'],
      medidor: map['medidor'],
      cuenta: map['cuenta'],
      propietario: map['propietario'],
      cedula: map['cedula'],
      lecturaAnterior: map['lecturaAnterior'],
      lecturaActual: map['lecturaActual'],
      observacion: map['observacion'],
      consumo: map['consumo'],
      novedadId: map['novedadId'],
      latitud: map['latitud']?.toDouble(),
      longitud: map['longitud']?.toDouble(),
      imagenes: map['imagenes'] != null
          ? List<String>.from(jsonDecode(map['imagenes']))
          : [],
      sincronizado: map['sincronizado'] == 1,
      registrado: map['registrado'] == 1,
      fechaLectura: map['fechaLectura'],
      lectorId: map['lectorId'],
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
    );
  }
}
