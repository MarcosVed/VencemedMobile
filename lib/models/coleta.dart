class Coleta {
  final int id;
  final String info;
  final String cep;
  final String numero;
  final String complemento;
  final String telefone;
  final String tipoMedicamento;
  final String tipoColeta;
  final DateTime dataColeta;
  final int usuarioId;
  final int estabelecimentoId;
  final String statusColeta;

  Coleta({
    required this.id,
    required this.info,
    required this.cep,
    required this.numero,
    required this.complemento,
    required this.telefone,
    required this.tipoMedicamento,
    required this.tipoColeta,
    required this.dataColeta,
    required this.usuarioId,
    required this.estabelecimentoId,
    required this.statusColeta,
  });
}