import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/poupanca_service.dart';
import 'historico.dart';

class Poupanca extends StatefulWidget {
  final int idUsuario; // precisa do id do usuário logado

  const Poupanca({super.key, required this.idUsuario});

  @override
  State<Poupanca> createState() => _PoupancaState();
}

class _PoupancaState extends State<Poupanca> {
  final PoupancaService _service = PoupancaService();

  double valorGuardado = 0;
  List<Map<String, dynamic>> _dadosGrafico = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarPoupancas();
  }

  Future<void> _carregarPoupancas() async {
    try {
      final lista = await _service.mostrarPoupancas(widget.idUsuario);

      // soma total dos valores
      final total = lista.fold<double>(0, (soma, e) => soma + (e['valor'] ?? 0));

      // agrupa por mês (simplificado)
      final Map<String, double> porMes = {};
      for (var item in lista) {
        final data = DateTime.parse(item['data']);
        final mes = _abreviarMes(data.month);
        porMes[mes] = (porMes[mes] ?? 0) + (item['valor'] ?? 0);
      }

      setState(() {
        valorGuardado = total;
        _dadosGrafico = porMes.entries
            .map((e) => {"mes": e.key, "valor": e.value})
            .toList();
        carregando = false;
      });
    } catch (e) {
      setState(() => carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao carregar dados da poupança")),
      );
    }
  }

  String _abreviarMes(int mes) {
    const meses = [
      "jan", "fev", "mar", "abr", "mai", "jun",
      "jul", "ago", "set", "out", "nov", "dez"
    ];
    return meses[mes - 1];
  }

  Future<void> _novoDeposito() async {
    double deposito = 0;
    final controller = TextEditingController();

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Novo depósito"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Valor (R\$)",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                deposito = double.tryParse(controller.text) ?? 0;
                Navigator.pop(context, true);
              },
              child: const Text("Confirmar"),
            ),
          ],
        );
      },
    );

    if (confirmado == true && deposito > 0) {
      try {
        await _service.criarPoupanca(
          widget.idUsuario,
          "poupanca",
          "Depósito manual",
          deposito,
          DateTime.now().toIso8601String(),
          0,
          "app",
        );
        await _carregarPoupancas();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Depósito registrado!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao registrar depósito.")),
        );
      }
    }
  }

  Widget _grafico() {
    if (_dadosGrafico.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 20),
        child: Center(child: Text("Nenhum dado disponível.")),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      height: 200,
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value < 0 || value >= _dadosGrafico.length) return Container();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _dadosGrafico[value.toInt()]['mes'],
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: _dadosGrafico
              .asMap()
              .entries
              .map(
                (e) => BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: e.value['valor'],
                      color: const Color(0xFF0D4590),
                      width: 18,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Cabeçalho
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const Text(
                        "Poupança",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D4590),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text("Valor guardado:",
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    color: Colors.grey[300],
                    child: Text(
                      "R\$ ${valorGuardado.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Center(
                    child: ElevatedButton(
                      onPressed: _novoDeposito,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                        minimumSize: const Size(180, 45),
                      ),
                      child: const Text("Novo depósito"),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Center(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const Historico()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(180, 45),
                        side: const BorderSide(color: Colors.black),
                      ),
                      child: const Text(
                        "Acessar histórico",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),

                  _grafico(),
                ],
              ),
            ),
    );
  }
}

