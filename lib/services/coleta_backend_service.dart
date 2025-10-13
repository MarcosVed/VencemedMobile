import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/coleta.dart';

class ColetaBackendService {
  static const String baseUrl = 'http://localhost:8080';

  static Future<bool> agendarColeta(Coleta coleta) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      
      if (userId == null) return false;

      final coletaData = {
        'info': coleta.info,
        'cep': coleta.cep,
        'numero': coleta.numero,
        'complemento': coleta.complemento,
        'telefone': coleta.telefone,
        'tipoMedicamento': coleta.tipoMedicamento,
        'tipoColeta': coleta.tipoColeta,
        'dataColeta': coleta.dataColeta.toIso8601String(),
        'usuario': {'id': userId},
        'estabelecimento': coleta.estabelecimento != null 
            ? {'id': coleta.estabelecimento!.id}
            : null,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/coletas/agendar'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(coletaData),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao agendar coleta: $e');
      return false;
    }
  }

  static Future<List<Coleta>> listarMinhasColetas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      
      if (userId == null) {
        print('UserId não encontrado no SharedPreferences');
        return [];
      }

      print('Buscando coletas para usuário ID: $userId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/coletas/minhas?usuarioId=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Status da resposta: ${response.statusCode}');
      print('Corpo da resposta: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final coletas = data.map((json) => Coleta.fromJson(json)).toList();
        print('Coletas encontradas: ${coletas.length}');
        return coletas;
      }
    } catch (e) {
      print('Erro ao listar coletas: $e');
    }
    return [];
  }

  static Future<bool> atualizarColeta(int id, Coleta coleta) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      
      if (userId == null) return false;

      final coletaData = {
        'info': coleta.info,
        'cep': coleta.cep,
        'numero': coleta.numero,
        'complemento': coleta.complemento,
        'telefone': coleta.telefone,
        'tipoMedicamento': coleta.tipoMedicamento,
        'tipoColeta': coleta.tipoColeta,
        'dataColeta': coleta.dataColeta.toIso8601String(),
        'statusColeta': coleta.statusColeta,
        'usuario': {'id': userId},
        'estabelecimento': coleta.estabelecimento != null 
            ? {'id': coleta.estabelecimento!.id}
            : null,
      };

      final response = await http.put(
        Uri.parse('$baseUrl/coletas/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(coletaData),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao atualizar coleta: $e');
      return false;
    }
  }

  static Future<bool> deletarColeta(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/coletas/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Erro ao deletar coleta: $e');
      return false;
    }
  }
}