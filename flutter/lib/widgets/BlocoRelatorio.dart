import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Importa as estruturas e constantes (Certifique-se que o caminho está correto)
import '../screens/relatorios.dart'; 

class BlocoRelatorio extends StatefulWidget {
  final TipoMovimento tipo;
  final List<HistoricoItem> eventosBrutos; // Recebe DADOS BRUTOS TOTAIS

  const BlocoRelatorio({
    super.key,
    required this.tipo,
    required this.eventosBrutos,
  });

  @override
  State<BlocoRelatorio> createState() => _BlocoRelatorioState();
}

class _BlocoRelatorioState extends State<BlocoRelatorio> {
  DateTime _mesAtual = DateTime.now();
  List<ItemAgregado> _dadosAgregados = []; // ESTADO INTERNO PARA OS DADOS DO GRÁFICO
  late DateFormat _mesFormatador;

  @override
  void initState() {
    super.initState();
    _mesFormatador = DateFormat('MMMM', 'pt_BR');
    _reprocessarDados(); // Processa os dados iniciais
  }
  
  // CORREÇÃO: ATUALIZA O ESTADO QUANDO O WIDGET PAI ENVIA NOVOS DADOS BRUTOS
  @override
  void didUpdateWidget(covariant BlocoRelatorio oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Se a lista BRUTA mudou, reprocessa
    if (widget.eventosBrutos != oldWidget.eventosBrutos) {
      _reprocessarDados(); 
    }
  }

  // --- LÓGICA DE AGREGAÇÃO (MOVIDA PARA CÁ) ---
  void _reprocessarDados() {
    // 1. Filtrar eventos APENAS para o mês atual
    final eventosDoMes = widget.eventosBrutos.where((item) {
      return item.data.month == _mesAtual.month && item.data.year == _mesAtual.year;
    }).toList();
    
    // 2. Agrupar e somar por Descrição
    final Map<String, double> agregacao = {};
    eventosDoMes.forEach((item) {
      final categoria = item.descricao; 
      agregacao[categoria] = (agregacao[categoria] ?? 0.0) + item.valor;
    });

    // 3. Processar para porcentagem (limitar a 5)
    final totalGeral = agregacao.values.fold<double>(0, (soma, valor) => soma + valor);
    List<MapEntry<String, double>> listaOrdenada = agregacao.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
      
    listaOrdenada = listaOrdenada.take(5).toList();

    final List<ItemAgregado> novosDados = listaOrdenada.asMap().entries.map((e) {
      final item = e.value;
      final index = e.key;
      return ItemAgregado(
        descricao: item.key,
        total: item.value,
        porcentagem: (item.value / totalGeral) * 100,
        cor: GRAFICO_CORES[index % GRAFICO_CORES.length],
      );
    }).toList();
    
    setState(() {
      _dadosAgregados = novosDados; 
    });
  }

  // --- Função para mudar o mês (AGORA CHAMA APENAS O REPROCESSAMENTO INTERNO) ---
  void _mudarMes(int meses) {
    setState(() {
      _mesAtual = DateTime(_mesAtual.year, _mesAtual.month + meses, 1);
    });
    _reprocessarDados(); // Recalcula o gráfico
  }

  @override
  Widget build(BuildContext context) {
    final String mesFormatado = _mesFormatador.format(_mesAtual);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA), // Fundo FAFAFA
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFF8EC1F3), width: 2), 
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seletor de Mês
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 16, color: Color(0xFF0D4590)),
                onPressed: () => _mudarMes(-1),
              ),
              Text(
                mesFormatado,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D4590)),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF0D4590)),
                onPressed: () => _mudarMes(1),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Gráfico de Barras de Porcentagem
          Container(
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: _dadosAgregados.isEmpty
                  ? [const Expanded(child: Center(child: Text("Nenhum dado neste mês."))) ]
                  : _dadosAgregados.map((item) { // USA _DADOSAGREGADOS
                      return Expanded(
                        flex: item.porcentagem.toInt(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: item.cor,
                            borderRadius: BorderRadius.horizontal(
                              left: item == _dadosAgregados.first ? const Radius.circular(6) : Radius.zero,
                              right: item == _dadosAgregados.last ? const Radius.circular(6) : Radius.zero,
                            ),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 6),
                          child: Text(
                            item.porcentagem.toInt() > 0 ? "${item.porcentagem.toInt()}%" : "",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      );
                    }).toList(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Legenda (Em Coluna, Alinhada à Esquerda)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: _dadosAgregados.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min, 
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: item.cor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(item.descricao, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}