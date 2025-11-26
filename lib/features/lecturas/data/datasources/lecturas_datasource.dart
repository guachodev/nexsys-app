import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:nexsys_app/core/constants/constants.dart';
import 'package:nexsys_app/core/errors/errors.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';

import '../mappers/periodo_mapper.dart';

class LecturasDatasourceImpl extends LecturasDatasource {
  final dio = Dio(BaseOptions(baseUrl: Environment.apiUrl));

  @override
  Future<Periodo?> getPeriodoActivo(String token) async {
    final response = await dio.get(
      '/lectura/periodo',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.data.toString().isEmpty) return null;

    print('Api => ${response.data}');

    final periodo = PeriodoMapper.jsonToEntity(response.data);
    return periodo;
  }

  @override
  Future<List<Lectura>> searchLecturas(String query) {
    // TODO: implement searchLecturas
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> descargarLecturasAsignadas(
    String periodoId,
    String token,
  ) async {
    final response = await dio.get(
      '/lectura/descargar/$periodoId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }

  Future<void> updateLectura(
    Map<String, dynamic> lecturaLike,
    String token,
  ) async {
    try {
      final int? lecturaId = lecturaLike['id'];
      debugPrint('Updating lectura ID: $lecturaId with data: $lecturaLike');
      await dio.request(
        '/lectura/$lecturaId',
        data: lecturaLike,
        options: Options(
          method: 'PATCH',
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
    } on DioException catch (e) {
      //throw _handleError(e);
      throw CustomError('Error dio: ${e.toString()}');
    } catch (e) {
      throw CustomError('Error inesperado: ${e.toString()}');
    }
  }
}
