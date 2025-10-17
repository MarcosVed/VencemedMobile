import 'estabelecimento.dart';

class Favorito {
  final int id;
  final int usuarioId;
  final Estabelecimento estabelecimento;
  final DateTime dataFavoritado;

  Favorito({
    required this.id,
    required this.usuarioId,
    required this.estabelecimento,
    required this.dataFavoritado,
  });

  factory Favorito.fromJson(Map<String, dynamic> json) {
    return Favorito(
      id: json['id'],
      usuarioId: json['usuario']['id'],
      estabelecimento: Estabelecimento.fromJson(json['estabelecimento']),
      dataFavoritado: DateTime.parse(json['dataFavoritado']),
    );
  }
}