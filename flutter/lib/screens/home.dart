import 'package:flutter/material.dart'; 
import '../services/auth_service.dart'; 

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
      saldoAtual = saldo;
    });
  }

  /// tela
  @override
  Widget build(BuildContext context) {
    /// recupera o email passado via Navigator
    final email = ModalRoute.of(context)!.settings.arguments as String;

    /// chama o método passando o email
    if (nomeUsuario == null) {
      carregarNomeUsuario(email);
    }
    return Scaffold( 
      /// Cabeçalho da tela
      //
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // espaçamento geral
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ícone de configurações no topo direito
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Image.asset(
                    'assets/images/engrenagem.png', /// caminho da futura imagem
                    width: 28,
                    height: 28,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/configuracao'); /// leva pra outra tela
                  },
                ),
              ),

              const SizedBox(height: 10),

              /// Linha com nome do app e saudação
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
                  Text(
                    nomeUsuario != null ? "Olá, $nomeUsuario" : "Olá, usuário",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF8EC1F3),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              /// Corpo da tela 
              /// 
              
            




            ],
          ),
        ),
      ),
    );
  }
}