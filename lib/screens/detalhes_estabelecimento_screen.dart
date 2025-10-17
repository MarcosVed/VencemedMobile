import 'package:flutter/material.dart';
import '../models/estabelecimento.dart';
import '../models/avaliacao.dart';
import '../services/avaliacao_service.dart';
import '../services/favorito_service.dart';

class DetalhesEstabelecimentoScreen extends StatefulWidget {
  final Estabelecimento estabelecimento;

  const DetalhesEstabelecimentoScreen({
    super.key,
    required this.estabelecimento,
  });

  @override
  State<DetalhesEstabelecimentoScreen> createState() => _DetalhesEstabelecimentoScreenState();
}

class _DetalhesEstabelecimentoScreenState extends State<DetalhesEstabelecimentoScreen> {
  List<Avaliacao> _avaliacoes = [];
  double _mediaAvaliacoes = 0.0;
  int _notaSelecionada = 0;
  final TextEditingController _comentarioController = TextEditingController();
  bool _isLoading = false;
  Avaliacao? _minhaAvaliacao;
  bool _isFavorito = false;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    await _carregarAvaliacoes();
    await _carregarMinhaAvaliacao();
    await _verificarFavorito();
  }

  Future<void> _verificarFavorito() async {
    final isFavorito = await FavoritoService.isFavorito(widget.estabelecimento.id);
    setState(() {
      _isFavorito = isFavorito;
    });
  }

  Future<void> _toggleFavorito() async {
    bool sucesso;
    
    if (_isFavorito) {
      sucesso = await FavoritoService.removerFavorito(widget.estabelecimento.id);
      if (sucesso) {
        setState(() => _isFavorito = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Favorito removido!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao remover favorito')),
        );
      }
    } else {
      sucesso = await FavoritoService.adicionarFavorito(widget.estabelecimento.id);
      if (sucesso) {
        setState(() => _isFavorito = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Estabelecimento favoritado!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao favoritar estabelecimento')),
        );
      }
    }
  }

  Future<void> _carregarMinhaAvaliacao() async {
    final avaliacao = await AvaliacaoService.buscarAvaliacaoUsuario(widget.estabelecimento.id);
    setState(() {
      _minhaAvaliacao = avaliacao;
      if (avaliacao != null) {
        _notaSelecionada = avaliacao.nota;
        _comentarioController.text = avaliacao.comentario ?? '';
      }
    });
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  Future<void> _carregarAvaliacoes() async {
    final avaliacoes = await AvaliacaoService.listarPorEstabelecimento(widget.estabelecimento.id);
    setState(() {
      _avaliacoes = avaliacoes;
      _mediaAvaliacoes = AvaliacaoService.calcularMediaAvaliacoes(avaliacoes);
    });
  }

  Future<void> _enviarAvaliacao() async {
    if (_notaSelecionada == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma nota')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final sucesso = await AvaliacaoService.salvarAvaliacao(
      widget.estabelecimento.id,
      _notaSelecionada,
      _comentarioController.text.trim().isEmpty ? null : _comentarioController.text.trim(),
      avaliacaoId: _minhaAvaliacao?.id,
    );

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_minhaAvaliacao == null ? 'Avaliação enviada com sucesso!' : 'Avaliação atualizada com sucesso!')),
      );
      await _carregarDados();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao enviar avaliação')),
      );
    }

    setState(() => _isLoading = false);
  }

  Widget _buildStarRating(double rating, {double size = 20}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor() ? Icons.star : (index < rating ? Icons.star_half : Icons.star_border),
          color: Colors.amber,
          size: size,
        );
      }),
    );
  }

  Widget _buildInteractiveStarRating() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () => setState(() => _notaSelecionada = index + 1),
          child: Icon(
            index < _notaSelecionada ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 30,
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.estabelecimento.nome),
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
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color.fromRGBO(58, 110, 183, 1),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 200,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              widget.estabelecimento.tipo == 'FARMACIA' 
                                ? Icons.local_pharmacy 
                                : Icons.store,
                              color: Colors.green,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.estabelecimento.nome,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _toggleFavorito,
                              icon: Icon(
                                _isFavorito ? Icons.favorite : Icons.favorite_border,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (widget.estabelecimento.fotoEst != null)
                          Container(
                            width: double.infinity,
                            height: 200,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                Uri.parse(widget.estabelecimento.fotoEst!).data!.contentAsBytes(),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.white.withOpacity(0.1),
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Colors.white,
                                        size: 50,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        _buildInfoRow('Informações', widget.estabelecimento.info),
                        _buildInfoRow('CEP', widget.estabelecimento.cep),
                        _buildInfoRow('Número', widget.estabelecimento.numero),
                        if (widget.estabelecimento.complemento != null)
                          _buildInfoRow('Complemento', widget.estabelecimento.complemento!),
                        _buildInfoRow('Telefone', widget.estabelecimento.telefone),
                        _buildInfoRow('Tipo', widget.estabelecimento.tipo),
                        _buildInfoRow('Coleta', widget.estabelecimento.coleta),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildStarRating(_mediaAvaliacoes, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              '${_mediaAvaliacoes.toStringAsFixed(1)} (${_avaliacoes.length} avaliações)',
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_avaliacoes.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.white.withOpacity(0.2),
                        border: Border.all(color: Colors.white),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Avaliações dos Usuários',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ..._avaliacoes.map((avaliacao) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white.withOpacity(0.1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      avaliacao.nomeUsuario,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildStarRating(avaliacao.nota.toDouble(), size: 16),
                                  ],
                                ),
                                if (avaliacao.comentario != null && avaliacao.comentario!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      avaliacao.comentario!,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                              ],
                            ),
                          )).toList(),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _minhaAvaliacao == null ? 'Avaliar Estabelecimento' : 'Editar Minha Avaliação',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInteractiveStarRating(),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _comentarioController,
                          decoration: const InputDecoration(
                            hintText: 'Comentário (opcional)',
                            hintStyle: TextStyle(color: Colors.white70),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _enviarAvaliacao,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(_minhaAvaliacao == null ? 'Enviar Avaliação' : 'Atualizar Avaliação'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, widget.estabelecimento);
                      },
                      child: const Text('Selecionar Este Local'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}