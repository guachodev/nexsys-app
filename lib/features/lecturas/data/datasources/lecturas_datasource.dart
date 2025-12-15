import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:nexsys_app/core/constants/constants.dart';
import 'package:nexsys_app/core/errors/errors.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';
import 'package:path/path.dart' as p;

import '../mappers/periodo_mapper.dart';

class LecturasDatasourceImpl extends LecturasDatasource {
  final dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiUrl,
      connectTimeout: const Duration(seconds: 10),
    ),
  );

  @override
  Future<Periodo?> getPeriodoActivo(String token) async {
    try {
      final response = await dio.get(
        '/lectura/periodo',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data.toString().isEmpty) return null;

      return PeriodoMapper.jsonToEntity(response.data);
    } on DioException catch (e) {
      handleDioError(e);
    }
  }

  @override
  Future<List<Lectura>> searchLecturas(String query) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> descargarLecturasAsignadas(
    String periodoId,
    String token,
  ) async {
    try {
      final response = await dio.get(
        '/lectura/descargar/$periodoId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      handleDioError(e);
    }
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
      handleDioError(e);
    }
  }

  Future<int?> uploadLecturaImage({
    required int lecturaId,
    required String localPath,
    required String token,
    required String sector,
    required String periodo,
  }) async {
    try {
      final formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(localPath),
        "periodo": periodo,
        "ruta": sector,
        "nombre": p.basename(localPath),
      });

      final response = await dio.post(
        "/lectura/$lecturaId/imagen",
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "multipart/form-data",
          },
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final remoteId = response.data["remote_id"];
        return remoteId;
      }
    } catch (e) {
      debugPrint("❌ Error subiendo imagen $localPath → $e");
    }

    return null;
  }
}
