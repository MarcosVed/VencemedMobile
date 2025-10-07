import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'models/estabelecimento.dart';
import 'detalhes_estabelecimento_screen.dart';
import 'services/cep_service.dart';

class SelecaoEstabelecimentoScreen extends StatefulWidget {
  const SelecaoEstabelecimentoScreen({super.key});

  @override
  State<SelecaoEstabelecimentoScreen> createState() => _SelecaoEstabelecimentoScreenState();
}

class _SelecaoEstabelecimentoScreenState extends State<SelecaoEstabelecimentoScreen> {
  final TextEditingController _cepController = TextEditingController();
  final MapController _mapController = MapController();
  LatLng _currentLocation = const LatLng(-23.5505, -46.6333);
  List<Estabelecimento> _estabelecimentosProximos = [];
  bool _isLoading = false;

  List<Estabelecimento> _getTodosEstabelecimentos() {
    return [
      Estabelecimento(
        id: 1,
        nome: 'Drogasil',
        endereco: 'Rua das Flores, 123 - Centro',
        telefone: '(11) 3333-4444',
        tipo: 'FARMACIA',
        descricao: 'Farmácia com amplo horário de funcionamento. Especializada em descarte seguro de medicamentos vencidos e seringas.',
        foto: 'assets/images/logo.jpg',
        latitude: -23.5505,
        longitude: -46.6333,
        logradouro: 'Rua das Flores, 123',
        bairro: 'Centro',
        cidade: 'São Paulo',
        cep: '01310-100',
      ),
      Estabelecimento(
        id: 2,
        nome: 'Drogaria Miro',
        endereco: 'Av. Principal, 456 - Vila Nova',
        telefone: '(11) 5555-6666',
        tipo: 'FARMACIA',
        descricao: 'Drogaria familiar com atendimento personalizado. Aceita todos os tipos de medicamentos para descarte responsável.',
        foto: 'assets/images/f.png',
        latitude: -23.5525,
        longitude: -46.6353,
        logradouro: 'Av. Principal, 456',
        bairro: 'Vila Nova',
        cidade: 'São Paulo',
        cep: '04567-890',
      ),
      Estabelecimento(
        id: 3,
        nome: 'Farmácia Popular',
        endereco: 'Rua do Comércio, 789 - Jardim',
        telefone: '(11) 7777-8888',
        tipo: 'FARMACIA',
        descricao: 'Farmácia popular com preços acessíveis. Programa de descarte gratuito de medicamentos para a comunidade.',
        latitude: -23.5485,
        longitude: -46.6313,
        logradouro: 'Rua do Comércio, 789',
        bairro: 'Jardim',
        cidade: 'São Paulo',
        cep: '02345-678',
      ),
      Estabelecimento(
        id: 4,
        nome: 'Centro de Descarte Municipal',
        endereco: 'Av. Ambiental, 321 - Industrial',
        telefone: '(11) 9999-0000',
        tipo: 'ESTABELECIMENTO',
        descricao: 'Centro oficial da prefeitura para descarte de medicamentos. Funcionamento de segunda a sexta, das 8h às 17h.',
        latitude: -23.5545,
        longitude: -46.6373,
        logradouro: 'Av. Ambiental, 321',
        bairro: 'Industrial',
        cidade: 'São Paulo',
        cep: '08765-432',
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _estabelecimentosProximos = _getTodosEstabelecimentos();
  }

  Future<void> _buscarPorCep() async {
    if (_cepController.text.length != 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um CEP válido com 8 dígitos')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final cepData = await CepService.buscarCep(_cepController.text);
    
    if (cepData != null) {
      final newLocation = LatLng(cepData['latitude'], cepData['longitude']);
      setState(() {
        _currentLocation = newLocation;
        _estabelecimentosProximos = _calcularEstabelecimentosProximos(newLocation);
      });
      _mapController.move(newLocation, 14.0);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CEP não encontrado')),
      );
    }

    setState(() => _isLoading = false);
  }

  List<Estabelecimento> _calcularEstabelecimentosProximos(LatLng location) {
    final estabelecimentos = _getTodosEstabelecimentos();
    
    estabelecimentos.sort((a, b) {
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
    
    return estabelecimentos;
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
                      decoration: const InputDecoration(
                        labelText: 'Digite seu CEP',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        counterText: '',
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 9),
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
                        ..._estabelecimentosProximos
                            .where((e) => e.latitude != null && e.longitude != null)
                            .map((estabelecimento) => Marker(
                              point: LatLng(estabelecimento.latitude!, estabelecimento.longitude!),
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context, estabelecimento),
                                child: Icon(
                                  estabelecimento.tipo == 'FARMACIA'
                                      ? Icons.local_pharmacy
                                      : Icons.business,
                                  color: Colors.green,
                                  size: 30,
                                ),
                              ),
                            )).toList(),
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
                            : Icons.business,
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