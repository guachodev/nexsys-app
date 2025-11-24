import 'dart:io';

import 'package:excel/excel.dart';
import 'package:nexsys_app/features/lecturas/domain/domain.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import 'helpers.dart';

class ExcelExporter {

  static Future<String> exportLecturas(List<Lectura> lecturas) async {
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Lecturas'];

    // ENCABEZADOS
    sheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Cuenta'),
      TextCellValue('Medidor'),
      TextCellValue('Propietario'),
      TextCellValue('Cédula'),
      TextCellValue('Lectura Anterior'),
      TextCellValue('Lectura Actual'),
      TextCellValue('Consumo'),
      TextCellValue('Observación'),
      TextCellValue('Novedad ID'),
      TextCellValue('Imágenes (paths)'),
      TextCellValue('Latitud'),
      TextCellValue('Longitud'),
      TextCellValue('Registrado'),
      TextCellValue('Sincronizado'),
    ]);

    // DATOS
    for (var l in lecturas) {
      sheet.appendRow([
        cv(l.id),
        cv(l.cuenta),
        cv(l.medidor),
        cv(l.propietario),
        cv(l.cedula),
        cv(l.lecturaAnterior),
        cv(l.lecturaActual), // <-- NO FALLA aunque sea null
        cv(l.consumo),
        cv(l.observacion),
        cv(l.novedadId),
        cv(l.imagenes),
        cv(l.latitud),
        cv(l.longitud),
        cv(l.registrado),
        cv(l.sincronizado),
      ]);
    }

    // DIRECTORIO
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/lecturas_exportadas.xlsx";

    // GUARDAR ARCHIVO
    final bytes = excel.encode()!;
    final file = File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes);

    return file.path;
  }

  // Abre el archivo directamente
  static Future<void> openExcel(String path) async {
    await OpenFilex.open(path);
  }
}
