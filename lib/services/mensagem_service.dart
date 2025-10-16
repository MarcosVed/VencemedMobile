import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mensagem.dart';

class MensagemService {
  static const String baseUrl = 'http://localhost:8080';

  static Future<List<Mensagem>> listarMinhasMensagens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email');
      
      if (email == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/mensagem/findByEmail/$email'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Mensagem.fromJson(json)).toList();
      }
    } catch (e) {
      print('Erro ao listar mensagens: $e');
    }
    return [];
  }

  static Future<bool> enviarMensagem(Mensagem mensagem) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mensagem/save'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(mensagem.toJson()),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Erro ao enviar mensagem: $e');
      return false;
    }
  }

  static Future<bool> deletarMensagem(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/mensagem/delete/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Erro ao deletar mensagem: $e');
      return false;
    }
  }
}