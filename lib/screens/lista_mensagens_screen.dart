import 'package:flutter/material.dart';
import '../models/mensagem.dart';
import '../services/mensagem_service.dart';
import 'mensagens_screen.dart';

class ListaMensagensScreen extends StatefulWidget {
  const ListaMensagensScreen({super.key});

  @override
  State<ListaMensagensScreen> createState() => _ListaMensagensScreenState();
}

class _ListaMensagensScreenState extends State<ListaMensagensScreen> {
  Future<List<Mensagem>> _getMensagens() async {
    return await MensagemService.listarMinhasMensagens();
  }

  Future<void> _deletarMensagem(Mensagem mensagem) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Mensagem'),
        content: const Text('Tem certeza que deseja deletar esta mensagem?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sim'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final sucesso = await MensagemService.deletarMensagem(mensagem.id);
      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mensagem deletada com sucesso!')),
        );
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao deletar mensagem')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Mensagens'),
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
            Expanded(
              child: FutureBuilder<List<Mensagem>>(
                future: _getMensagens(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }
                  
                  final mensagens = snapshot.data ?? [];
                  
                  if (mensagens.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhuma mensagem encontrada',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: mensagens.length,
                    itemBuilder: (context, index) {
                      final mensagem = mensagens[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      mensagem.texto,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: mensagem.statusMensagem == 'ATIVO'
                                              ? Colors.green.withOpacity(0.2)
                                              : Colors.blue.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          mensagem.statusMensagem,
                                          style: TextStyle(
                                            color: mensagem.statusMensagem == 'ATIVO'
                                                ? Colors.green
                                                : Colors.blue,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      if (mensagem.statusMensagem == 'ATIVO')
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _deletarMensagem(mensagem),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                mensagem.texto,
                                style: const TextStyle(color: Colors.white),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${mensagem.dataMensagem.day}/${mensagem.dataMensagem.month}/${mensagem.dataMensagem.year}',
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MensagensScreen(),
                      ),
                    );
                    setState(() {});
                  },
                  child: const Text('Enviar Nova Mensagem'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}