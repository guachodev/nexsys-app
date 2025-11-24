import 'package:nexsys_app/features/lecturas/domain/domain.dart';

class PeriodoMapper {
  static Periodo jsonToEntity(Map<String, dynamic> json) {
    return Periodo(
      id: json["id"],
      name: json["periodo"],
      descargado: json["descargado"] == json,
      cerrado: json["cerrado"] == json,
      fecha: json["fecha"],
    );
  }

  static Periodo jsonTodb(Map<String, dynamic> json) {
    return Periodo(
      id: json["id"],
      name: json["nombre"],
      descargado: json['descargado'] == 1,
      cerrado: json["cerrado"] == json,
      fecha: json["fecha"],
    );
  }
}
