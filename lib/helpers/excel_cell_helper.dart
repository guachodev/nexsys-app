import 'package:excel/excel.dart';

/// Convierte cualquier valor dinámico en un CellValue válido para Excel.
/// Soporta: null, int, double, bool y String.
CellValue cv(dynamic value) {
  if (value == null) {
    return TextCellValue(''); 
  }

  if (value is int) {
    return IntCellValue(value);
  }

  if (value is double) {
    return DoubleCellValue(value);
  }

  if (value is bool) {
    return BoolCellValue(value);
  }

  // Para String y cualquier otro tipo
  return TextCellValue(value.toString());
}
