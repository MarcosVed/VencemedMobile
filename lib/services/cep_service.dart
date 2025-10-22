import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class CepService {
  static Future<Map<String, dynamic>?> buscarCep(String cep) async {
    try {
      // Limpar CEP removendo espaços e caracteres especiais
      final cepLimpo = cep.replaceAll(RegExp(r'[^0-9]'), '');
      
      final response = await http.get(
        Uri.parse('https://viacep.com.br/ws/$cepLimpo/json/'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['erro'] == null) {
          // Buscar coordenadas usando geocoding com endereço completo
          final coordenadas = await _buscarCoordenadas(
            data['logradouro'] ?? '',
            data['bairro'] ?? '',
            data['localidade'] ?? '',
            data['uf'] ?? '',
          );
          
          return {
            'cep': data['cep'],
            'logradouro': data['logradouro'],
            'bairro': data['bairro'],
            'localidade': data['localidade'],
            'uf': data['uf'],
            'latitude': coordenadas['latitude'],
            'longitude': coordenadas['longitude'],
          };
        }
      }
    } catch (e) {
      print('Erro ao buscar CEP: $e');
    }
    return null;
  }

  static Future<Map<String, double>> _buscarCoordenadas(
    String logradouro,
    String bairro,
    String cidade,
    String uf,
  ) async {
    try {
      // Construir endereço completo para geocoding
      final endereco = [logradouro, bairro, cidade, uf]
          .where((part) => part.isNotEmpty)
          .join(', ');
      
      final encodedAddress = Uri.encodeComponent(endereco);
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/search?format=json&q=$encodedAddress&limit=1'),
        headers: {'User-Agent': 'VencemedApp/1.0'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        if (results.isNotEmpty) {
          final result = results[0];
          return {
            'latitude': double.parse(result['lat']),
            'longitude': double.parse(result['lon']),
          };
        }
      }
    } catch (e) {
      print('Erro no geocoding: $e');
    }
    
    // Fallback: coordenadas aproximadas de São Paulo
    return {
      'latitude': -23.5505 + (Random().nextDouble() - 0.5) * 0.1,
      'longitude': -46.6333 + (Random().nextDouble() - 0.5) * 0.1,
    };
  }

  static double calcularDistancia(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Raio da Terra em km
    
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);
    
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  static double _toRadians(double degree) {
    return degree * (pi / 180);
  }

  static Future<Map<String, double>?> buscarCoordenadasEstabelecimento(
    String logradouro,
    String bairro,
    String cidade,
    String uf,
  ) async {
    return await _buscarCoordenadas(logradouro, bairro, cidade, uf);
  }
}