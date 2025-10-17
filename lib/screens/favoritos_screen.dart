import 'package:flutter/material.dart';
import '../models/favorito.dart';
import '../services/favorito_service.dart';
import 'agendamento_screen.dart';

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({super.key});

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  List<Favorito> _favoritos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarFavoritos();
  }

  Future<void> _carregarFavoritos() async {
    final favoritos = await FavoritoService.listarFavoritos();
    setState(() {
      _favoritos = favoritos;
      _isLoading = false;
    });
  }

  Future<void> _removerFavorito(int estabelecimentoId) async {
    final sucesso = await FavoritoService.removerFavorito(estabelecimentoId);
    
    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Favorito removido!')),
      );
      await _carregarFavoritos();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao remover favorito')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : _favoritos.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum estabelecimento favoritado',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _favoritos.length,
                    itemBuilder: (context, index) {
                      final favorito = _favoritos[index];
                      final estabelecimento = favorito.estabelecimento;

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
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  estabelecimento.nome,
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                              IconButton(
                                onPressed: () => _removerFavorito(estabelecimento.id),
                                icon: const Icon(
                                  Icons.favorite,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(estabelecimento.endereco, style: const TextStyle(color: Colors.white)),
                              Text(estabelecimento.telefone, style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AgendamentoScreen(
                                  estabelecimentoSelecionado: estabelecimento,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}