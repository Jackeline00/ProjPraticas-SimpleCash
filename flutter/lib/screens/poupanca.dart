import 'package:flutter/material.dart';
import '../services/poupanca_service.dart'; // serviço que faz GET e POST dos dados de poupança
import 'novo_deposito_page.dart'; // tela para adicionar novo depósito
import 'package:fl_chart/fl_chart.dart'; // biblioteca para o gráfico de barras

class PoupancaPage extends StatefulWidget {
  const PoupancaPage({super.key});

  @override
  State<PoupancaPage> createState() => _PoupancaPageState();
}

class _PoupancaPageState extends State<PoupancaPage> {
  late Future<List<Map<String, dynamic>>> _poupancasFuture;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() {
    _poupancasFuture = PoupancaService().listarPoupancas();
  }

  void _atualizarTela() {
    setState(() {
      _carregarDados();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Poupança"),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _poupancasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          }

          final dados = snapshot.data ?? [];

          if (dados.isEmpty) {
            return const Center(child: Text("Nenhum dado de poupança encontrado."));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: BarChart(
                    BarChartData(
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              int index = value.toInt();
                              if (index < 0 || index >= dados.length) return const SizedBox();
                              return Text(
                                dados[index]["mes"] ?? "",
                                style: const TextStyle(fontSize: 12),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: dados.asMap().entries.map((e) {
                        int i = e.key;
                        double valor = double.tryParse(e.value["valor"].toString()) ?? 0;
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: valor,
                              color: Colors.green.shade600,
                              width: 18,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text("Novo Depósito"),
                  onPressed: () async {
                    final atualizado = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NovoDepositoPage()),
                    );
                    if (atualizado == true) {
                      _atualizarTela();
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
