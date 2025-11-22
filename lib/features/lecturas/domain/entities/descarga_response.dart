import 'lectura.dart';
import 'novedad.dart';
import 'ruta.dart';

class DescargaResponse {
  final List<Novedad> novedades;
  final List<Ruta> rutas;
  final List<Lectura> lecturas;

  DescargaResponse({
    required this.novedades,
    required this.rutas,
    required this.lecturas,
  });

  factory DescargaResponse.fromJson(Map<String, dynamic> json) {
    return DescargaResponse(
      novedades: (json['novedades'] as List)
          .map((e) => Novedad.fromJson(e))
          .toList(),
      rutas: (json['rutas'] as List).map((e) => Ruta.fromJson(e)).toList(),
      lecturas: (json['lecturas'] as List)
          .map((e) => Lectura.fromJson(e))
          .toList(),
    );
  }
}
