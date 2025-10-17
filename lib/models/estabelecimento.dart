class Estabelecimento {
  final int id;
  final String nome;
  final String info;
  final String cep;
  final String numero;
  final String? complemento;
  final String telefone;
  final String tipo;
  final String coleta;
  final String statusEstabelecimento;
  final double? latitude;
  final double? longitude;
  final String? fotoEst;

  Estabelecimento({
    required this.id,
    required this.nome,
    required this.info,
    required this.cep,
    required this.numero,
    this.complemento,
    required this.telefone,
    required this.tipo,
    required this.coleta,
    required this.statusEstabelecimento,
    this.latitude,
    this.longitude,
    this.fotoEst,
  });

  factory Estabelecimento.fromJson(Map<String, dynamic> json) {
    return Estabelecimento(
      id: json['id'],
      nome: json['nome'],
      info: json['info'],
      cep: json['cep'],
      numero: json['numero'],
      complemento: json['complemento'],
      telefone: json['telefone'],
      tipo: json['tipo'],
      coleta: json['coleta'],
      statusEstabelecimento: json['statusEstabelecimento'],
      fotoEst: json['fotoEst'],
    );
  }

  String get endereco => '$numero${complemento != null ? ', $complemento' : ''}';
  String get descricao => info;
}