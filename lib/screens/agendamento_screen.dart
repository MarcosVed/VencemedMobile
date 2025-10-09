import 'package:flutter/material.dart';
import 'selecao_estabelecimento_screen.dart';
import '../models/estabelecimento.dart';
import '../models/coleta.dart';
import '../services/coleta_service.dart';

class AgendamentoScreen extends StatefulWidget {
  const AgendamentoScreen({super.key});

  @override
  State<AgendamentoScreen> createState() => _AgendamentoScreenState();
}

class _AgendamentoScreenState extends State<AgendamentoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _infoController = TextEditingController();
  final _cepController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _telefoneController = TextEditingController();
  
  String _tipoMedicamento = 'COMPRIMIDO';
  String _tipoColeta = 'RETIRADA';
  Estabelecimento? _estabelecimentoSelecionado;

  @override
  void dispose() {
    _infoController.dispose();
    _cepController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  void _agendar() {
    if (!_formKey.currentState!.validate()) return;
    if (_estabelecimentoSelecionado == null) {
      _showSnackBar('Selecione um local de descarte');
      return;
    }
    
    final coleta = Coleta(
      id: ColetaService().getNextId(),
      info: _infoController.text.trim(),
      cep: _cepController.text.trim(),
      numero: _numeroController.text.trim(),
      complemento: _complementoController.text.trim(),
      telefone: _telefoneController.text.trim(),
      tipoMedicamento: _tipoMedicamento,
      tipoColeta: _tipoColeta,
      dataColeta: DateTime.now().add(const Duration(days: 1)),
      usuarioId: 1,
      estabelecimentoId: _estabelecimentoSelecionado!.id,
      statusColeta: 'ATIVO',
    );
    
    ColetaService().adicionarColeta(coleta);
    _showSnackBar('Coleta agendada com sucesso!');
    Navigator.pop(context);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
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
    );
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
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _infoController,
                        decoration: _buildInputDecoration('Informações'),
                        style: const TextStyle(color: Colors.white),
                        maxLines: 3,
                        validator: (value) => value?.trim().isEmpty == true ? 'Campo obrigatório' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _cepController,
                        decoration: _buildInputDecoration('CEP').copyWith(
                          counterStyle: const TextStyle(color: Colors.white),
                        ),
                        style: const TextStyle(color: Colors.white),
                        maxLength: 8,
                        validator: (value) => value?.trim().isEmpty == true ? 'Campo obrigatório' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _numeroController,
                        decoration: _buildInputDecoration('Número'),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) => value?.trim().isEmpty == true ? 'Campo obrigatório' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _complementoController,
                        decoration: _buildInputDecoration('Complemento'),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _telefoneController,
                        decoration: _buildInputDecoration('Telefone'),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) => value?.trim().isEmpty == true ? 'Campo obrigatório' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _tipoMedicamento,
                        decoration: _buildInputDecoration('Tipo de Medicamento'),
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
                        decoration: _buildInputDecoration('Tipo de Coleta'),
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
                                  style: const TextStyle(color: Colors.white),
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
      ),
    );
  }
}