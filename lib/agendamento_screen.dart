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
    if (_infoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha as informações')),
      );
      return;
    }
    if (_cepController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha o CEP')),
      );
      return;
    }
    if (_numeroController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha o número')),
      );
      return;
    }
    if (_telefoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha o telefone')),
      );
      return;
    }
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
          color: Color.fromRGBO(58, 110, 183, 1),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _infoController,
                      decoration: InputDecoration(
                        labelText: 'Informações',
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
                      ),
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _cepController,
                      decoration: InputDecoration(
                        labelText: 'CEP',
                        labelStyle: const TextStyle(color: Colors.white),
                        counterStyle: const TextStyle(color: Colors.white),
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
                      ),
                      style: const TextStyle(color: Colors.white),
                      maxLength: 8,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _numeroController,
                      decoration: InputDecoration(
                        labelText: 'Número',
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
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _complementoController,
                      decoration: InputDecoration(
                        labelText: 'Complemento',
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
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _telefoneController,
                      decoration: InputDecoration(
                        labelText: 'Telefone',
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
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _tipoMedicamento,
                      decoration: InputDecoration(
                        labelText: 'Tipo de Medicamento',
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
                      ),
                      style: const TextStyle(color: Colors.white),
                      iconEnabledColor: Colors.white,
                      dropdownColor: const Color.fromRGBO(58, 110, 183, 1),
                      items: const [
                        DropdownMenuItem(value: 'COMPRIMIDO', child: Text('Comprimido', style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 'SERINGA', child: Text('Seringa', style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 'VARIOS', child: Text('Vários', style: TextStyle(color: Colors.white))),
                      ],
                      onChanged: (value) => setState(() => _tipoMedicamento = value!),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _tipoColeta,
                      decoration: InputDecoration(
                        labelText: 'Tipo de Coleta',
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
                      ),
                      style: const TextStyle(color: Colors.white),
                      iconEnabledColor: Colors.white,
                      dropdownColor: const Color.fromRGBO(58, 110, 183, 1),
                      items: const [
                        DropdownMenuItem(value: 'RETIRADA', child: Text('Retirada', style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 'ENTREGA', child: Text('Entrega', style: TextStyle(color: Colors.white))),
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
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _estabelecimentoSelecionado?.nome ?? 'Selecionar Local de Descarte',
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, color: Colors.white),
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