import '../entities/user.dart';

abstract class AuthDataSource {
  Future<User> login(String username, String password);
  Future<User> checkAuthStatus(String token);
}
