import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/avaliacao.dart';

class AvaliacaoService {
  static const String baseUrl = 'http://localhost:8080';

  static Future<Avaliacao?> buscarAvaliacaoUsuario(int estabelecimentoId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      
      if (userId == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/avaliacoes/usuario/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final avaliacoes = data.map((json) => Avaliacao.fromJson(json)).toList();
        
        try {
          return avaliacoes.firstWhere(
            (avaliacao) => avaliacao.estabelecimentoId == estabelecimentoId,
          );
        } catch (e) {
          return null;
        }
      }
    } catch (e) {
      print('Erro ao buscar avaliação do usuário: $e');
    }
    return null;
  }

  static Future<bool> salvarAvaliacao(int estabelecimentoId, int nota, String? comentario) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      
      if (userId == null) return false;

      final uri = Uri.parse('$baseUrl/avaliacoes').replace(
        queryParameters: {
          'usuarioId': userId.toString(),
          'estabelecimentoId': estabelecimentoId.toString(),
          'nota': nota.toString(),
          if (comentario != null && comentario.isNotEmpty) 'comentario': comentario,
        },
      );

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao salvar avaliação: $e');
      return false;
    }
  }

  static Future<List<Avaliacao>> listarPorEstabelecimento(int estabelecimentoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/avaliacoes/estabelecimento/$estabelecimentoId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Avaliacao.fromJson(json)).toList();
      }
    } catch (e) {
      print('Erro ao listar avaliações: $e');
    }
    return [];
  }

  static double calcularMediaAvaliacoes(List<Avaliacao> avaliacoes) {
    if (avaliacoes.isEmpty) return 0.0;
    final soma = avaliacoes.fold(0, (sum, avaliacao) => sum + avaliacao.nota);
    return soma / avaliacoes.length;
  }
}