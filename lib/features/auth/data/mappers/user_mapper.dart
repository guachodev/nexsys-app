import 'package:nexsys_app/features/auth/domain/entities/user.dart';

class UserMapper {
  static User userJsonToEntity(Map<String, dynamic> json) => User(
    id: json['user']['id'],
    email: json['user']['email'] ?? '',
    fullName: json['user']['name'] ?? '',
    rol: json['user']['rol'] ?? '',
    empleadoId: 2,
    token: json['token'] ?? '',
    refreshToken: json['refreshToken'] ?? '',
  );
}
