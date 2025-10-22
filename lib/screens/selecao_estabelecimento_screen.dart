import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/estabelecimento.dart';
import 'detalhes_estabelecimento_screen.dart';
import '../services/cep_service.dart';
import '../services/estabelecimento_service.dart';
import '../services/favorito_service.dart';

class SelecaoEstabelecimentoScreen extends StatefulWidget {
  const SelecaoEstabelecimentoScreen({super.key});

  @override
  State<SelecaoEstabelecimentoScreen> createState() => _SelecaoEstabelecimentoScreenState();
}

class _SelecaoEstabelecimentoScreenState extends State<SelecaoEstabelecimentoScreen> {
  final TextEditingController _cepController = TextEditingController();
  final MapController _mapController = MapController();
  LatLng _currentLocation = const LatLng(-23.5124538,-46.8898006);
  List<Estabelecimento> _estabelecimentosProximos = [];
  bool _isLoading = false;
  Set<int> _favoritos = {};



  @override
  void initState() {
    super.initState();
    _estabelecimentosProximos = [];
    _carregarEstabelecimentos();
    _carregarFavoritos();
  }

  Future<void> _carregarEstabelecimentos() async {
    try {
      final estabelecimentos = await EstabelecimentoService.listarTodos();
      print('Estabelecimentos carregados: ${estabelecimentos.length}');
      for (final est in estabelecimentos) {
        print('${est.nome}: lat=${est.latitude}, lng=${est.longitude}');
      }
      if (mounted) {
        setState(() {
          _estabelecimentosProximos = estabelecimentos;
        });
      }
    } catch (e) {
      print('Erro ao carregar estabelecimentos: $e');
    }
  }

  Future<void> _carregarFavoritos() async {
    try {
      final estabelecimentos = await EstabelecimentoService.listarTodos();
      final favoritosSet = <int>{};
      
      for (final estabelecimento in estabelecimentos) {
        final isFavorito = await FavoritoService.isFavorito(estabelecimento.id);
        if (isFavorito) {
          favoritosSet.add(estabelecimento.id);
        }
      }
      
      if (mounted) {
        setState(() {
          _favoritos = favoritosSet;
        });
      }
    } catch (e) {
      // Silenciar erros para evitar loops
    }
  }

  Future<void> _buscarPorCep() async {
    final cep = _cepController.text.replaceAll('-', '');
    if (cep.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um CEP válido com 8 dígitos')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final cepData = await CepService.buscarCep(cep);
    
    if (cepData != null) {
      final newLocation = LatLng(cepData['latitude'], cepData['longitude']);
      
      // Buscar todos os estabelecimentos do BD
      final todosEstabelecimentos = await EstabelecimentoService.listarTodos();
      
      // Filtrar estabelecimentos próximos (raio de 10km)
      final estabelecimentosProximos = _filtrarEstabelecimentosProximos(newLocation, todosEstabelecimentos, 10.0);
      
      setState(() {
        _currentLocation = newLocation;
        _estabelecimentosProximos = estabelecimentosProximos;
      });
      _mapController.move(newLocation, 14.0);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${estabelecimentosProximos.length} estabelecimentos encontrados próximos')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CEP não encontrado')),
      );
    }

    setState(() => _isLoading = false);
  }

  List<Estabelecimento> _filtrarEstabelecimentosProximos(LatLng location, List<Estabelecimento> estabelecimentos, double raioKm) {
    final estabelecimentosProximos = estabelecimentos.where((estabelecimento) {
      if (estabelecimento.latitude == null || estabelecimento.longitude == null) return false;
      
      final distancia = CepService.calcularDistancia(
        location.latitude, location.longitude,
        estabelecimento.latitude!, estabelecimento.longitude!,
      );
      
      return distancia <= raioKm;
    }).toList();
    
    // Ordenar por distância
    estabelecimentosProximos.sort((a, b) {
      final distA = CepService.calcularDistancia(
        location.latitude, location.longitude,
        a.latitude!, a.longitude!,
      );
      final distB = CepService.calcularDistancia(
        location.latitude, location.longitude,
        b.latitude!, b.longitude!,
      );
      return distA.compareTo(distB);
    });
    
    return estabelecimentosProximos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolher Local de Descarte'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/fundo.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(58, 110, 183, 1),
        ),
        child: Column(
          children: [
            // Campo de busca por CEP
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _cepController,
                      keyboardType: TextInputType.number,
                      maxLength: 9,
                      decoration: InputDecoration(
                        labelText: 'Digite seu CEP',
                        labelStyle: const TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        counterText: '',
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _buscarPorCep,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                  ),
                ],
              ),
            ),
            // Mapa
            Container(
              height: 300,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentLocation,
                    initialZoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.vencemed',
                    ),
                    MarkerLayer(
                      markers: [
                        // Marcador da localização atual
                        Marker(
                          point: _currentLocation,
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.blue,
                            size: 30,
                          ),
                        ),
                        // Marcadores dos estabelecimentos
                        ...() {
                          final estabelecimentosComCoordenadas = _estabelecimentosProximos
                              .where((e) => e.latitude != null && e.longitude != null)
                              .toList();
                          print('Estabelecimentos com coordenadas: ${estabelecimentosComCoordenadas.length}');
                          return estabelecimentosComCoordenadas.map((estabelecimento) => Marker(
                            point: LatLng(estabelecimento.latitude!, estabelecimento.longitude!),
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context, estabelecimento),
                              child: Icon(
                                estabelecimento.tipo == 'FARMACIA'
                                    ? Icons.local_pharmacy
                                    : Icons.store,
                                color: Colors.green,
                                size: 30,
                              ),
                            ),
                          ));
                        }().toList(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Lista de estabelecimentos
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _estabelecimentosProximos.length,
                itemBuilder: (context, index) {
                  final estabelecimento = _estabelecimentosProximos[index];
                  final distancia = estabelecimento.latitude != null && estabelecimento.longitude != null
                      ? CepService.calcularDistancia(
                          _currentLocation.latitude,
                          _currentLocation.longitude,
                          estabelecimento.latitude!,
                          estabelecimento.longitude!,
                        )
                      : 0.0;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: Colors.transparent,
                    child: ListTile(
                      leading: Icon(
                        estabelecimento.tipo == 'FARMACIA'
                            ? Icons.local_pharmacy
                            : Icons.store,
                        color: Colors.green,
                        size: 32,
                      ),
                      title: Text(
                        estabelecimento.nome,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(estabelecimento.endereco, style: const TextStyle(color: Colors.white)),
                          Text(estabelecimento.telefone, style: const TextStyle(color: Colors.white)),
                          if (distancia > 0)
                            Text(
                              '${distancia.toStringAsFixed(1)} km de distância',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_favoritos.isNotEmpty && _favoritos.contains(estabelecimento.id))
                            const Icon(Icons.favorite, color: Colors.white, size: 24),
                          IconButton(
                            icon: const Icon(Icons.info_outline, color: Colors.white),
                            onPressed: () async {
                              final result = await Navigator.push<Estabelecimento>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetalhesEstabelecimentoScreen(
                                    estabelecimento: estabelecimento,
                                  ),
                                ),
                              );
                              if (result != null) {
                                Navigator.pop(context, result);
                              }
                            },
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white),
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(context, estabelecimento);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}