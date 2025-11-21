import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/gasto_service.dart';
import '../services/ganho_service.dart';
import '../services/poupanca_service.dart';
import '../services/auth_service.dart';

// --- NOVO MODELO DE DADOS ---
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
// --- FIM NOVO MODELO DE DADOS ---


class Historico extends StatefulWidget {
  final String email;
  const Historico({super.key, required this.email}) // A tela deve receber o email/idUsuario!

  @override
  State<Historico> createState() => _HistoricoState();
}

class _HistoricoState extends State<Historico> {
  final GastoService _gastoService = GastoService();
  final GanhoService _ganhoService = GanhoService();
  final PoupancaService _poupancaService = PoupancaService();

  List<HistoricoItem> _eventosAgrupados = [];
  bool _carregando = true;
  int? _idUsuario;

  @override
  void initState() {
    super.initState();
    // A busca de ID será feita em didChangeDependencies
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_idUsuario == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final email = args is String ? args : '';
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
          await _consolidarHistorico();
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
  
  // --- LÓGICA DE GERAÇÃO DE EVENTOS RECORRENTES ---
  List<HistoricoItem> _gerarRecorrentes(List<dynamic> lista, TipoMovimento tipo) {
    List<HistoricoItem> eventos = [];
    final hoje = DateTime.now();
    final dataLimite = hoje.subtract(const Duration(days: 180)); // Histórico de 6 meses

    for (var item in lista) {
      final dataInicioStr = item['dataInicio'];
      if (dataInicioStr == null) continue;
      
      final dataInicio = DateTime.parse(dataInicioStr);
      final repeticaoBD = item['repeticao'] ?? 'nenhuma';
      final valor = item['valor'] as double? ?? 0.0;
      final descricao = item['descricao'] ?? (item['origem'] ?? 'Sem descrição');

      // Se for um evento pontual, adiciona apenas se for recente
      if (repeticaoBD == 'nenhuma') {
        final data = item['dataCriacao'] != null ? DateTime.parse(item['dataCriacao']) : dataInicio;
        if (data.isAfter(dataLimite)) {
          eventos.add(_criaItem(tipo, descricao, valor, data));
        }
        continue;
      }

      // Lógica de Recorrência (mensal, semanal, etc.)
      DateTime dataAtual = dataInicio;
      while (dataAtual.isBefore(hoje)) {
        if (dataAtual.isAfter(dataLimite)) {
          eventos.add(_criaItem(tipo, descricao, valor, dataAtual));
        }
        
        // Avança para o próximo período (simplificado)
        if (repeticaoBD == 'mensal') {
          dataAtual = DateTime(dataAtual.year, dataAtual.month + 1, dataAtual.day);
        } else if (repeticaoBD == 'semanal') {
          dataAtual = dataAtual.add(const Duration(days: 7));
        } else if (repeticaoBD == 'x_dias') {
          final intervalo = item['intervaloDias'] ?? 30; // 30 dias se não houver
          dataAtual = dataAtual.add(Duration(days: intervalo));
        } else {
          break; // Sai do loop se não souber a repetição
        }
      }
    }
    return eventos;
  }
  
  // Função auxiliar para criar o HistoricoItem
  HistoricoItem _criaItem(TipoMovimento tipo, String descricao, double valor, DateTime data) {
    final bool isNegativo = tipo == TipoMovimento.gasto;
    final bool isDeposito = tipo == TipoMovimento.deposito;
    
    // Mapeamento de cores e ícones (você precisará ter as imagens)
    final cor = isNegativo ? Colors.red : (isDeposito ? Colors.orange : Colors.green);
    final icon = isNegativo ? 'assets/imagens/menos.png' : (isDeposito ? 'assets/imagens/moedas.png' : 'assets/imagens/mais.png');
    
    // O valor para o item de gasto deve ser positivo para a soma (se necessário), 
    // mas o sinal é dado pela cor/ícone. Aqui usamos o valor absoluto.
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

  Future<void> _consolidarHistorico() async {
    if (_idUsuario == null) return;
    try {
      // 1. Busca todos os dados
      final gastosRaw = await _gastoService.mostrarGastos(_idUsuario!);
      final ganhosRaw = await _ganhoService.mostrarGanhos(_idUsuario!);
      final depositosRaw = await _poupancaService.mostrarPoupancas(_idUsuario!);

      // 2. Converte e gera os eventos recorrentes
      final gastosEventos = _gerarRecorrentes(gastosRaw, TipoMovimento.gasto);
      final ganhosEventos = _gerarRecorrentes(ganhosRaw, TipoMovimento.ganho);
      final depositosEventos = _gerarRecorrentes(depositosRaw, TipoMovimento.deposito);

      // 3. Consolida e ordena (mais recente no topo)
      final todosEventos = [...gastosEventos, ...ganhosEventos, ...depositosEventos];
      todosEventos.sort((a, b) => b.data.compareTo(a.data)); // Ordena Decrescente (Mais recente primeiro)

      // 4. Agrupa por dia para a UI
      Map<String, List<HistoricoItem>> grupos = {};
      final formatador = DateFormat('dd/MM/yyyy');
      for (var item in todosEventos) {
        final chaveDia = formatador.format(item.data);
        if (!grupos.containsKey(chaveDia)) {
          grupos[chaveDia] = [];
        }
        grupos[chaveDia]!.add(item);
      }
      
      // Converte para uma lista simples para o ListView
      List<HistoricoItem> listaFinal = [];
      grupos.forEach((data, eventos) {
        // Adiciona um item especial para o separador de data
        listaFinal.add(HistoricoItem(
          tipo: TipoMovimento.deposito, // Usa 'deposito' como tipo dummy para o separador
          descricao: data, 
          valor: 0, 
          data: eventos.first.data, 
          iconAsset: 'separador', // Flag
          corValor: Colors.transparent,
        ));
        listaFinal.addAll(eventos);
      });


      if (mounted) {
        setState(() {
          _eventosAgrupados = listaFinal;
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _carregando = false;
          // Em caso de erro, você pode querer adicionar um item de erro aqui
        });
      }
    }
  }

  // --- WIDGET PARA O ITEM DO HISTÓRICO ---
  Widget _buildHistoricoItem(HistoricoItem item) {
    if (item.iconAsset == 'separador') {
      // Separador de Data
      return Padding(
        padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 16.0, right: 16.0),
        child: Row(
          children: [
            Text(
              item.descricao, // É a data formatada
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
        color: const Color(0xFFC7C7C7).withOpacity(0.3), // Fundo C7C7C7 com transparência
        borderRadius: BorderRadius.circular(10.0), // Bordas arredondadas
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Lado Esquerdo: Ícone e Descrição
          Row(
            children: [
              Image.asset(
                item.iconAsset, // Ícone do movimento (precisa existir nos assets)
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.45, // Limita a largura
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
  // --- FIM WIDGET PARA O ITEM DO HISTÓRICO ---


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho (Título)
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
                  // Placeholder para o botão de filtro (se existir)
                  const SizedBox(width: 48), 
                ],
              ),
            ),
            
            // Filtro (Placeholder - Você deve adicionar sua UI de filtro aqui)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text("Filtros Aqui (Ex: Mês, Ano)", style: TextStyle(fontStyle: FontStyle.italic)),
            ),
            
            // Indicador de Carregamento
            if (_carregando)
              const Center(child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ))
            else 
            // Lista do Histórico
            Expanded(
              child: _eventosAgrupados.isEmpty
                  ? const Center(child: Text("Nenhum movimento encontrado nos últimos 6 meses."))
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