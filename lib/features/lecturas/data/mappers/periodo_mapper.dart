import 'package:nexsys_app/features/lecturas/domain/domain.dart';

class PeriodoMapper {
  static Periodo jsonToEntity(Map<String, dynamic> json) {
    return Periodo(
      id: json["id"],
      periodo: json["periodo"],
        total: json["total"],
        totalLectura: json["total_lectura"],
    );
  }
}
