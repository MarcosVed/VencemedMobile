import '../models/coleta.dart';

class ColetaService {
  static final ColetaService _instance = ColetaService._internal();
  factory ColetaService() => _instance;
  ColetaService._internal();

  final List<Coleta> _coletas = [];
  int _nextId = 1;

  List<Coleta> getColetas() => List.from(_coletas);

  void adicionarColeta(Coleta coleta) {
    _coletas.add(coleta);
  }

  int getNextId() => _nextId++;
}