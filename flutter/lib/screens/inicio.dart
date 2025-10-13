import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login.dart'; // substitua pelo nome correto da sua tela de login/cadastro
import 'home.dart'; // substitua pelo nome correto da sua tela principal

void main() {
  runApp(const Inicio());
}

class Inicio extends StatelessWidget {
  const Inicio({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const CentralizedScreen(),
    );
  }
}

class CentralizedScreen extends StatefulWidget {
  const CentralizedScreen({super.key});

  @override
  State<CentralizedScreen> createState() => _CentralizedScreenState();
}

class _CentralizedScreenState extends State<CentralizedScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();

    // Pequeno delay pra exibir o splash e verificar login
    Timer(const Duration(seconds: 2), () async {
      bool logado = await _authService.estaLogado();

      if (!mounted) return; // evita erro se o widget for destruído antes

      if (logado) {
        // Usuário já está logado → vai pra home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      } else {
        // Usuário ainda não logado → vai pra tela de login/cadastro
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/porquinho_provisorio.jpg', width: 200),
            const SizedBox(height: 5),
            const Text(
              'SimpleCash',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
