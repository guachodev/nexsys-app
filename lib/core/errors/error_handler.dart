import 'package:dio/dio.dart';

Never handleDioError(DioException e) {
  final status = e.response?.statusCode;

  if (status == 401) {
    throw CustomError(e.response?.data['message'] ?? 'Tu sesión ha expirado o el token es inválido.');
  }

  if (status == 400 || status == 404 || status == 409) {
    throw CustomError(e.response?.data['message'] ?? 'La petición no es válida. Revisa los datos.');
  }

  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout) {
    throw CustomError('No se pudo conectar con el servidor. Verifica tu conexión.');
  }

  if (e.type == DioExceptionType.badResponse) {
    throw CustomError('El servidor tuvo un problema. Intenta más tarde.');
  }

  throw CustomError('Ocurrió un problema inesperado. Intenta nuevamente.');
}

class CustomError implements Exception {
  final String message;
  CustomError(this.message);
}
