import 'package:flutter/material.dart';
import 'agendamento_screen.dart';
import 'perfil_screen.dart';

class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VenceMed'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/fundo.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            showDialog(
              context: context,
              barrierColor: Colors.transparent,
              builder: (context) => const PerfilScreen(),
            );
          },
          icon: const Icon(Icons.person),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF334155),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.jpg',
                  height: 150,
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AgendamentoScreen()),
                      );
                    },
                    child: const Text('Agendar Coleta'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}