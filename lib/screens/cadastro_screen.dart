import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'tela_inicial.dart';

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

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  String _formatPhone(String phone) {
    final numbers = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (numbers.length == 11) {
      return '(${numbers.substring(0, 2)}) ${numbers.substring(2, 7)}-${numbers.substring(7)}';
    }
    return phone;
  }

  Future<void> _cadastrar() async {
    if (_nomeController.text.trim().isEmpty) {
      _showError('Nome é obrigatório');
      return;
    }

    if (!_isValidEmail(_emailController.text)) {
      _showError('Digite um email válido (ex: usuario@gmail.com)');
      return;
    }

    if (_senhaController.text.length < 6) {
      _showError('Senha deve ter pelo menos 6 caracteres');
      return;
    }

    setState(() => _isLoading = true);

    final url = Uri.parse('http://localhost:8080/usuario/salvar');
 // use 10.0.2.2 para emulador Android
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': _nomeController.text.trim(),
        'email': _emailController.text.trim().toLowerCase(),
        'telefone': _formatPhone(_telefoneController.text),
        'senha': _senhaController.text,
        'nivelAcesso': 'USER',
        'statusUsuario': 'ATIVO'
      }),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _nomeController.text);
      await prefs.setString('userEmail', _emailController.text);
      await prefs.setInt('userId', responseData['id'] ?? 0);
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TelaInicial()),
      );
    } else if (response.statusCode == 409) {
      _showError('Email já cadastrado.');
    } else {
      _showError('Erro ao cadastrar: ${response.body}');
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fundo.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/f.png', height: 200),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Criar conta',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _nomeController,
                    decoration: _inputDecoration('Nome'),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration('Email'),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _telefoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                      _PhoneInputFormatter(),
                    ],
                    decoration: _inputDecoration('Telefone'),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _senhaController,
                    obscureText: _obscurePassword,
                    decoration: _inputDecoration('Senha').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white,
                        ),
                        onPressed: () => setState(() {
                          _obscurePassword = !_obscurePassword;
                        }),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _cadastrar,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Cadastrar'),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 50,
              left: 24,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
