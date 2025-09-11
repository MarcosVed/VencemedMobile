class Mensagem {
  final int id;
  final DateTime dataMensagem;
  final String emissor;
  final String email;
  final String? telefone;
  final String texto;
  final String statusMensagem;

  Mensagem({
    required this.id,
    required this.dataMensagem,
    required this.emissor,
    required this.email,
    this.telefone,
    required this.texto,
    required this.statusMensagem,
  });
}