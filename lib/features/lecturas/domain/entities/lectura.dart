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
  final int? consumo;
  final int? novedadId;
  final double? latitud;
  final double? longitud;
  final List<String> imagenes;
  final bool synced;

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
    this.synced = true,
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
    bool? synced,
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
      synced: synced ?? this.synced,
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
      'synced': synced ? 1 : 0,
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
      lecturaAnterior: map['lectura_anterior'],
      lecturaActual: map['lectura_actual'],
      observacion: map['observacion'],
      consumo: map['consumo'],
      novedadId: map['novedad_id'],
      latitud: map['latitud']?.toDouble(),
      longitud: map['longitud']?.toDouble(),
      imagenes: map['imagenes'] != null
          ? List<String>.from(jsonDecode(map['imagenes']))
          : [],
      synced: map['synced'] == 1,
    );
  }

  factory Lectura.fromJson(Map<String, dynamic> json) {
    return Lectura(
      id: json['id'],
      medidor: json['medidor'],
      cuenta: json['cuenta'],
      propietario: json['propietario'],
      cedula: json['cedula'],
      lecturaAnterior: json['lectura_anterior']
    );
  }
}
