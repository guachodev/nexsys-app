import 'package:nexsys_app/features/lecturas/domain/domain.dart';

class PeriodoMapper {
  static Periodo jsonToEntity(Map<String, dynamic> json) {
    return Periodo(id: json["id"], name: json["periodo"], dowload: false);
  }

  static Periodo jsonTodb(Map<String, dynamic> json) {
    return Periodo(id: json["id"], name: json["nombre"], dowload: json['descargado'] == 1);
  }
}
