import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/gasto_service.dart';
import '../services/ganho_service.dart';
import '../services/poupanca_service.dart';
import '../services/auth_service.dart';
import '../widgets/BlocoRelatorio.dart'; // <--- IMPORTAÇÃO DO NOVO WIDGET

// --- ENUMS E MODELOS ---
// Deve ser copiado para o BlocoRelatorio também
enum TipoMovimento { gasto, ganho, deposito }

class HistoricoItem {
  final TipoMovimento tipo;
  final String descricao;
  final double valor;
  final DateTime data;
  final String iconAsset; 
  final Color corValor;

  HistoricoItem({
    required this.tipo,
    required this.descricao,
    required this.valor,
    required this.data,
    required this.iconAsset,
    required this.corValor,
  });
}

// CORES CORRIGIDAS
const List<Color> GRAFICO_CORES = [
  Color(0xFF56CC39), 
  Color(0xFF267FD7),
  Color(0xFFE2B328),
  Color(0xFFE25328),
  Color(0xFFE838D6),
];

class ItemAgregado {
  final String descricao;
  final double total;
  final double porcentagem;
  final Color cor;

  ItemAgregado({
    required this.descricao,
    required this.total,
    required this.porcentagem,
    required this.cor,
  });
}
// --- FIM ENUMS E MODELOS ---


class Relatorios extends StatefulWidget {
  final String email;
  const Relatorios({super.key, required this.email});

  @override
  State<Relatorios> createState() => _RelatoriosState();
}

class _RelatoriosState extends State<Relatorios> {
  final GastoService _gastoService = GastoService();
  final GanhoService _ganhoService = GanhoService();
  final PoupancaService _poupancaService = PoupancaService();

  // Estados
  int? _idUsuario;
  bool _carregando = true;
  
  // Listas BRUTAS (Totais) para serem passadas aos blocos
  List<HistoricoItem> _eventosGastos = [];
  List<HistoricoItem> _eventosGanhos = [];
  List<HistoricoItem> _eventosDepositos = [];


  @override
  void initState() {
    super.initState();
    _buscarIdEcarregar();
  }

  // --- LÓGICA DE CARREGAMENTO E BUSCA DE ID ---

  Future<void> _buscarIdEcarregar() async {
    try {
      final id = await AuthService().buscarIdUsuario(widget.email);
      if (mounted) {
        setState(() {
          _idUsuario = id;
        });
        if (_idUsuario != null && _idUsuario! > 0) {
          await _carregarDadosCompletos();
        } else {
          setState(() => _carregando = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  // Lógica de Geração de Recorrentes (COPIADA DO HISTORICO.DART)
  List<HistoricoItem> _gerarRecorrentes(List<dynamic> lista, TipoMovimento tipo) {
    List<HistoricoItem> eventos = [];
    final hoje = DateTime.now();
    final dataLimite = hoje.subtract(const Duration(days: 365));

    for (var item in lista) {
      final dataBaseStr = item['dataInicio'] ?? item['dataCriacao'] ?? item['data'];
      if (dataBaseStr == null) continue;
      
      final dataBase = DateTime.parse(dataBaseStr);
      final repeticaoBD = item['repeticao'] ?? 'nenhuma';
      final valor = double.tryParse(item['valor']?.toString() ?? '0.0') ?? 0.0; 
      final descricao = item['descricao'] ?? (item['origem'] ?? 'Sem descrição');

      DateTime dataAtual = dataBase;
      while (dataAtual.isBefore(hoje.add(const Duration(days: 1)))) {
        if (dataAtual.isAfter(dataLimite)) {
          eventos.add(_criaItem(tipo, descricao, valor, dataAtual));
        }
        
        if (repeticaoBD == 'nenhuma') break; 
        
        if (repeticaoBD == 'mensal') {
          dataAtual = DateTime(dataAtual.year, dataAtual.month + 1, dataAtual.day);
        } else if (repeticaoBD == 'semanal') {
          dataAtual = dataAtual.add(const Duration(days: 7));
        } else if (repeticaoBD == 'x_dias') {
          final intervalo = item['intervaloDias'] as int? ?? 30;
          dataAtual = dataAtual.add(Duration(days: intervalo));
        } else {
          break; 
        }
      }
    }
    return eventos;
  }
  
  // Cria Item (COPIADA DO HISTORICO.DART)
  HistoricoItem _criaItem(TipoMovimento tipo, String descricao, double valor, DateTime data) {
    final bool isNegativo = tipo == TipoMovimento.gasto;
    final bool isDeposito = tipo == TipoMovimento.deposito;
    
    final cor = isNegativo ? Colors.red : (isDeposito ? Colors.orange : Colors.green);
    final icon = isNegativo ? 'assets/images/menos.png' : (isDeposito ? 'assets/images/deposito.png' : 'assets/images/mais.png');
    
    return HistoricoItem(
      tipo: tipo,
      descricao: descricao,
      valor: valor.abs(),
      data: data,
      iconAsset: icon,
      corValor: cor,
    );
  }

  Future<void> _carregarDadosCompletos() async {
    if (_idUsuario == null) return;
    try {
      final gastosRaw = await _gastoService.mostrarGastos(_idUsuario!);
      final ganhosRaw = await _ganhoService.mostrarGanhos(_idUsuario!);
      final depositosRaw = await _poupancaService.mostrarPoupancas(_idUsuario!);

      // GERAÇÃO DE EVENTOS E ARMAZENAMENTO NAS LISTAS BRUTAS
      final gastosEventos = _gerarRecorrentes(gastosRaw, TipoMovimento.gasto);
      final ganhosEventos = _gerarRecorrentes(ganhosRaw, TipoMovimento.ganho);
      final depositosEventos = _gerarRecorrentes(depositosRaw, TipoMovimento.deposito);

      if (mounted) {
        setState(() {
          _eventosGastos = gastosEventos; 
          _eventosGanhos = ganhosEventos; 
          _eventosDepositos = depositosEventos;
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  // A função _filtrarEAgruparPorMes e _agregarDados foram MOVIDAS
  // para dentro do BlocoRelatorio, deixando o Relatorios.dart mais limpo.
  
  // --- WIDGETS DE UI ---
  // Separador (Linha com ícone/título)
  Widget _buildSeparador(TipoMovimento tipo) {
    final Map<TipoMovimento, String> titulos = {
      TipoMovimento.gasto: "Gastos",
      TipoMovimento.ganho: "Ganhos",
      TipoMovimento.deposito: "Rendimentos",
    };
    final Map<TipoMovimento, String> icones = {
      TipoMovimento.gasto: 'assets/images/menos.png',
      TipoMovimento.ganho: 'assets/images/mais.png',
      TipoMovimento.deposito: 'assets/images/deposito.png',
    };
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Row(
        children: [
          Image.asset(icones[tipo]!, width: 24, height: 24),
          const SizedBox(width: 8),
          Text(
            titulos[tipo]!,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color.fromARGB(255, 33, 37, 41)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Divider(color: Color(0xFFC7C7C7), thickness: 1.5),
          ),
        ],
      ),
    );
  }
  // --- FIM WIDGETS DE UI ---


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fundo da página branco
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Cabeçalho
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 16.0, right: 16.0),
              child: Stack( 
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
                      "Relatórios",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D4590),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // 2. Indicador de Carregamento
            if (_carregando)
              const Center(child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ))
            else 
            // 3. Blocos de Relatório (Scrollable)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // --- BLOCO 1: GASTOS ---
                    _buildSeparador(TipoMovimento.gasto),
                    BlocoRelatorio(
                      tipo: TipoMovimento.gasto,
                      eventosBrutos: _eventosGastos, // <--- PASSA DADOS BRUTOS
                    ),
                    
                    // --- BLOCO 2: GANHOS ---
                    _buildSeparador(TipoMovimento.ganho),
                    BlocoRelatorio(
                      tipo: TipoMovimento.ganho,
                      eventosBrutos: _eventosGanhos,
                    ),
                    
                    // --- BLOCO 3: RENDIMENTOS (DEPÓSITOS) ---
                    _buildSeparador(TipoMovimento.deposito),
                    BlocoRelatorio(
                      tipo: TipoMovimento.deposito,
                      eventosBrutos: _eventosDepositos,
                    ),
                    
                    const SizedBox(height: 30),
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