class Ruta {
  final int id;
  final int sectorId;
  final String detalle;

  Ruta({required this.id, required this.sectorId, required this.detalle});

  factory Ruta.fromJson(Map<String, dynamic> json) {
    return Ruta(
      id: json['id'],
      sectorId: json['sector_id'],
      detalle: json['detalle'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sector_id': sectorId,
    'detalle': detalle,
  };

  factory Ruta.fromMap(Map<String, dynamic> map) => Ruta(
    id: map['id'],
    sectorId: map['sectorId'],
    detalle: map['detalle'],
  );
}
