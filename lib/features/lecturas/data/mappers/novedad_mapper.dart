import 'package:nexsys_app/features/lecturas/domain/domain.dart';

class NovedadMapper {
  static Novedad jsonToEntity(Map<String, dynamic> json) {
    return Novedad(
      id: json['id'],
      name: json['name'],
      isDefault: json['default'],
    );
  }
}
