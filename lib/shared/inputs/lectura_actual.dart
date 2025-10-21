import 'package:formz/formz.dart';

enum LecturaActualError { empty, value, format, lessThanPrevious }

class LecturaActual extends FormzInput<int?, LecturaActualError> {
  final int? lecturaAnterior;

  // Call super.pure to represent an unmodified form input.
  const LecturaActual.pure({this.lecturaAnterior}) : super.pure(null);

  // Call super.dirty to represent a modified form input.
  const LecturaActual.dirty(super.value, {this.lecturaAnterior})
    : super.dirty();

  String? get errorMessage {
    if (isValid || isPure) return null;

    switch (displayError) {
      case LecturaActualError.empty:
        return 'El campo es requerido';
      case LecturaActualError.value:
        return 'Tiene que ser un número mayor o igual a cero';
      case LecturaActualError.format:
        return 'No tiene formato de número';
      case LecturaActualError.lessThanPrevious:
        return 'La lectura no puede ser menor a la lectura anterior';
      default:
        return null;
    }
  }

  // Override validator to handle validating a given input value.
  @override
  LecturaActualError? validator(int? value) {
    if (value == null) return LecturaActualError.empty;
    if (value > 99999999999) return LecturaActualError.format;
    if (lecturaAnterior != null && value < lecturaAnterior!) {
      return LecturaActualError.lessThanPrevious;
    }

    return null;
  }

  LecturaActual copyWith({int? value, int? lecturaAnterior}) {
    return LecturaActual.dirty(
      value ?? this.value,
      lecturaAnterior: lecturaAnterior ?? this.lecturaAnterior,
    );
  }
}
