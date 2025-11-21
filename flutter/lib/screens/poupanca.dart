import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/poupanca_service.dart';
import '../services/auth_service.dart'; 
// Importação do Histórico já está correta se for necessário
// import 'historico.dart'; 


class Poupanca extends StatefulWidget {
  // CORREÇÃO: Construtor agora aceita o email
  final String email; 

  const Poupanca({super.key, required this.email});

  @override
  State<Poupanca> createState() => _PoupancaState();
}

class _PoupancaState extends State<Poupanca> {
  final PoupancaService _service = PoupancaService();

  double valorGuardado = 0;
  List<Map<String, dynamic>> _dadosGrafico = [];
  bool carregando = true;
  int? idUsuario; // Variável para guardar o ID do usuário

  @override
  void initState() {
    super.initState();
    _buscarIdEcarregar(); // <--- INICIA O PROCESSO DE BUSCA
  }

  // --- FUNÇÃO CORRIGIDA: BUSCA ID E INICIA O CARREGAMENTO ---
  Future<void> _buscarIdEcarregar() async {
    try {
      // 1. Busca o ID do usuário usando o email
      final id = await AuthService().buscarIdUsuario(widget.email);
      
      if (mounted) {
        setState(() {
          idUsuario = id;
        });
        
        if (id != 0 && idUsuario != null) { 
          // 2. Se o ID foi encontrado, carrega os dados da poupança
          await _carregarPoupancas();
        } else {
          // 3. Se não encontrou o ID, para o loading
          setState(() => carregando = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => carregando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao buscar ID: $e")),
        );
      }
    }
  }
  
  Future<void> _recarregarAposAcao() async {
    setState(() => carregando = true);
    await _carregarPoupancas();
  }

  Future<void> _carregarPoupancas() async {
    if (idUsuario == null) return; // Proteção

    try {
      // 1. Usa idUsuario! para chamar o serviço
      final lista = await _service.mostrarPoupancas(idUsuario!);

      // soma total dos valores
      final total = lista.fold<double>(0, (soma, e) => soma + (e['valor'] ?? 0));

      // agrupa por mês (simplificado)
      final Map<String, double> porMes = {};
      for (var item in lista) {
        // Usa 'dataCriacao' ou 'data' dependendo do que seu backend retorna
        final dataStr = item['dataCriacao'] ?? item['data'] ?? DateTime.now().toIso8601String(); 
        final data = DateTime.parse(dataStr);
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
      if (mounted) {
        setState(() => carregando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao carregar dados da poupança")),
        );
      }
    }
  }

  String _abreviarMes(int mes) {
    const meses = [
      "Jan", "Fev", "Mar", "Abr", "Mai", "Jun",
      "Jul", "Ago", "Set", "Out", "Nov", "Dez"
    ];
    return meses[mes - 1];
  }

  Future<void> _navegarParaNovoDeposito() async {
    if (idUsuario == null) return;
    
    // Passa o idUsuario para a tela de depósito
    final resultado = await Navigator.pushNamed(
      context, 
      '/adicionarDeposito', 
      arguments: idUsuario!, 
    );
    
    if (resultado == true) {
      _recarregarAposAcao(); 
    }
  }
  
  void _navegarParaHistorico() {
    if (idUsuario == null) return;
    Navigator.pushNamed(
      context,
      '/historico',
      arguments: idUsuario!,
    );
  }


  Widget _grafico() {
    if (_dadosGrafico.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 20),
        child: Center(child: Text("Nenhum dado disponível.")),
      );
    }

    // ... (restante do código do BarChart)
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _dadosGrafico.map((e) => e['valor'] as double).reduce((a, b) => a > b ? a : b) * 1.1, 
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                       return Text(value.toStringAsFixed(0));
                    }
                )
            ),
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
                      toY: e.value['valor'] as double,
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
    if (carregando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    // Proteção caso o ID não tenha sido encontrado
    if (idUsuario == null) {
      return const Scaffold(
        body: Center(child: Text("Erro: Não foi possível carregar dados do usuário.")),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 1. Cabeçalho (Título Pequeno)
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
                  const Center(
                    child: Text(
                      "Poupança",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D4590),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// 2. Retângulo com o Valor Atual
              const Text(
                "Valor guardado",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 33, 37, 41)),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9), 
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "R\$ ${valorGuardado.toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0D4590)),
                ),
              ),

              const SizedBox(height: 40),

              /// 3. Botões (Centralizados Verticalmente)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Botão Novo Depósito
                    ElevatedButton(
                      onPressed: _navegarParaNovoDeposito,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D4590), 
                        foregroundColor: Colors.white,
                        minimumSize: const Size(200, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Novo depósito",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Botão Acessar Histórico
                    OutlinedButton(
                      onPressed: _navegarParaHistorico,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(200, 50),
                        side: const BorderSide(color: Color(0xFF0D4590)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Acessar histórico",
                        style: TextStyle(color: Color(0xFF0D4590), fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              /// 4. Gráfico
              const Text("Evolução Mensal:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Expanded(
                child: _grafico(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}