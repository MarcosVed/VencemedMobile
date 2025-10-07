class Estabelecimento {
  final int id;
  final String nome;
  final String endereco;
  final String telefone;
  final String tipo;
  final String descricao;
  final String? foto;
  final double? latitude;
  final double? longitude;
  final String? logradouro;
  final String? bairro;
  final String? cidade;
  final String? cep;

  Estabelecimento({
    required this.id,
    required this.nome,
    required this.endereco,
    required this.telefone,
    required this.tipo,
    required this.descricao,
    this.foto,
    this.latitude,
    this.longitude,
    this.logradouro,
    this.bairro,
    this.cidade,
    this.cep,
  });
}