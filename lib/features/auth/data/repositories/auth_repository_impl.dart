import 'package:nexsys_app/features/auth/data/data.dart';
import 'package:nexsys_app/features/auth/domain/domain.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthDataSource datasource;

  AuthRepositoryImpl({AuthDataSource? datasource})
    : datasource = datasource ?? AuthDataSourceImpl();

  @override
  Future<User> checkAuthStatus(String token) {
    return datasource.checkAuthStatus(token);
  }

  @override
  Future<User> login(String username, String password) {
    return datasource.login(username, password);
  }
}
