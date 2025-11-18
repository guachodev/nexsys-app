import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:nexsys_app/core/constants/constants.dart';

class DioClient {
  static Dio create() {
    final logger = Logger();

    final dio = Dio(
      BaseOptions(
        baseUrl: Environment.apiUrl,
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 12),
        sendTimeout: const Duration(seconds: 12),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          logger.i('[REQUEST] ${options.method} => ${options.path}');
          logger.i('BODY => ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          logger.i('[RESPONSE] => STATUS: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (e, handler) {
          logger.e('[DIO ERROR] => ${e.message}');
          handler.next(e);
        },
      ),
    );

    return dio;
  }
}
