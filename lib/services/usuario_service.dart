import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UsuarioService {
  static const String baseUrl = 'http://localhost:8080';

  static Future<bool> alterarSenha(String novaSenha) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      
      if (userId == null) return false;

      final uri = Uri.parse('$baseUrl/usuario/alterarSenha/$userId').replace(
        queryParameters: {'novaSenha': novaSenha},
      );

      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao alterar senha: $e');
      return false;
    }
  }

  static Future<bool> atualizarNome(String novoNome) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      
      if (userId == null) return false;

      final uri = Uri.parse('$baseUrl/usuario/alterarNome/$userId').replace(
        queryParameters: {'novoNome': novoNome},
      );

      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Atualizar SharedPreferences
        await prefs.setString('nome', novoNome);
        return true;
      }
    } catch (e) {
      print('Erro ao atualizar nome: $e');
    }
    return false;
  }
}