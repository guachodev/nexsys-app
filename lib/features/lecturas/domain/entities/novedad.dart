class Novedad {
  final int id;
  final String detalle;
  final bool isDefault;

  Novedad({required this.id, required this.detalle, required this.isDefault});

  factory Novedad.fromJson(Map<String, dynamic> json) {
    //int defectoParaSqlite = json['defecto'] == true ? 1 : 0;
    return Novedad(
      id: json['id'],
      detalle: json['detalle'],
      isDefault: json['defecto'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'detalle': detalle,
    'defecto': isDefault,
  };

  factory Novedad.fromMap(Map<String, dynamic> map) {
    return Novedad(
      id: map['id'],
      detalle: map['detalle'],
      isDefault: map['defecto'] == 1,
    );
  }
}
