import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/auth_service.dart';
import '../services/poupanca_service.dart';

class Poupanca extends StatefulWidget {
  const Poupanca({super.key});

  @override
  State<Poupanca> createState() => _PoupancaScreen();
}

class _PoupancaScreen extends State<Poupanca> {
  late Future<List<dynamic>> _poupancasFuture;
  late String email;
  late int idUsuario;

  List<FlSpot> _dadosGrafico = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;
    final email = args is String ? args : '';

    void carregarIdUsuario(String email) async {
      final authService = AuthService();
      final id = await authService.buscarIdUsuario(email);
      setState(() {
        idUsuario = id as int;
      });
    }

    final service = PoupancaService();
    _poupancasFuture = service.mostrarPoupancas(idUsuario) as Future<List>;

    _carregarDadosGrafico(); // carrega o gráfico
  }

  void _carregarDadosGrafico() async {
    // Exemplo simples — substitua por dados vindos do service
    // Formato: mês (x), valor acumulado (y)
    setState(() {
      _dadosGrafico = [
        const FlSpot(1, 200.0),
        const FlSpot(2, 350.0),
        const FlSpot(3, 450.0),
        const FlSpot(4, 700.0),
        const FlSpot(5, 850.0),
        const FlSpot(6, 950.0),
      ];
    });
  }

  void _deletarPoupanca(idPoupanca) async {
    final service = PoupancaService();
    final apagou = await service.deletarPoupanca(idPoupanca);
    if (apagou) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Poupança deletada com sucesso.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Falha ao deletar a poupança.")),
      );
    }
  }

  Widget _graficoPoupanca() {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              bottom: BorderSide(color: Colors.grey),
              left: BorderSide(color: Colors.grey),
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (x, meta) {
                  const meses = [
                    '',
                    'Jan',
                    'Fev',
                    'Mar',
                    'Abr',
                    'Mai',
                    'Jun',
                    'Jul',
                    'Ago',
                    'Set',
                    'Out',
                    'Nov',
                    'Dez'
                  ];
                  return Text(meses[x.toInt()]);
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text("R\$${value.toInt()}"),
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: _dadosGrafico,
              isCurved: true,
              color: const Color(0xFF0D4590),
              barWidth: 3,
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF0D4590).withOpacity(0.3),
              ),
              dotData: const FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        color: Colors.white,
        child: Column(
          children: [
            // ------ Cabeçalho ------
            Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Image.asset(
                      'assets/images/seta.png',
                      width: 24,
                      height: 24,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/home', arguments: email);
                    },
                  ),
                ),
                const Center(
                  child: Text(
                    "Poupança",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 33, 37, 41),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ------ Gráfico ------
            _graficoPoupanca(),

            const SizedBox(height: 20),

            // ------ Botão Nova Poupança ------
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 13, 69, 144),
                    minimumSize: const Size(200, 100),
                    side: const BorderSide(
                        color: Color.fromARGB(255, 230, 232, 234)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/adicionarPoupanca',
                        arguments: email);
                  },
                  child: const Text(
                    "Nova poupança +",
                    style: TextStyle(
                      color: Color.fromARGB(255, 230, 232, 234),
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ------ Botão acessar histórico ------
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  minimumSize: const Size(400, 70),
                  side: const BorderSide(
                      color: Color.fromARGB(255, 33, 37, 41), width: 2),
                  shape: const RoundedRectangleBorder(),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/historicoPoupanca',
                      arguments: email);
                },
                child: const Text(
                  "Acessar histórico",
                  style: TextStyle(
                    color: Color.fromARGB(255, 33, 37, 41),
                    fontSize: 20,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ------ Lista de poupanças ------
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _poupancasFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(
                        child: Text("Erro ao carregar as poupanças."));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text("Nenhuma poupança encontrada."));
                  }

                  final poupancas = snapshot.data!;

                  return ListView.builder(
                    itemCount: poupancas.length,
                    itemBuilder: (context, index) {
                      final poupanca = poupancas[index];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: const Icon(Icons.savings,
                              color: Color(0xFF0D4590)),
                          title: Text(
                            poupanca["nome"] ?? "Sem nome",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            "R\$ ${poupanca["valorAtual"]}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Image.asset(
                                  'assets/images/lapis.png',
                                  width: 22,
                                  height: 22,
                                ),
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/editarPoupanca',
                                      arguments: email);
                                },
                              ),
                              IconButton(
                                icon: Image.asset(
                                  'assets/images/lixeira.png',
                                  width: 22,
                                  height: 22,
                                ),
                                onPressed: () =>
                                    _deletarPoupanca(poupanca["idPoupanca"]),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
