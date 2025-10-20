import 'package:flutter/material.dart';
import 'package:frontend/services/auth_service.dart';
import '../services/gasto_service.dart';
import '../services/poupanca_service.dart';
import '../services/ganho_service.dart';

class Graficos extends StatefulWidget {
  final String email;
  const Graficos({super.key, required this.email});

  @override
  State<Graficos> createState() => _GraficosState();
}

class _GraficosState extends State<Graficos> {
  late final gastoService = GastoService();
  final ganhoService = GanhoService();
  final poupancaService = PoupancaService();

  List<Map<String, dynamic>> gastos = [];
  List<Map<String, dynamic>> ganhos = [];
  List<Map<String, dynamic>> poupancas = [];

  bool carregando = true;
  int? idUsuario;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Recupera email via argumentos da rota
    final args = ModalRoute.of(context)?.settings.arguments;
    final email = args is String ? args : '';

    if (carregando) {
      _carregarDados(email);
    }
  }

  Future<void> _carregarDados(String email) async {
    setState(() => carregando = true);

    try {
      final authService = AuthService();

      // 1. Busca o ID do usuário
      final id = await authService.buscarIdUsuario(email);
      if (id == null) throw Exception("Usuário não encontrado");
      idUsuario = id;

      // 2. Busca os dados agora que idUsuario existe
      gastos = List<Map<String, dynamic>>.from(await gastoService.mostrarGastos(idUsuario!));
      ganhos = List<Map<String, dynamic>>.from(await ganhoService.mostrarGanhos(idUsuario!));
      poupancas = await poupancaService.mostrarPoupancas(idUsuario!);
    } catch (e) {
      debugPrint('Erro ao carregar dados: $e');
    }

    setState(() => carregando = false);
  }


  void carregarIdUsuario(String email) async {
    final authService = AuthService();
    final id = await authService.buscarIdUsuario(email);
    setState(() {
      idUsuario = id as int; 
    });
  }


  Widget _buildGrafico(List<Map<String, dynamic>> dados) {
    if (dados.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text("Sem dados para exibir."),
      );
    }

    double total = dados.fold(0, (sum, item) => sum + (item["valor"] ?? 0));
    final cores = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.cyan,
      Colors.pink
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Row(
            children: dados.asMap().entries.map((entry) {
              final valor = entry.value["valor"] ?? 0.0;
              final cor = cores[entry.key % cores.length];
              final porcentagem = total > 0 ? valor / total : 0;
              return Expanded(
                flex: (porcentagem * 100).round(),
                child: Container(height: 24, color: cor),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: dados.asMap().entries.map((entry) {
              final cor = cores[entry.key % cores.length];
              final descricao = entry.value["descricao"] ?? "Sem descrição";
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(width: 10, height: 10, color: cor),
                    const SizedBox(width: 6),
                    Text(descricao, style: const TextStyle(fontSize: 13)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final email = args is String ? args : '';


    return Scaffold(
      backgroundColor: Colors.white,
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            "Gráficos",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D4590),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Gastos",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildGrafico(gastos),

                  const Text(
                    "Ganhos",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildGrafico(ganhos),

                  const Text(
                    "Poupança",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildGrafico(poupancas),
                ],
              ),
            ),
    );
  }
}
