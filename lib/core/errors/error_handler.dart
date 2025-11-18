import 'package:dio/dio.dart';
import 'package:nexsys_app/core/errors/errors.dart';

Never handleDioError(DioException e) {
  final status = e.response?.statusCode;

  if (status == 401) {
    throw CustomError(e.response?.data['message'] ?? 'No autorizado');
  }

  if (status == 400 || status == 404 || status == 409) {
    throw CustomError(e.response?.data['message'] ?? 'Error en la petición');
  }

  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout) {
    throw CustomError('Sin conexión a Internet');
  }

  if (e.type == DioExceptionType.badResponse) {
    throw CustomError('Error en el servidor');
  }

  throw CustomError('Error inesperado');
}
