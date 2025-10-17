class Avaliacao {
  final int id;
  final int usuarioId;
  final String nomeUsuario;
  final int estabelecimentoId;
  final int nota;
  final String? comentario;
  final DateTime dataAvaliacao;

  Avaliacao({
    required this.id,
    required this.usuarioId,
    required this.nomeUsuario,
    required this.estabelecimentoId,
    required this.nota,
    this.comentario,
    required this.dataAvaliacao,
  });

  factory Avaliacao.fromJson(Map<String, dynamic> json) {
    return Avaliacao(
      id: json['id'],
      usuarioId: json['usuario']['id'],
      nomeUsuario: json['usuario']['nome'],
      estabelecimentoId: json['estabelecimento']['id'],
      nota: json['nota'],
      comentario: json['comentario'],
      dataAvaliacao: DateTime.parse(json['dataAvaliacao']),
    );
  }
}