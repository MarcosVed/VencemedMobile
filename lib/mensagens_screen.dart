import 'package:flutter/material.dart';


class MensagensScreen extends StatefulWidget {
  const MensagensScreen({super.key});

  @override
  State<MensagensScreen> createState() => _MensagensScreenState();
}

class _MensagensScreenState extends State<MensagensScreen> {
  final _emissorController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _textoController = TextEditingController();

  void _enviarMensagem() {
    // Futuramente será implementado
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mensagem enviada com sucesso!')),
    );
    
    _emissorController.clear();
    _emailController.clear();
    _telefoneController.clear();
    _textoController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensagens'),
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 200,
              ),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enviar Mensagem',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _emissorController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do Emissor',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _telefoneController,
                      decoration: const InputDecoration(
                        labelText: 'Telefone (Opcional)',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _textoController,
                      decoration: const InputDecoration(
                        labelText: 'Mensagem',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      maxLines: 5,
                      maxLength: 400,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _enviarMensagem,
                        child: const Text('Enviar Mensagem'),
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