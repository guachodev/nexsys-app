/* class Novedad {
  final int? id;
  final String name;
  final bool isDefault;

  Novedad({required this.id, required this.name, required this.isDefault});
}
 */
class Novedad {
  final int id;
  final String detalle;
  final bool isDefault;

  Novedad({required this.id, required this.detalle, required this.isDefault});

  factory Novedad.fromJson(Map<String, dynamic> json) {
    return Novedad(
      id: json['id'],
      detalle: json['detalle'], // se mantiene el nombre con doble "ll"
      isDefault: json['default'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'detallle': detalle,
    'default': isDefault,
  };
}
