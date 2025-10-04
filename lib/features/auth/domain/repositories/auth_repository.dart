
import 'package:nexsys_app/features/auth/domain/domain.dart';

abstract class AuthRepository {
  Future<User> login(String username, String password);
  Future<User> checkAuthStatus(String token);
}
