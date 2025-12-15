import 'package:formz/formz.dart';

enum NovedadError { empty }

class NovedadInput extends FormzInput<int?, NovedadError> {
  const NovedadInput.pure(int? value) : super.pure(null);
  const NovedadInput.dirty([super.value]) : super.dirty();

  String? get errorMessage {
    if (isValid || isPure) return null;

    if (displayError == NovedadError.empty) return 'La novedad es requerido';

    return null;
  }

  @override
  NovedadError? validator(int? value) {
    if (value == null ||
        value.toString().isEmpty ||
        value.toString().trim().isEmpty) {
      return NovedadError.empty;
    }
    if ( value == -1 ) return NovedadError.empty;

    /*final isInteger = int.tryParse( value.toString()) ?? -1;
    if ( isInteger == -1 ) return NovedadError.format;*/

    //if ( value < 0 ) return StockError.value;
    return null;
  }
}
