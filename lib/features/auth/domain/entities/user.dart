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
}
