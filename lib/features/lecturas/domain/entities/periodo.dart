class Periodo {
  final int id;
  final String name;
  final bool? dowload;
  final String? date;

  Periodo({required this.id, required this.name, this.dowload, this.date});

  Periodo copyWith({int? id, String? name, bool? dowload, String? date}) {
    return Periodo(
      id: id ?? this.id,
      name: name ?? this.name,
      dowload: dowload ?? this.dowload,
      date: date ?? this.date,
    );
  }

  factory Periodo.fromMap(Map<String, dynamic> map) => Periodo(
    id: map['id'],
    name: map['name'],
    // estado: map['estado'],
    dowload: map['dowload'],
    // fechaSync: map['fechaSync'],
  );
}
