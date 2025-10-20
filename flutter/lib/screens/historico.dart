import 'package:flutter/material.dart';
import 'package:frontend/services/auth_service.dart';
import '../services/historico_service.dart';

class Historico extends StatefulWidget {
  const Historico({super.key});

  @override
  State<Historico> createState() => _HistoricoScreen();
}

class _HistoricoScreen extends State<Historico> {
  String filtroSelecionado = "todos";
  late Future<List<Map<String, dynamic>>> _historicoFuture;
  late int idUsuario;

  final service = HistoricoService();

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  void carregarIdUsuario(String email) async {
    final authService = AuthService();
    final id = await authService.buscarIdUsuario(email);
    setState(() {
      idUsuario = id as int; /// tenta converter para double 
    });
  }

  void _carregarHistorico() {
    switch (filtroSelecionado) {
      case "gastos":
        _historicoFuture = service.mostrarGastos(idUsuario);
        break;
      case "ganhos":
        _historicoFuture = service.mostrarGanhos(idUsuario);
        break;
      case "poupanca":
        _historicoFuture = service.mostrarPoupancas(idUsuario);
        break;
      default:
        _historicoFuture = Future.wait([
          service.mostrarGastos(idUsuario),
          service.mostrarGanhos(idUsuario),
          service.mostrarPoupancas(idUsuario),
        ]).then((listas) => listas.expand((e) => e).toList());
    }
    setState(() {});
  }

  void _abrirFiltro() async {
    final selecionado = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Filtrar histórico"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Todos"),
                onTap: () => Navigator.pop(context, "todos"),
              ),
              ListTile(
                title: const Text("Gastos"),
                onTap: () => Navigator.pop(context, "gastos"),
              ),
              ListTile(
                title: const Text("Ganhos"),
                onTap: () => Navigator.pop(context, "ganhos"),
              ),
              ListTile(
                title: const Text("Poupança"),
                onTap: () => Navigator.pop(context, "poupanca"),
              ),
            ],
          ),
        );
      },
    );

    if (selecionado != null && selecionado != filtroSelecionado) {
      setState(() {
        filtroSelecionado = selecionado;
        _carregarHistorico();
      });
    }
  }

  IconData _iconePorTipo(String tipo) {
    switch (tipo) {
      case "gasto":
        return Icons.remove_circle_outline;
      case "ganho":
        return Icons.add_circle_outline;
      case "poupanca":
        return Icons.savings_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  Color _corPorTipo(String tipo) {
    switch (tipo) {
      case "gasto":
        return Colors.red;
      case "ganho":
        return Colors.green;
      case "poupanca":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _textoFiltro(String filtro) {
    switch (filtro) {
      case "gastos":
        return "gastos";
      case "ganhos":
        return "ganhos";
      case "poupanca":
        return "poupança";
      default:
        return "todos";
    }
  }

  @override
  Widget build(BuildContext context) {
    /// recupera o email passado via Navigator
    final args = ModalRoute.of(context)?.settings.arguments;
    final email = args is String ? args : '';

    /// Pega o usuário 
    carregarIdUsuario(email);
    

    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        color: Colors.white,
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
                    icon: Image.asset('assets/images/seta.png', width: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Text(
                  "Histórico",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D4590),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            /// Botão "Filtrar" + Chip do filtro ativo
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: _abrirFiltro,
                  child: const Text(
                    "filtrar",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(width: 12),
                if (filtroSelecionado != "todos")
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.black26),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 6, horizontal: 12),
                    child: Text(
                      _textoFiltro(filtroSelecionado),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 30),

            /// Lista de histórico
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _historicoFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text("Erro ao carregar histórico."));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Nenhum registro encontrado."));
                  }

                  final dados = snapshot.data!;

                  // Agrupar por data
                  final datas = dados.map((e) => e['data']).toSet().toList();

                  return ListView.builder(
                    itemCount: datas.length,
                    itemBuilder: (context, i) {
                      final data = datas[i];
                      final registros = dados.where((e) => e['data'] == data).toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const Divider(),
                          ...registros.map((r) => Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                      color: _corPorTipo(r["tipo"])
                                          .withOpacity(0.5)),
                                ),
                                child: ListTile(
                                  leading: Icon(_iconePorTipo(r["tipo"]),
                                      color: _corPorTipo(r["tipo"])),
                                  title: Text(r["descricao"]),
                                  trailing: Text(
                                    "R\$${r["valor"].toStringAsFixed(2)}",
                                    style: TextStyle(
                                      color: _corPorTipo(r["tipo"]),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )),
                          const SizedBox(height: 20),
                        ],
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
