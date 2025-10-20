import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'selecao_estabelecimento_screen.dart';
import '../models/estabelecimento.dart';
import '../models/coleta.dart';
import '../services/coleta_service.dart';
import '../services/coleta_backend_service.dart';
import '../services/cep_service.dart';

class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (text.length <= 2) {
      return newValue.copyWith(text: text);
    } else if (text.length <= 7) {
      return newValue.copyWith(
        text: '(${text.substring(0, 2)}) ${text.substring(2)}',
        selection: TextSelection.collapsed(offset: text.length + 4),
      );
    } else if (text.length <= 11) {
      return newValue.copyWith(
        text: '(${text.substring(0, 2)}) ${text.substring(2, 7)}-${text.substring(7)}',
        selection: TextSelection.collapsed(offset: text.length + 6),
      );
    }
    
    return oldValue;
  }
}

class _CepInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (text.length <= 5) {
      return newValue.copyWith(text: text);
    } else if (text.length <= 8) {
      return newValue.copyWith(
        text: '${text.substring(0, 5)}-${text.substring(5)}',
        selection: TextSelection.collapsed(offset: text.length + 1),
      );
    }
    
    return oldValue;
  }
}

class AgendamentoScreen extends StatefulWidget {
  final Estabelecimento? estabelecimentoSelecionado;

  const AgendamentoScreen({super.key, this.estabelecimentoSelecionado});

  @override
  State<AgendamentoScreen> createState() => _AgendamentoScreenState();
}

class _AgendamentoScreenState extends State<AgendamentoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final TextEditingController _infoController = TextEditingController();
  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _bairroController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _estadoController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _complementoController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();

  // Estado
  String _tipoMedicamento = 'COMPRIMIDO';
  String _tipoColeta = 'RETIRADA';
  Estabelecimento? _estabelecimentoSelecionado;
  DateTime? _dataRetiradaSelecionada;
  bool _isValidatingCep = false;

  @override
  void initState() {
    super.initState();
    if (widget.estabelecimentoSelecionado != null) {
      _estabelecimentoSelecionado = widget.estabelecimentoSelecionado;
    }
  }

  @override
  void dispose() {
    _infoController.dispose();
    _cepController.dispose();
    _enderecoController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  Future<void> _validarCep(String cep) async {
    final cepNumeros = cep.replaceAll('-', '');
    if (cepNumeros.length != 8) return;

    setState(() => _isValidatingCep = true);

    try {
      final data = await CepService.buscarCep(cepNumeros);
      
      if (data != null && mounted) {
        setState(() {
          _enderecoController.text = data['logradouro'] ?? '';
          _bairroController.text = data['bairro'] ?? '';
          _cidadeController.text = data['localidade'] ?? '';
          _estadoController.text = data['uf'] ?? '';
        });
      } else if (mounted) {
        _showSnackBar('CEP não encontrado');
        _limparCamposEndereco();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erro ao buscar CEP');
        _limparCamposEndereco();
      }
    } finally {
      if (mounted) {
        setState(() => _isValidatingCep = false);
      }
    }
  }

  void _limparCamposEndereco() {
    _enderecoController.text = '';
    _bairroController.text = '';
    _cidadeController.text = '';
    _estadoController.text = '';
  }

  void _showSnackBar(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  void _agendar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_estabelecimentoSelecionado == null) {
      _showSnackBar('Selecione um local de descarte');
      return;
    }
    if (_tipoColeta == 'RETIRADA' && _dataRetiradaSelecionada == null) {
      _showSnackBar('Selecione a data de retirada');
      return;
    }
    
    final endereco = _enderecoController.text.trim();
    final bairro = _bairroController.text.trim();
    final cidade = _cidadeController.text.trim();
    final estado = _estadoController.text.trim();
    
    final enderecoCompleto = [endereco, bairro, cidade, estado]
        .where((part) => part.isNotEmpty)
        .join(', ');
    
    final enderecoFinal = enderecoCompleto.isEmpty 
        ? 'Endereço não informado'
        : (enderecoCompleto.length > 100 
            ? enderecoCompleto.substring(0, 100)
            : enderecoCompleto);
    
    final coleta = Coleta(
      id: 0,
      info: _infoController.text.trim(),
      cep: _cepController.text.trim(),
      endereco: enderecoFinal,
      numero: _numeroController.text.trim(),
      complemento: _complementoController.text.trim(),
      telefone: _telefoneController.text.trim(),
      tipoMedicamento: _tipoMedicamento,
      tipoColeta: _tipoColeta,
      dataColeta: _tipoColeta == 'RETIRADA' && _dataRetiradaSelecionada != null 
          ? _dataRetiradaSelecionada! 
          : DateTime.now().add(const Duration(days: 1)),
      statusColeta: 'ATIVO',
      estabelecimento: _estabelecimentoSelecionado,
    );
    
    final sucesso = await ColetaBackendService.agendarColeta(coleta);
    
    if (sucesso) {
      ColetaService().adicionarColeta(coleta);
      _showSnackBar('Coleta agendada com sucesso!');
    } else {
      _showSnackBar('Erro ao agendar coleta. Tente novamente.');
    }
    
    Navigator.pop(context);
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
                        decoration: _buildInputDecoration('Informações').copyWith(
                          counterStyle: const TextStyle(color: Colors.white),
                        ),
                        style: const TextStyle(color: Colors.white),
                        maxLines: 3,
                        maxLength: 200,
                        validator: (value) => value?.trim().isEmpty == true ? 'Campo obrigatório' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _cepController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(8),
                          _CepInputFormatter(),
                        ],
                        decoration: _buildInputDecoration('CEP').copyWith(
                          counterStyle: const TextStyle(color: Colors.white),
                          suffixIcon: _isValidatingCep
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                        style: const TextStyle(color: Colors.white),
                        maxLength: 9,
                        onChanged: (value) {
                          final cepNumeros = value.replaceAll('-', '');
                          if (cepNumeros.length == 8) {
                            _validarCep(value);
                          } else if (mounted) {
                            _limparCamposEndereco();
                          }
                        },
                        validator: (value) {
                          if (value?.trim().isEmpty == true) return 'Campo obrigatório';
                          final cepNumeros = value!.replaceAll('-', '');
                          if (cepNumeros.length != 8) return 'CEP deve ter 8 dígitos';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _enderecoController,
                        enabled: false,
                        decoration: _buildInputDecoration('Endereço').copyWith(
                          counterText: '',
                          hintText: 'Será preenchido automaticamente após inserir o CEP',
                          hintStyle: const TextStyle(color: Colors.white54),
                        ),
                        style: const TextStyle(color: Colors.white),
                        maxLength: 100,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _bairroController,
                        enabled: false,
                        decoration: _buildInputDecoration('Bairro').copyWith(
                          counterText: '',
                          hintText: 'Será preenchido automaticamente após inserir o CEP',
                          hintStyle: const TextStyle(color: Colors.white54),
                        ),
                        style: const TextStyle(color: Colors.white),
                        maxLength: 100,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _cidadeController,
                              enabled: false,
                              decoration: _buildInputDecoration('Cidade').copyWith(
                                counterText: '',
                                hintText: 'Preenchido automaticamente',
                                hintStyle: const TextStyle(color: Colors.white54),
                              ),
                              style: const TextStyle(color: Colors.white),
                              maxLength: 100,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _estadoController,
                              enabled: false,
                              decoration: _buildInputDecoration('Estado').copyWith(
                                counterText: '',
                                hintText: 'UF',
                                hintStyle: const TextStyle(color: Colors.white54),
                              ),
                              style: const TextStyle(color: Colors.white),
                              maxLength: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _numeroController,
                        decoration: _buildInputDecoration('Número').copyWith(
                          counterText: '',
                        ),
                        style: const TextStyle(color: Colors.white),
                        maxLength: 10,
                        validator: (value) => value?.trim().isEmpty == true ? 'Campo obrigatório' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _complementoController,
                        decoration: _buildInputDecoration('Complemento').copyWith(
                          counterText: '',
                        ),
                        style: const TextStyle(color: Colors.white),
                        maxLength: 40,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _telefoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                          _PhoneInputFormatter(),
                        ],
                        decoration: _buildInputDecoration('Telefone').copyWith(
                          counterText: '',
                        ),
                        style: const TextStyle(color: Colors.white),
                        maxLength: 15,
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
                        onChanged: (value) {
                          setState(() {
                            _tipoColeta = value!;
                            if (_tipoColeta != 'RETIRADA') {
                              _dataRetiradaSelecionada = null;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      if (_tipoColeta == 'RETIRADA')
                        GestureDetector(
                          onTap: () async {
                            final data = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now().add(const Duration(days: 1)),
                              firstDate: DateTime.now().add(const Duration(days: 1)),
                              lastDate: DateTime.now().add(const Duration(days: 30)),
                            );
                            if (data != null) {
                              setState(() => _dataRetiradaSelecionada = data);
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
                                    _dataRetiradaSelecionada != null
                                        ? 'Data: ${_dataRetiradaSelecionada!.day}/${_dataRetiradaSelecionada!.month}/${_dataRetiradaSelecionada!.year}'
                                        : 'Selecionar Data de Retirada',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                const Icon(Icons.calendar_today, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      if (_tipoColeta == 'RETIRADA')
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