import '../models/coleta.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColetaService {
  static final ColetaService _instance = ColetaService._internal();
  factory ColetaService() => _instance;
  ColetaService._internal();

  final List<Coleta> _coletas = [];
  int _nextId = 1;

  Future<List<Coleta>> getColetas() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    
    if (userId == null) return [];
    
    // Retorna apenas coletas do usuário logado
    return _coletas.where((coleta) => coleta.id == userId || _coletas.isEmpty).toList();
  }
  
  List<Coleta> getColetasSync() => List.from(_coletas);

  void adicionarColeta(Coleta coleta) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    
    if (userId != null) {
      // Cria uma nova coleta com o ID do usuário correto
      final coletaComUsuario = Coleta(
        id: coleta.id,
        info: coleta.info,
        cep: coleta.cep,
        endereco: coleta.endereco,
        numero: coleta.numero,
        complemento: coleta.complemento,
        telefone: coleta.telefone,
        tipoMedicamento: coleta.tipoMedicamento,
        tipoColeta: coleta.tipoColeta,
        dataColeta: coleta.dataColeta,
        statusColeta: coleta.statusColeta,
        estabelecimento: coleta.estabelecimento,
      );
      _coletas.add(coletaComUsuario);
    }
  }

  int getNextId() => _nextId++;
}