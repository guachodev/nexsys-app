import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Solicita todos los permisos necesarios al iniciar la app
  Future<void> requestInitialPermissions() async {
    await _handlePermission(Permission.camera, 'Necesitamos acceso a la cámara para escanear códigos.');
    await _handlePermission(Permission.photos, 'Necesitamos acceso a tus fotos para seleccionar imágenes.'); // iOS
    await _handlePermission(Permission.storage, 'Necesitamos acceso al almacenamiento para seleccionar imágenes.'); // Android
    await _handlePermission(Permission.locationWhenInUse, 'Necesitamos tu ubicación para funciones de geolocalización.');
  }

  /// Método genérico para manejar permisos con explicación previa si es necesario
  Future<void> _handlePermission(Permission permission, String rationaleMessage) async {
    final status = await permission.status;

    if (status.isDenied || status.isRestricted) {
      final shouldExplain = await permission.shouldShowRequestRationale;
      if (shouldExplain) {
        // Aquí puedes mostrar un diálogo personalizado con el mensaje
        print('Mostrar explicación: $rationaleMessage');
        // Ejemplo: await showDialog(...);
      }

      final result = await permission.request();
      if (result.isDenied) {
        print('Permiso denegado: $permission');
      } else if (result.isPermanentlyDenied) {
        print('Permiso permanentemente denegado: $permission');
        // Puedes redirigir a la configuración del sistema
        await openAppSettings();
      }
    }
  }

  /// Verifica si todos los permisos están concedidos
  Future<bool> hasAllPermissions() async {
    final camera = await Permission.camera.isGranted;
    final photos = await Permission.photos.isGranted;
    final storage = await Permission.storage.isGranted;
    final location = await Permission.locationWhenInUse.isGranted;

    return camera && (photos || storage) && location;
  }
}
