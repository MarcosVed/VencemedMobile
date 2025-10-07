import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class CepService {
  static Future<Map<String, dynamic>?> buscarCep(String cep) async {
    try {
      final response = await http.get(
        Uri.parse('https://viacep.com.br/ws/$cep/json/'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['erro'] == null) {
          // Simular coordenadas baseadas no CEP (em produção, usar serviço de geocoding)
          final lat = -23.5505 + (Random().nextDouble() - 0.5) * 0.1;
          final lng = -46.6333 + (Random().nextDouble() - 0.5) * 0.1;
          
          return {
            'cep': data['cep'],
            'logradouro': data['logradouro'],
            'bairro': data['bairro'],
            'localidade': data['localidade'],
            'uf': data['uf'],
            'latitude': lat,
            'longitude': lng,
          };
        }
      }
    } catch (e) {
      print('Erro ao buscar CEP: $e');
    }
    return null;
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
}