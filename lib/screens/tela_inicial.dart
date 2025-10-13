import 'package:flutter/material.dart';
import 'agendamento_screen.dart';
import 'perfil_screen.dart';
import '../models/coleta.dart';
import '../services/coleta_service.dart';
import '../services/coleta_backend_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ArchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 30,
      size.width,
      size.height - 30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final nome = prefs.getString('nome');

    print('Usuário logado: $nome ($email)');
  }

  Future<List<Coleta>> _getColetas() async {
    final coletasBackend = await ColetaBackendService.listarMinhasColetas();
    if (coletasBackend.isNotEmpty) {
      return coletasBackend;
    }
    return await ColetaService().getColetas();
  }

  Widget _buildColetasList() {
    return FutureBuilder<List<Coleta>>(
      future: _getColetas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }
        
        final coletas = snapshot.data ?? [];
        
        if (coletas.isEmpty) {
          return const Center(
            child: Text(
              'Nenhuma coleta encontrada',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return ListView.builder(
          itemCount: coletas.length,
          itemBuilder: (context, index) {
            final coleta = coletas[index];
            return _buildColetaCard(coleta);
          },
        );
      },
    );
  }

  Widget _buildColetaCard(Coleta coleta) {
    Color statusColor;
    IconData statusIcon;

    switch (coleta.statusColeta) {
      case 'ATIVO':
        statusColor = Colors.green;
        statusIcon = Icons.schedule;
        break;
      case 'COLETADO':
        statusColor = Colors.blue;
        statusIcon = Icons.check_circle;
        break;
      case 'INATIVO':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

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
                    coleta.info,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        coleta.statusColeta,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tipo: ${coleta.tipoMedicamento} - ${coleta.tipoColeta}',
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              'Data: ${coleta.dataColeta.day}/${coleta.dataColeta.month}/${coleta.dataColeta.year}',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

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
        decoration: const BoxDecoration(color: Color.fromRGBO(58, 110, 183, 1)),
        child: Column(
          children: [
            ClipPath(
              clipper: ArchClipper(),
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/image.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AgendamentoScreen(),
                            ),
                          );
                          setState(() {});
                        },
                        child: const Text('Agendar Coleta'),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Suas Coletas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(child: _buildColetasList()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
