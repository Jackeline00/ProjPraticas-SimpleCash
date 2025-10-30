import 'package:flutter/material.dart'; 
import '../services/auth_service.dart'; 

/// Tela funcionando corretamente
/// Falta: Design, imagens, tirar a faixa amarela da parte de baixo

class Home extends StatefulWidget{
  const Home({super.key});

  @override
  State<Home> createState() => _HomeScreen();
}

class _HomeScreen extends State<Home>{
  /// variáveis
  String? nomeUsuario;
  double? saldoAtual;

  /// métodos de buscar dados
  void carregarNomeUsuario(String email) async {
    final authService = AuthService();
    final nome = await authService.buscarNomeUsuario(email);
    setState(() {
      nomeUsuario = nome;
    });
  }

  void carregarSaldoUsuario(String email) async {
    final authService = AuthService();
    final saldo = await authService.buscarSaldo(email);
    setState(() {
      saldoAtual = saldo; /// tenta converter para double 
    });
  }

  /// inicialização da tela (carrega dados uma única vez)
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final args = ModalRoute.of(context)?.settings.arguments;
      final email = args is String ? args : '';
      if (email.isNotEmpty) {
        carregarNomeUsuario(email);
        carregarSaldoUsuario(email);
      }
    });
  }

  /// tela
  @override
  Widget build(BuildContext context) {
    /// recupera o email passado via Navigator
    final args = ModalRoute.of(context)?.settings.arguments;
    final email = args is String ? args : '';

    return Scaffold( 
      /// Cabeçalho da tela
      //
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(  /// permite rolagem se o conteúdo for maior que a tela
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              /// ícone de configurações no topo direito
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "SimpleCash",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D4590),
                    ),
                  ),
                  IconButton(
                    icon: Image.asset(
                      'assets/images/engrenagem.png', /// caminho da futura imagem
                      width: 45,  /// tamanho ajustado
                      height: 45,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/configuracao', arguments: email); /// leva pra outra tela
                    },
                  ),
                ],
              ),

              const SizedBox(height: 10),

              /// Linha com nome do app e saudação
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  nomeUsuario != null ? "Olá, $nomeUsuario" : "Olá, usuário",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF8EC1F3),
                  ),
                ),
              ),


              const SizedBox(height: 20),

// ------------------------------------------------------------------------------------------------
              /// Corpo da tela 
              /// 
              Padding(
                padding: const EdgeInsets.all(32.0), /// espaçamento
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Saldo atual",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      saldoAtual != null ? "R\$ ${saldoAtual!.toStringAsFixed(2)}" : "R\$ 0,00",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D4590),
                      ),
                    ),

                  ],
                ),
              ),

//-------------------------------------------------------------------------------------------------
              /// Linha ou divisão
              ///
              const Divider(
                color: Colors.grey,     
                thickness: 1,            /// espessura da linha
                height: 20,              /// altura do espaço vertical em volta da linha
                indent: 0,               /// recuo da esquerda
                endIndent: 0,            /// recuo da direita
              ),

              Center(
                child:
                Padding(padding: const EdgeInsets.all(32.0),
                  child:  
                  Column(
                    children: [    
                      SizedBox(
                        width: 200,
                        child: /// largura fixa para todos os botões
                          ElevatedButton(
                            onPressed: () {  /// ação ao clicar
                              Navigator.pushNamed(context, '/gastos', arguments: email); /// manda para a tela de gastos
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D4590), /// cor de fundo
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12), /// deixa as bordas arredondadas
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), /// tamanho do botão
                            ),
                            child: const Text(
                              "Gastos",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white, /// cor do texto
                              ),
                            ),
                          ),
                      ),

                      const SizedBox(height: 14), 

                      SizedBox(
                        width: 200,
                        child: /// largura fixa para todos os botões
                          ElevatedButton(
                            onPressed: () {/// ação ao clicar
                              Navigator.pushNamed(context, '/ganhos', arguments: email); /// envia para a tela de ganhos
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D4590), /// cor de fundo
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12), /// deixa as bordas arredondadas
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), /// tamanho do botão
                            ),
                            child: const Text(
                              "Ganhos",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white, /// cor do texto
                              ),
                            ),
                          ),
                      ),

                      const SizedBox(height: 14), 

                      SizedBox(
                        width: 200,
                        child: /// largura fixa para todos os botões
                          ElevatedButton(
                            onPressed: () {/// ação ao clicar
                              Navigator.pushNamed(context, '/poupanca', arguments: email); /// envia para a tela de poupanças
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D4590), /// cor de fundo
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12), /// deixa as bordas arredondadas
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), /// tamanho do botão
                            ),
                            child: const Text(
                              "Poupanças",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white, /// cor do texto
                              ),
                            ),
                          ),
                      ),

                      const SizedBox(height: 18), 

                      SizedBox(
                        width: 200,
                        child: /// largura fixa para todos os botões
                          ElevatedButton(
                            onPressed: () {/// ação ao clicar
                              Navigator.pushNamed(context, '/relatorio'); // manda para a tela de relatorios
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white, /// cor de fundo
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12), /// deixa as bordas arredondadas
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), /// tamanho do botão
                            ),
                            child: const Text(
                              "Relatórios",
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF0D4590), /// cor do texto
                              ),
                            ),
                          ),
                      ),

                      const SizedBox(height: 14), 

                      SizedBox(
                        width: 200,
                        child: /// largura fixa para todos os botões
                          ElevatedButton(
                            onPressed: () {/// ação ao clicar
                              Navigator.pushNamed(context, '/historico', arguments: email); /// manda para a tela de histórico
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white, /// cor de fundo
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12), /// deixa as bordas arredondadas
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), /// tamanho do botão
                            ),
                            child: const Text(
                              "Histórico",
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF0D4590), /// cor do texto
                              ),
                            ),
                          )
                      )

                    ],
                    )
                  ),
              )
            ],
          ),
        ),
      ),
    ),
    );
  }
}
