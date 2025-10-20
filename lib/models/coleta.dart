import 'estabelecimento.dart';

class Coleta {
  final int id;
  final String info;
  final String cep;
  final String endereco;
  final String numero;
  final String? complemento;
  final String telefone;
  final String tipoMedicamento;
  final String tipoColeta;
  final DateTime dataColeta;
  final String statusColeta;
  final Estabelecimento? estabelecimento;

  Coleta({
    required this.id,
    required this.info,
    required this.cep,
    required this.endereco,
    required this.numero,
    this.complemento,
    required this.telefone,
    required this.tipoMedicamento,
    required this.tipoColeta,
    required this.dataColeta,
    required this.statusColeta,
    this.estabelecimento,
  });

  factory Coleta.fromJson(Map<String, dynamic> json) {
    return Coleta(
      id: json['id'],
      info: json['info'],
      cep: json['cep'],
      endereco: json['endereço'] ?? json['endereco'],
      numero: json['numero'],
      complemento: json['complemento'],
      telefone: json['telefone'],
      tipoMedicamento: json['tipoMedicamento'],
      tipoColeta: json['tipoColeta'],
      dataColeta: DateTime.parse(json['dataColeta']),
      statusColeta: json['statusColeta'],
      estabelecimento: json['estabelecimento'] != null
          ? Estabelecimento.fromJson(json['estabelecimento'])
          : null,
    );
  }
}