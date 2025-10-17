import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorito.dart';

class FavoritoService {
  static const String baseUrl = 'http://localhost:8080';

  static Future<bool> adicionarFavorito(int estabelecimentoId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      
      if (userId == null) return false;

      final uri = Uri.parse('$baseUrl/favoritos').replace(
        queryParameters: {
          'usuarioId': userId.toString(),
          'estabelecimentoId': estabelecimentoId.toString(),
        },
      );

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao adicionar favorito: $e');
      return false;
    }
  }

  static Future<List<Favorito>> listarFavoritos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      
      if (userId == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/favoritos/usuario/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Favorito.fromJson(json)).toList();
      }
    } catch (e) {
      print('Erro ao listar favoritos: $e');
    }
    return [];
  }

  static Future<bool> isFavorito(int estabelecimentoId) async {
    final favoritos = await listarFavoritos();
    return favoritos.any((favorito) => favorito.estabelecimento.id == estabelecimentoId);
  }

  static Future<bool> removerFavorito(int estabelecimentoId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      
      if (userId == null) return false;

      final uri = Uri.parse('$baseUrl/favoritos').replace(
        queryParameters: {
          'usuarioId': userId.toString(),
          'estabelecimentoId': estabelecimentoId.toString(),
        },
      );

      final response = await http.delete(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao remover favorito: $e');
      return false;
    }
  }
}