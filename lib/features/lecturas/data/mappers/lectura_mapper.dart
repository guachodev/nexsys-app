import 'package:nexsys_app/features/lecturas/domain/domain.dart';

class LecturaMapper {
  static Lectura jsonToEntity(Map<String, dynamic> json) {
    return Lectura(
      id: json["id"],
      clienteId: json["cliente_id"],
      medidor: json["medidor"],
      catastro: json["catastro"]!,
      propietario: json["propietario"],
      cedula: json["cedula"],
      lecturaAnterior:json["lectura_anterior"], 
      estado: 'pendiente',
      observaciones: '',
      periodo: json["periodo"],
    );
  }
}
