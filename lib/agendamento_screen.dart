import 'package:flutter/material.dart';
import 'selecao_estabelecimento_screen.dart';
import 'models/estabelecimento.dart';
import 'models/coleta.dart';
import 'services/coleta_service.dart';

class AgendamentoScreen extends StatefulWidget {
  const AgendamentoScreen({super.key});

  @override
  State<AgendamentoScreen> createState() => _AgendamentoScreenState();
}

class _AgendamentoScreenState extends State<AgendamentoScreen> {
  final _infoController = TextEditingController();
  final _cepController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _telefoneController = TextEditingController();
  
  String _tipoMedicamento = 'COMPRIMIDO';
  String _tipoColeta = 'RETIRADA';
  Estabelecimento? _estabelecimentoSelecionado;

  void _agendar() {
    if (_estabelecimentoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um local de descarte')),
      );
      return;
    }
    
    final coleta = Coleta(
      id: ColetaService().getNextId(),
      info: _infoController.text,
      cep: _cepController.text,
      numero: _numeroController.text,
      complemento: _complementoController.text,
      telefone: _telefoneController.text,
      tipoMedicamento: _tipoMedicamento,
      tipoColeta: _tipoColeta,
      dataColeta: DateTime.now().add(const Duration(days: 1)),
      usuarioId: 1,
      estabelecimentoId: _estabelecimentoSelecionado!.id,
      statusColeta: 'ATIVO',
    );
    
    ColetaService().adicionarColeta(coleta);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coleta agendada com sucesso!')),
    );
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar Coleta'),
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
          color: Color(0xFF334155),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _infoController,
                      decoration: const InputDecoration(
                        labelText: 'Informações',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _cepController,
                      decoration: const InputDecoration(
                        labelText: 'CEP',
                        border: OutlineInputBorder(),
                      ),
                      maxLength: 8,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _numeroController,
                      decoration: const InputDecoration(
                        labelText: 'Número',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _complementoController,
                      decoration: const InputDecoration(
                        labelText: 'Complemento',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _telefoneController,
                      decoration: const InputDecoration(
                        labelText: 'Telefone',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _tipoMedicamento,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Medicamento',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'COMPRIMIDO', child: Text('Comprimido')),
                        DropdownMenuItem(value: 'SERINGA', child: Text('Seringa')),
                        DropdownMenuItem(value: 'VARIOS', child: Text('Vários')),
                      ],
                      onChanged: (value) => setState(() => _tipoMedicamento = value!),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _tipoColeta,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Coleta',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'RETIRADA', child: Text('Retirada')),
                        DropdownMenuItem(value: 'ENTREGA', child: Text('Entrega')),
                      ],
                      onChanged: (value) => setState(() => _tipoColeta = value!),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final estabelecimento = await Navigator.push<Estabelecimento>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SelecaoEstabelecimentoScreen(),
                          ),
                        );
                        if (estabelecimento != null) {
                          setState(() => _estabelecimentoSelecionado = estabelecimento);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _estabelecimentoSelecionado?.nome ?? 'Selecionar Local de Descarte',
                                style: TextStyle(
                                  color: _estabelecimentoSelecionado != null 
                                    ? Colors.black 
                                    : Colors.grey[600],
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _agendar,
                        child: const Text('Agendar Coleta'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}