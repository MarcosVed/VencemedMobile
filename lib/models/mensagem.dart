class Mensagem {
  final int id;
  final String emissor;
  final String email;
  final String? telefone;
  final String texto;
  final DateTime dataMensagem;
  final String statusMensagem;

  Mensagem({
    required this.id,
    required this.emissor,
    required this.email,
    this.telefone,
    required this.texto,
    required this.dataMensagem,
    required this.statusMensagem,
  });

  factory Mensagem.fromJson(Map<String, dynamic> json) {
    return Mensagem(
      id: json['id'],
      emissor: json['emissor'],
      email: json['email'],
      telefone: json['telefone'],
      texto: json['texto'],
      dataMensagem: DateTime.parse(json['dataMensagem']),
      statusMensagem: json['statusMensagem'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emissor': emissor,
      'email': email,
      'telefone': telefone,
      'texto': texto,
    };
  }
}