import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/estabelecimento.dart';
import 'cep_service.dart';

class EstabelecimentoService {
  static const String baseUrl = 'http://localhost:8080';
  static const String baseUrlEmulator = 'http://10.0.2.2:8080';
  static String get apiUrl => baseUrl; // Use baseUrlEmulator para emulador Android

  static Future<List<Estabelecimento>> buscarPorCep(String cep) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/estabelecimento/buscarPorCep/$cep'),
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
      print('Buscando em: $apiUrl/estabelecimento/publico');
      final response = await http.get(
        Uri.parse('$apiUrl/estabelecimento/publico'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Status: ${response.statusCode}');
      print('Resposta: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<Estabelecimento> estabelecimentos = data
            .map((json) => Estabelecimento.fromJson(json))
            .toList();
        
        print('Total encontrado: ${estabelecimentos.length}');
        return await _adicionarCoordenadas(estabelecimentos);
      }
    } catch (e) {
      print('Erro: $e');
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

  static Future<Uint8List?> buscarImagemEstabelecimento(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/estabelecimento/imagem/$id'),
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (e) {
      print('Erro ao buscar imagem: $e');
    }
    return null;
  }
}