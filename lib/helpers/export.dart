
import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<File> saveJsonFile(String jsonString) async {
  final dir = await getApplicationDocumentsDirectory();
  final path = "${dir.path}/lecturas_export.json";

  final file = File(path);
  await file.writeAsString(jsonString);

  return file;
}