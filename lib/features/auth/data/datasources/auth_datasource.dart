import 'package:dio/dio.dart';
import 'package:nexsys_app/core/constants/environment.dart';
import 'package:nexsys_app/core/errors/error_handler.dart';
import 'package:nexsys_app/core/errors/errors.dart';
import 'package:nexsys_app/features/auth/data/data.dart';
import 'package:nexsys_app/features/auth/domain/domain.dart';

class AuthDataSourceImpl extends AuthDataSource {
  final dio = Dio(BaseOptions(baseUrl: Environment.apiUrl));
  

  @override
  Future<User> checkAuthStatus(String token) async {
    try {
      dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('[REQUEST] => ${options.method} ${options.path}');
          return handler.next(options);
        },
        onError: (e, handler) {
          print('[ERROR] => ${e.message}');
          return handler.next(e);
        },
      ),
    );
      final response = await dio.get(
        '/auth/check-status',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final user = UserMapper.userJsonToEntity(response.data);
      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw CustomError('Token incorrecto');
      }
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<User> login(String username, String password) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {'username': username, 'password': password},
      );

      final user = UserMapper.userJsonToEntity(response.data);
      return user;
    } on DioException catch (e) {
      handleDioError(e);
    }
  }
}
