import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class LocalImage {
  final File file;
  final int sizeBytes;
  final DateTime modified;

  LocalImage({
    required this.file,
    required this.sizeBytes,
    required this.modified,
  });
}

class ImageService {
  static Future<String> saveAsWebP(String originalPath, int lecturaId) async {
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
      quality: 80, // Calidad 1–100
      format: CompressFormat.webp, // WebP
      minWidth: 1280, // Reducción automática
      minHeight: 1280,
    );

    if (result == null) {
      throw Exception("No se pudo comprimir la imagen a WebP");
    }

    return result.path;
  }

  static String _t(int v) => v.toString().padLeft(2, "0");

  static Future<List<LocalImage>> getLocalImages() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory("${appDir.path}/.lecturas");

    if (!await dir.exists()) return [];

    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.webp'))
        .toList();

    return files.map((file) {
      final stat = file.statSync();
      return LocalImage(
        file: file,
        sizeBytes: stat.size,
        modified: stat.modified,
      );
    }).toList();
  }

  static Future<void> clearAllImages() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory("${appDir.path}/.lecturas");

    if (!await dir.exists()) return;

    await for (final entity in dir.list()) {
      if (entity is File && entity.path.endsWith('.webp')) {
        await entity.delete();
      }
    }
  }

  static Future<void> deleteImage(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }

  // 👉 EXPORTAR TODAS LAS IMÁGENES A ZIP
  static Future<File?> exportImagesAsZip() async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory("${appDir.path}/.lecturas");

    if (!await imagesDir.exists()) {
      return null;
    }

    final images = imagesDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.webp'))
        .toList();

    if (images.isEmpty) return null;

    final archive = Archive();

    for (final file in images) {
      final bytes = await file.readAsBytes();
      final filename = file.uri.pathSegments.last;

      archive.addFile(
        ArchiveFile(
          filename,
          bytes.length,
          bytes,
        ),
      );
    }

    // Nombre profesional con timestamp
    final now = DateTime.now();
    final zipName =
        "imagenes_lecturas_${now.year}${now.month}${now.day}_${now.hour}${now.minute}${now.second}.zip";

    final tempDir = await getTemporaryDirectory();
    final zipFile = File("${tempDir.path}/$zipName");

    final encoder = ZipEncoder();
    final zipData = encoder.encode(archive);

    await zipFile.writeAsBytes(zipData);

    return zipFile;
  }
}
