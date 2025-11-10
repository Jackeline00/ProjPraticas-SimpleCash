import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/gasto_service.dart'; /// serviço que faz a requisição GET

/// Tela pronta
//

class Gastos extends StatefulWidget {
  const Gastos({super.key});

  @override
  State<Gastos> createState() => _GastosScreen();
}

class _GastosScreen extends State<Gastos> {
  Future<List<dynamic>> _gastosFuture = Future.value([]);
  String email = '';
  int? idUsuario;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;
    email = args is String ? args : '';

    print("E-mail recebido: $email");

    _carregarGastos(); 
  }

  void _carregarGastos() async {
    final authService = AuthService();
    final id = await authService.buscarIdUsuario(email);

    if (id != null) {
      setState(() {
        idUsuario = id;
        _gastosFuture = GastoService().mostrarGastos(idUsuario!);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao recuperar ID do usuário.")),
      );
    }
  }

  void _deletarGasto(idGasto) async {
    final service = GastoService();
    final apagou = await service.deletarGasto(idGasto);
    if(apagou){
      ScaffoldMessenger.of(context).showSnackBar( 
        const SnackBar(content: Text("Dado deletado com sucesso.")),
      );
      _carregarGastos(); /// recarrega lista após deletar
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar( 
        const SnackBar(content: Text("Falha ao deletar o dado")),
      );
    }

  }

  @override
  Widget build(BuildContext context) {

    if (idUsuario == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                child: Column(
                  children: [
                    /// ------ Cabeçalho ------
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
                            "Gastos",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 33, 37, 41),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    /// ------ Botão Novo Gasto ------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 13, 69, 144),
                            minimumSize: const Size(200, 100), /// largura = 200, altura = 100
                            side: const BorderSide(color: Color.fromARGB(255, 230, 232, 234)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/adicionarGasto', arguments: email); /// leva pra outra tela
                          },
                          child: const Text(
                            "Novo gasto +",
                            style: TextStyle(
                              color: Color.fromARGB(255, 230, 232, 234),
                              fontSize: 20,
                              //fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    /// ------ Botão acessar histórico ------
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          minimumSize: const Size(400, 70), 
                          side: const BorderSide(color: Color.fromARGB(255, 33, 37, 41), width: 2),
                          shape: RoundedRectangleBorder(
                            
                          ),
                        ),
                        onPressed: () {
                            Navigator.pushNamed(context, '/historico', arguments: email); /// leva pra outra tela
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

                    /// ------ Lista de gastos ------
                    SizedBox(
                      height: 400, // define altura para evitar overflow
                      child: FutureBuilder<List<dynamic>>(
                        future: _gastosFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return const Center(
                                child: Text("Erro ao carregar os gastos."));
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(
                                child: Text("Nenhum gasto encontrado."));
                          }

                          final gastos = snapshot.data!;

                          return ListView.builder(
                            itemCount: gastos.length,
                            itemBuilder: (context, index) {
                              final gasto = gastos[index];
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
                                  leading: const Icon(Icons.attach_money,
                                      color: Color(0xFF0D4590)),
                                  title: Text(
                                    gasto["descricao"] ?? "Sem descrição",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "R\$ ${gasto["valor"]}",
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
                                          Navigator.pushNamed(context, '/editarGasto', arguments: gasto); /// envia gasto para edição
                                        },
                                      ),
                                      IconButton(
                                        icon: Image.asset(
                                          'assets/images/lixeira.png',
                                          width: 22,
                                          height: 22,
                                        ),
                                        onPressed: () => _deletarGasto(gasto["idGasto"]),
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
            ),
          ],
        ),
      ),
    );
  }
}
