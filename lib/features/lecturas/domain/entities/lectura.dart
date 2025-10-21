class Lectura {
  final int id;
  final int? clienteId;
  final String medidor;
  final String catastro;
  final String propietario;
  final String cedula;
  final String periodo;
  final int lecturaAnterior;
  final String? estado;
  final String? observaciones;

  Lectura({
    required this.id,
    required this.clienteId,
    required this.medidor,
    required this.catastro,
    required this.propietario,
    required this.cedula,
    required this.periodo,
    required this.lecturaAnterior,
    required this.estado,
    this.observaciones=''
  });
}
