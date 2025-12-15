import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ImageStorageService {
  static Future<String> saveCompressedImage(String originalPath) async {
    final dir = await getApplicationDocumentsDirectory();
    final imgDir = Directory("${dir.path}/lecturas_imgs");

    if (!await imgDir.exists()) {
      await imgDir.create(recursive: true);
      await File("${imgDir.path}/.nomedia").create();
    }

    final targetPath =
        "${imgDir.path}/${DateTime.now().millisecondsSinceEpoch}.webp";

    final compressed = await FlutterImageCompress.compressWithFile(
      originalPath,
      quality: 80,
      minWidth: 1920,
      minHeight: 1920,
      format: CompressFormat.webp,
    );

    final file = File(targetPath);
    await file.writeAsBytes(compressed!);

    return targetPath;
  }
}
