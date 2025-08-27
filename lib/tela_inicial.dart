import 'package:flutter/material.dart';
import 'agendamento_screen.dart';
import 'perfil_screen.dart';
import 'models/coleta.dart';

class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

  List<Coleta> _getColetas() {
    return [
      Coleta(
        id: 1,
        info: 'Medicamentos vencidos',
        cep: '12345678',
        numero: '123',
        complemento: 'Apto 45',
        telefone: '11999999999',
        tipoMedicamento: 'COMPRIMIDO',
        tipoColeta: 'RETIRADA',
        dataColeta: DateTime.now().add(const Duration(days: 2)),
        usuarioId: 1,
        estabelecimentoId: 1,
        statusColeta: 'ATIVO',
      ),
      Coleta(
        id: 2,
        info: 'Seringas usadas',
        cep: '87654321',
        numero: '456',
        complemento: 'Casa',
        telefone: '11888888888',
        tipoMedicamento: 'SERINGA',
        tipoColeta: 'ENTREGA',
        dataColeta: DateTime.now().subtract(const Duration(days: 1)),
        usuarioId: 1,
        estabelecimentoId: 2,
        statusColeta: 'COLETADO',
      ),
      Coleta(
        id: 3,
        info: 'Medicamentos diversos',
        cep: '11223344',
        numero: '789',
        complemento: 'Bloco B',
        telefone: '11777777777',
        tipoMedicamento: 'VARIOS',
        tipoColeta: 'RETIRADA',
        dataColeta: DateTime.now().subtract(const Duration(days: 5)),
        usuarioId: 1,
        estabelecimentoId: 1,
        statusColeta: 'INATIVO',
      ),
    ];
  }

  Widget _buildColetasList() {
    final coletas = _getColetas();
    
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
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              style: const TextStyle(color: Colors.grey),
            ),
            Text(
              'Data: ${coleta.dataColeta.day}/${coleta.dataColeta.month}/${coleta.dataColeta.year}',
              style: const TextStyle(color: Colors.grey),
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
        decoration: const BoxDecoration(
          color: Color(0xFF334155),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Image.asset(
                'assets/images/logo.jpg',
                height: 100,
              ),
              const SizedBox(height: 20),
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
              Expanded(
                child: _buildColetasList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}