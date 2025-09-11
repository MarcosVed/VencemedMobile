class Estabelecimento {
  final int id;
  final String nome;
  final String endereco;
  final String telefone;
  final String tipo;
  final String descricao;
  final String? foto;

  Estabelecimento({
    required this.id,
    required this.nome,
    required this.endereco,
    required this.telefone,
    required this.tipo,
    required this.descricao,
    this.foto,
  });
}