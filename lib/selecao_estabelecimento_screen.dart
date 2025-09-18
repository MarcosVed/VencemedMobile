import 'package:flutter/material.dart';
import 'models/estabelecimento.dart';
import 'detalhes_estabelecimento_screen.dart';

class SelecaoEstabelecimentoScreen extends StatelessWidget {
  const SelecaoEstabelecimentoScreen({super.key});

  List<Estabelecimento> _getEstabelecimentos() {
    return [
      Estabelecimento(
        id: 1,
        nome: 'Drogasil',
        endereco: 'Rua das Flores, 123 - Centro',
        telefone: '(11) 3333-4444',
        tipo: 'FARMACIA',
        descricao: 'Farmácia com amplo horário de funcionamento. Especializada em descarte seguro de medicamentos vencidos e seringas.',
        foto: 'assets/images/logo.jpg',
      ),
      Estabelecimento(
        id: 2,
        nome: 'Drogaria Miro',
        endereco: 'Av. Principal, 456 - Vila Nova',
        telefone: '(11) 5555-6666',
        tipo: 'FARMACIA',
        descricao: 'Drogaria familiar com atendimento personalizado. Aceita todos os tipos de medicamentos para descarte responsável.',
        foto: 'assets/images/f.png',
      ),
      Estabelecimento(
        id: 3,
        nome: 'Farmácia Popular',
        endereco: 'Rua do Comércio, 789 - Jardim',
        telefone: '(11) 7777-8888',
        tipo: 'FARMACIA',
        descricao: 'Farmácia popular com preços acessíveis. Programa de descarte gratuito de medicamentos para a comunidade.',
      ),
      Estabelecimento(
        id: 4,
        nome: 'Centro de Descarte Municipal',
        endereco: 'Av. Ambiental, 321 - Industrial',
        telefone: '(11) 9999-0000',
        tipo: 'ESTABELECIMENTO',
        descricao: 'Centro oficial da prefeitura para descarte de medicamentos. Funcionamento de segunda a sexta, das 8h às 17h.',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final estabelecimentos = _getEstabelecimentos();

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
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: estabelecimentos.length,
          itemBuilder: (context, index) {
            final estabelecimento = estabelecimentos[index];
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
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.info_outline),
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
                    const Icon(Icons.arrow_forward_ios),
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
    );
  }
}