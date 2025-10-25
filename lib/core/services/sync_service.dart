import 'package:nexsys_app/core/services/connectivity_service.dart';
import 'package:nexsys_app/core/services/local_database_service.dart';
import 'package:nexsys_app/features/lecturas/data/data.dart';

class SyncService {
  final LecturasDatasourceImpl remote;

  SyncService(this.remote);

  Future<void> syncPendingLecturas(String token) async {
    final hasNet = await ConnectivityService.hasConnection();
    if (!hasNet) return;

    final pendingLecturas = await LocalDatabaseService.getPendingSync();

    for (final lectura in pendingLecturas) {
      try {
        await remote.updateLectura(lectura.toJson(), token);
        await LocalDatabaseService.markAsSynced(lectura.id);
      } catch (e) {
        // Si falla, la dejamos pendiente
        continue;
      }
    }
  }
}
