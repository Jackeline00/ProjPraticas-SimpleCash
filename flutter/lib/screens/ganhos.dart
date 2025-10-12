import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/ganho_service.dart'; // serviço que faz a requisição GET

/// Tela em fase de testes
//

class Ganhos extends StatefulWidget {
  const Ganhos({super.key});

  @override
  State<Ganhos> createState() => _GanhosScreen();
}

class _GanhosScreen extends State<Ganhos> {
  late Future<List<dynamic>> _gastosFuture; /// lista futura de ganhos
  late String email;
  late int idUsuario;

  /// método de buscar dados
  void carregarIdUsuario(String email) async {
    final authService = AuthService();
    final id = await authService.buscarIdUsuario(email);
    setState(() {
      idUsuario = id as int;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Recupera o email passado via Navigator (só é possível aqui, pois o context já existe)
    final args = ModalRoute.of(context)?.settings.arguments;
    email = args is String ? args : '';

    // Chama o método de busca no service
    final service = GanhoService();
    _gastosFuture = service.mostrarGanhos(idUsuario) as Future<List>;
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
                    "Ganhos",
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

            /// ------ Botão novo ganho ------
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
                    /// Navigator.pushNamed(context, '/adicionarGasto', arguments: email); /// leva pra outra tela
                  },
                  child: const Text(
                    "Novo ganho +",
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
                  /// TODO: ação do botão "Acessar histórico"
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

            /// ------ Lista de ganhos ------
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _gastosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(
                        child: Text("Erro ao carregar os ganhos."));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text("Nenhum ganho encontrado."));
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
                                  // TODO: ação para editar o ganho
                                },
                              ),
                              IconButton(
                                icon: Image.asset(
                                  'assets/images/lixeira.png',
                                  width: 22,
                                  height: 22,
                                ),
                                onPressed: () {
                                  // TODO: ação para excluir o ganho
                                },
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
