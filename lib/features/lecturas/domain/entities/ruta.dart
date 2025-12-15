class Ruta {
  final int id;
  final int sectorId;
  final String detalle;
  final bool cerrado;

  Ruta({
    required this.id,
    required this.sectorId,
    required this.detalle,
    required this.cerrado,
  });

  factory Ruta.fromJson(Map<String, dynamic> json) {
    return Ruta(
      id: json['id'],
      sectorId: json['sector_id'],
      detalle: json['detalle'],
      cerrado: false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sector_id': sectorId,
    'detalle': detalle,
    'cerrado': cerrado,
  };

  factory Ruta.fromMap(Map<String, dynamic> map) => Ruta(
    id: map['rutaId'],
    sectorId: map['sector_id'],
    detalle: map['detalle'],
    cerrado: map['cerrado'] == 1,
  );
}
