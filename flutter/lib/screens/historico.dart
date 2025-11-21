import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/gasto_service.dart';
import '../services/ganho_service.dart';
import '../services/poupanca_service.dart';
import '../services/auth_service.dart';

// --- ENUMS E MODELOS ---
enum TipoMovimento { gasto, ganho, deposito }
enum FiltroAtivo { todos, gastos, ganhos, depositos } 

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
// --- FIM ENUMS E MODELOS ---


class Historico extends StatefulWidget {
  final String email; 
  const Historico({super.key, required this.email}); 

  @override
  State<Historico> createState() => _HistoricoState();
}

class _HistoricoState extends State<Historico> {
  final GastoService _gastoService = GastoService();
  final GanhoService _ganhoService = GanhoService();
  final PoupancaService _poupancaService = PoupancaService();

  List<HistoricoItem> _eventosOriginais = []; 
  List<HistoricoItem> _eventosAgrupados = []; 
  bool _carregando = true;
  int? _idUsuario;
  FiltroAtivo _filtroAtual = FiltroAtivo.todos; 


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_idUsuario == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final Map<String, dynamic> argsMap = args is Map<String, dynamic> ? args : {};
      
      final email = argsMap['email'] ?? widget.email; 
      final filtroInicialStr = argsMap['filtro'] ?? 'todos'; 

      // Mapeamento do Filtro Inicial
      _filtroAtual = switch (filtroInicialStr) {
        'gastos' => FiltroAtivo.gastos,
        'ganhos' => FiltroAtivo.ganhos,
        'depositos' => FiltroAtivo.depositos,
        _ => FiltroAtivo.todos,
      };

      if (email.isNotEmpty) {
        _buscarIdEcarregar(email);
      } else {
        setState(() => _carregando = false);
      }
    }
  }

  Future<void> _buscarIdEcarregar(String email) async {
    try {
      final id = await AuthService().buscarIdUsuario(email);
      if (mounted) {
        setState(() {
          _idUsuario = id;
        });
        if (_idUsuario != null && _idUsuario! > 0) {
          await _carregarDadosCompletos(); 
          _aplicarFiltro(_filtroAtual); 
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

  // --- LÓGICA DE GERAÇÃO DE EVENTOS RECORRENTES (COMPLETA) ---
  List<HistoricoItem> _gerarRecorrentes(List<dynamic> lista, TipoMovimento tipo) {
    List<HistoricoItem> eventos = [];
    final hoje = DateTime.now();
    final dataLimite = hoje.subtract(const Duration(days: 180)); 

    for (var item in lista) {
      // Tenta usar dataInicio ou dataCriacao para a data base
      final dataBaseStr = item['dataInicio'] ?? item['dataCriacao'] ?? item['data'];
      if (dataBaseStr == null) continue;
      
      final dataBase = DateTime.parse(dataBaseStr);
      final repeticaoBD = item['repeticao'] ?? 'nenhuma';
      // NOTA: O valor pode ser Double ou Int dependendo do DB. Forçar o cast:
      final valor = double.tryParse(item['valor']?.toString() ?? '0.0') ?? 0.0; 
      final descricao = item['descricao'] ?? (item['origem'] ?? 'Sem descrição');

      // 1. Eventos pontuais (nenhuma repetição)
      if (repeticaoBD == 'nenhuma') {
        if (dataBase.isAfter(dataLimite)) {
          eventos.add(_criaItem(tipo, descricao, valor, dataBase));
        }
        continue;
      }

      // 2. Eventos recorrentes
      DateTime dataAtual = dataBase;
      while (dataAtual.isBefore(hoje)) {
        if (dataAtual.isAfter(dataLimite)) {
          eventos.add(_criaItem(tipo, descricao, valor, dataAtual));
        }
        
        // Avança para o próximo período
        if (repeticaoBD == 'mensal') {
          dataAtual = DateTime(dataAtual.year, dataAtual.month + 1, dataAtual.day);
        } else if (repeticaoBD == 'semanal') {
          dataAtual = dataAtual.add(const Duration(days: 7));
        } else if (repeticaoBD == 'x_dias') {
          final intervalo = item['intervaloDias'] as int? ?? 30; // Padrão 30 dias
          dataAtual = dataAtual.add(Duration(days: intervalo));
        } else {
          break; 
        }
      }
    }
    return eventos;
  }
  
  // Função auxiliar para criar o HistoricoItem (Permanece)
  HistoricoItem _criaItem(TipoMovimento tipo, String descricao, double valor, DateTime data) {
    final bool isNegativo = tipo == TipoMovimento.gasto;
    final bool isDeposito = tipo == TipoMovimento.deposito;
    
    // As cores foram ajustadas para o padrão solicitado
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
  // --- FIM LÓGICA DE GERAÇÃO DE EVENTOS RECORRENTES ---

  Future<void> _carregarDadosCompletos() async {
    if (_idUsuario == null) return;
    try {
      // NOTA: Para Poupança, estamos usando mostrarPoupancas, que pode retornar 
      // todos os eventos, que é o que precisamos.
      final gastosRaw = await _gastoService.mostrarGastos(_idUsuario!);
      final ganhosRaw = await _ganhoService.mostrarGanhos(_idUsuario!);
      final depositosRaw = await _poupancaService.mostrarPoupancas(_idUsuario!);

      final gastosEventos = _gerarRecorrentes(gastosRaw, TipoMovimento.gasto);
      final ganhosEventos = _gerarRecorrentes(ganhosRaw, TipoMovimento.ganho);
      // NOTE: Para Depósitos, assumimos que são todos eventos recorrentes (TipoMovimento.deposito)
      final depositosEventos = _gerarRecorrentes(depositosRaw, TipoMovimento.deposito);

      final todosEventos = [...gastosEventos, ...ganhosEventos, ...depositosEventos];
      todosEventos.sort((a, b) => b.data.compareTo(a.data)); // Mais recente no topo

      if (mounted) {
        setState(() {
          _eventosOriginais = todosEventos; 
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  // --- LÓGICA DE FILTRAGEM (NOVO) ---
  void _aplicarFiltro(FiltroAtivo novoFiltro) {
    List<HistoricoItem> eventosFiltrados = _eventosOriginais.where((item) {
      if (item.iconAsset == 'separador') return true; // Mantém o separador

      if (novoFiltro == FiltroAtivo.todos) return true;
      if (novoFiltro == FiltroAtivo.gastos && item.tipo == TipoMovimento.gasto) return true;
      if (novoFiltro == FiltroAtivo.ganhos && item.tipo == TipoMovimento.ganho) return true;
      if (novoFiltro == FiltroAtivo.depositos && item.tipo == TipoMovimento.deposito) return true;
      return false;
    }).toList();
    
    // 4. Agrupa por dia para a UI
    Map<String, List<HistoricoItem>> grupos = {};
    final formatador = DateFormat('dd/MM/yyyy');
    for (var item in eventosFiltrados) {
      final chaveDia = formatador.format(item.data);
      if (!grupos.containsKey(chaveDia)) {
        grupos[chaveDia] = [];
      }
      grupos[chaveDia]!.add(item);
    }
    
    // Converte para uma lista simples para o ListView com separadores
    List<HistoricoItem> listaFinal = [];
    grupos.forEach((data, eventos) {
      // Adiciona um item especial para o separador de data
      listaFinal.add(HistoricoItem(
        tipo: TipoMovimento.deposito, 
        descricao: data, 
        valor: 0, 
        data: eventos.first.data, 
        iconAsset: 'separador', 
        corValor: Colors.transparent,
      ));
      listaFinal.addAll(eventos);
    });

    setState(() {
      _filtroAtual = novoFiltro;
      _eventosAgrupados = listaFinal;
    });
  }
  
  // Função para mostrar o menu de filtro (janelinha)
  void _mostrarMenuFiltro() {
    // Calcula a posição para aparecer no canto superior direito
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset(button.size.width, 0), ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    
    showMenu<FiltroAtivo>(
      context: context,
      position: position, // Usa a posição calculada
      items: FiltroAtivo.values.map((filtro) {
        return PopupMenuItem<FiltroAtivo>(
          value: filtro,
          child: Text(filtro.name.substring(0, 1).toUpperCase() + filtro.name.substring(1)), 
        );
      }).toList(),
    ).then((value) {
      if (value != null) {
        _aplicarFiltro(value);
      }
    });
  }
  // --- FIM LÓGICA DE FILTRAGEM (NOVO) ---


  // --- WIDGETS ---
  Widget _buildHistoricoItem(HistoricoItem item) {
    // ... (restante do seu código _buildHistoricoItem) ...
    
    if (item.iconAsset == 'separador') {
      // Separador de Data
      return Padding(
        padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 16.0, right: 16.0),
        child: Row(
          children: [
            Text(
              item.descricao, 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Divider(color: Color(0xFFC7C7C7), thickness: 1.5),
            ),
          ],
        ),
      );
    }

    // Cartão de Gasto/Ganho/Depósito
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFC7C7C7).withOpacity(0.3), 
        borderRadius: BorderRadius.circular(10.0), 
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Lado Esquerdo: Ícone e Descrição
          Row(
            children: [
              Image.asset(
                item.iconAsset, 
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.45, 
                child: Text(
                  item.descricao,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),

          // Lado Direito: Valor
          Text(
            (item.tipo == TipoMovimento.gasto ? '- ' : '+ ') + "R\$ ${item.valor.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: item.corValor,
            ),
          ),
        ],
      ),
    );
  }
  // --- FIM WIDGETS ---


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Cabeçalho e Botão Filtros
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 16.0, right: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Histórico",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D4590),
                    ),
                  ),
                  // BOTÃO FILTROS
                  TextButton(
                    onPressed: _mostrarMenuFiltro,
                    child: const Text("Filtros", style: TextStyle(color: Color(0xFF0D4590), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            
            // 2. INDICADOR DE FILTRO ATIVO (Chip) - CORRIGIDO PARA ALINHAR À DIREITA
            if (_filtroAtual != FiltroAtivo.todos)
              Row( // Usa um Row para alinhar
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0, bottom: 8.0), // Padding à direita
                    child: Chip(
                      label: Text(
                        "Filtro: ${_filtroAtual.name.substring(0, 1).toUpperCase() + _filtroAtual.name.substring(1)}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => _aplicarFiltro(FiltroAtivo.todos), // Volta para 'Todos'
                    ),
                  ),
                ],
              ),
            
            // 3. Indicador de Carregamento
            if (_carregando)
              const Center(child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ))
            else 
            // 4. Lista do Histórico
            Expanded(
              child: _eventosAgrupados.isEmpty
                  ? const Center(child: Text("Nenhum movimento encontrado nos últimos 6 meses com este filtro."))
                  : ListView.builder(
                      itemCount: _eventosAgrupados.length,
                      itemBuilder: (context, index) {
                        final item = _eventosAgrupados[index];
                        return _buildHistoricoItem(item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}