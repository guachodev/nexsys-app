import 'dart:convert';

class User {
  final int id;
  final int empleadoId;
  final String email;
  final String fullName;
  final String rol;
  final String token;
  final String refreshToken;

  User({
    required this.id,
    required this.empleadoId,
    required this.email,
    required this.fullName,
    required this.rol,
    required this.token,
    required this.refreshToken,
  });

  // Convertir User a Map (para guardar en local)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'empleadoId': empleadoId,
      'email': email,
      'fullName': fullName,
      'rol': rol,
      'token': token,
      'refreshToken': refreshToken,
    };
  }

  // Crear User desde Map (recuperar de local)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      empleadoId: json['empleadoId'],
      email: json['email'],
      fullName: json['fullName'],
      rol: json['rol'],
      token: json['token'],
      refreshToken: json['refreshToken'],
    );
  }

  // Opcional: convertir a String JSON
  String toJsonString() => jsonEncode(toJson());

  // Opcional: crear User desde String JSON

  factory User.fromJsonString(String jsonString) {
  final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
  return User.fromJson(jsonMap);
}

}
