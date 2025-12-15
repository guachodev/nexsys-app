import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexsys_app/features/auth/presentation/presentation.dart';
import 'package:nexsys_app/features/lecturas/data/data.dart';

final lecturasRepositoryProvider = Provider((ref) {
  final repo = LecturasRepositoryImpl();
  final user = ref.watch(authProvider).user;
  return LecturasRepository(datasource: repo, userId: user!.id);
});

class LecturasRepository {
  final LecturasRepositoryImpl datasource;
  final int userId;

  LecturasRepository({required this.datasource, required this.userId});

  // Obtiene el siguiente medidor en orden
  Future<int?> getLecturaOrden(int rutaId) async {
    try {
      return await datasource.getLecturaIdOrdenNext(userId, rutaId);
    } catch (e) {
      debugPrint("Error en getLecturaOrden: $e");
      return null;
    }
  }
}
