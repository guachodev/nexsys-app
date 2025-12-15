class Periodo {
  final int id;
  final String name;
  final bool cerrado;
  final bool descargado;
  final bool descargable;
  final String? fecha;
  final int? userId;

  final int totalMedidores;
  final int medidoresLeidos;
  final int pendientes;
  final double porcentajeAvance;

  Periodo({
    required this.id,
    required this.name,
    this.descargado = false,
    this.cerrado = false,
    this.fecha,
    this.totalMedidores = 0,
    this.medidoresLeidos = 0,
    this.pendientes = 0,
    this.porcentajeAvance = 0.0,
    this.userId,
    required this.descargable,
  });

  Periodo copyWith({
    int? id,
    String? name,
    String? fecha,
    bool? cerrado,
    bool? descargado,
    int? totalMedidores,
    int? medidoresLeidos,
    int? pendientes,
    double? porcentajeAvance,
    int? userId,
    bool? descargable,
  }) {
    return Periodo(
      id: id ?? this.id,
      name: name ?? this.name,
      fecha: fecha ?? this.fecha,
      cerrado: cerrado ?? this.cerrado,
      descargado: descargado ?? this.descargado,
      totalMedidores: totalMedidores ?? this.totalMedidores,
      medidoresLeidos: medidoresLeidos ?? this.medidoresLeidos,
      pendientes: pendientes ?? this.pendientes,
      porcentajeAvance: porcentajeAvance ?? this.porcentajeAvance,
      userId: userId ?? this.userId,
      descargable: descargable ?? this.descargable,
    );
  }

  factory Periodo.fromMap(Map<String, dynamic> map) => Periodo(
    id: map['id'],
    name: map['name'],
    descargado: map['descargado'],
    cerrado: map['cerrado'],
    descargable: map['descargable'],
  );
}

class RutaCerrada {
  final int id;
  final bool cerrado;

  RutaCerrada({required this.id, required this.cerrado});
}
