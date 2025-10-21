import 'package:dio/dio.dart';
import 'package:nexsys_app/core/constants/constants.dart';
import 'package:nexsys_app/core/errors/errors.dart';
import 'package:nexsys_app/features/lecturas/data/data.dart';
import 'package:nexsys_app/features/lecturas/data/mappers/periodo_mapper.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';

class LecturasDatasourceImpl extends LecturasDatasource {
  final dio = Dio(BaseOptions(baseUrl: Environment.apiUrl));

  @override
  Future<List<Lectura>> getLecturaAsignadasByPage({
    int limit = 10,
    int offset = 0,
  }) async {
    final response = await dio.get<List>(
      '/lectura/asignados?limit=$limit&offset=$offset',
    );
    final List<Lectura> lecturas = [];
    for (final lectura in response.data ?? []) {
      lecturas.add(LecturaMapper.jsonToEntity(lectura));
    }

    return lecturas;
  }

  @override
  Future<void> updateLectura(Map<String, dynamic> lecturaLike,String token) async {
    try {
      final int? lecturaId = lecturaLike['id'];

      final response = await dio.request(
        '/lectura/$lecturaId',
        data: lecturaLike,
        options: Options(method: 'PATCH',headers: {'Authorization': 'Bearer $token'}),
     
      );
      print(response.data);
      //final product = ProductMapper.jsonToEntity(response.data);
      //return product;
    } on DioException catch (e) {
      //throw _handleError(e);
      throw CustomError('Error dio: ${e.toString()}');
    } catch (e) {
      throw CustomError('Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<List<Lectura>> searchLecturas(String query, String token) async {
    if (query.isEmpty) return [];

    final response = await dio.get(
      '/lectura/asignados',
      queryParameters: {'tipo': 'medidor', 'valor': query},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final List<Lectura> lecturas = [];
    for (final lectura in response.data ?? []) {
      lecturas.add(LecturaMapper.jsonToEntity(lectura));
    }

    return lecturas;
  }

  @override
  Future<Periodo?> getPeriodoActivo(String token) async {
    final response = await dio.get('/lectura/periodo',options: Options(headers: {'Authorization': 'Bearer $token'}),);
    print('periodo ${response.data} is null ${response.data == null}');

    if (response.data.toString().isEmpty) return null;

    final periodo = PeriodoMapper.jsonToEntity(response.data);
    return periodo;
  }
  
  @override
  Future<Lectura?> searchLecturasByMedidor(String medidor, String token) async {
    if (medidor.isEmpty) return null;

    final response = await dio.get(
      '/lectura/asignados',
      queryParameters: {'tipo': 'medidor', 'valor': medidor},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final List<Lectura> lecturas = [];
    for (final lectura in response.data ?? []) {
      lecturas.add(LecturaMapper.jsonToEntity(lectura));
    }

    return lecturas.first;
  }
}
