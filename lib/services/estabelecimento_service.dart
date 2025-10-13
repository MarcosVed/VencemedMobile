import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/estabelecimento.dart';
import 'cep_service.dart';

class EstabelecimentoService {
  static const String baseUrl = 'http://localhost:8080'; // Para web browser

  static Future<List<Estabelecimento>> buscarPorCep(String cep) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/estabelecimento/buscarPorCep/$cep'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<Estabelecimento> estabelecimentos = data
            .map((json) => Estabelecimento.fromJson(json))
            .where((e) => e.statusEstabelecimento == 'ATIVO')
            .toList();

        return await _adicionarCoordenadas(estabelecimentos);
      }
    } catch (e) {
      print('Erro ao buscar por CEP: $e');
    }
    return [];
  }

  static Future<List<Estabelecimento>> listarTodos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/estabelecimento/publico'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<Estabelecimento> estabelecimentos = data
            .map((json) => Estabelecimento.fromJson(json))
            .where((e) => e.statusEstabelecimento == 'ATIVO')
            .toList();
        
        return await _adicionarCoordenadas(estabelecimentos);
      }
    } catch (e) {
      print('Erro ao conectar ao backend: $e');
    }
    return [];
  }



  static Future<List<Estabelecimento>> _adicionarCoordenadas(List<Estabelecimento> estabelecimentos) async {
    for (int i = 0; i < estabelecimentos.length; i++) {
      final estabelecimento = estabelecimentos[i];
      final cepData = await CepService.buscarCep(estabelecimento.cep);
      if (cepData != null) {
        estabelecimentos[i] = Estabelecimento(
          id: estabelecimento.id,
          nome: estabelecimento.nome,
          info: estabelecimento.info,
          cep: estabelecimento.cep,
          numero: estabelecimento.numero,
          complemento: estabelecimento.complemento,
          telefone: estabelecimento.telefone,
          tipo: estabelecimento.tipo,
          coleta: estabelecimento.coleta,
          statusEstabelecimento: estabelecimento.statusEstabelecimento,
          latitude: cepData['latitude'],
          longitude: cepData['longitude'],
        );
      }
    }
    return estabelecimentos;
  }
}