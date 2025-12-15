import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ImageService {
  static Future<String> saveAsWebP(
    String originalPath,
    int lecturaId,
  ) async {
    // Carpeta oculta .lecturas
    final appDir = await getApplicationDocumentsDirectory();
    final hiddenDir = Directory("${appDir.path}/.lecturas");

    if (!await hiddenDir.exists()) {
      await hiddenDir.create(recursive: true);
      await File("${hiddenDir.path}/.nomedia").create();
    }

    // Nombre con timestamp mejorado
    final now = DateTime.now();
    final timestamp =
        "${now.year}${_t(now.month)}${_t(now.day)}_${_t(now.hour)}${_t(now.minute)}${_t(now.second)}_${now.millisecond}";

    final outputPath = "${hiddenDir.path}/${lecturaId}_$timestamp.webp";

    // Compresión eficiente
    final result = await FlutterImageCompress.compressAndGetFile(
      originalPath,
      outputPath,
      quality: 80,                   // Calidad 1–100
      format: CompressFormat.webp,   // WebP
      minWidth: 1280,                // Reducción automática
      minHeight: 1280,
    );

    if (result == null) {
      throw Exception("No se pudo comprimir la imagen a WebP");
    }

    return result.path;
  }

  static String _t(int v) => v.toString().padLeft(2, "0");

}
