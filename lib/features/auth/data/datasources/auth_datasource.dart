import 'package:dio/dio.dart';
import 'package:nexsys_app/core/constants/constants.dart';
import 'package:nexsys_app/core/errors/errors.dart';
import 'package:nexsys_app/features/auth/data/data.dart';
import 'package:nexsys_app/features/auth/domain/domain.dart';

class AuthDataSourceImpl extends AuthDataSource {
  final dio = Dio(BaseOptions(baseUrl: Environment.apiUrl,connectTimeout: const Duration(seconds: 10),));

  @override
  Future<User> checkAuthStatus(String token) async {
    try {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.next(options);
          },
          onError: (e, handler) {
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

      return UserMapper.userJsonToEntity(response.data);
    } on DioException catch (e) {
      handleDioError(e);
    }
  }
}
