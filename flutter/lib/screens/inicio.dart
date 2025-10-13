import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// Alguém faz aí
/// Essa tela vai ter o nome do aplicativo, a imagem do porquinho se existir e
/// depois de tantos segundos vai mudar sozinho para a tela de login ou cadastro

void main() {
  runApp(const Inicio());
}

class Inicio extends StatelessWidget {
  const Inicio({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const CentralizedScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CentralizedScreen extends StatefulWidget {
  const CentralizedScreen({super.key});

  @override
  State<CentralizedScreen> createState() => _CentralizedScreenState();
}

class _CentralizedScreenState extends State<CentralizedScreen> {
  @override
  void initState() {
    super.initState();

    // Espera 3 segundos antes de trocar para o login
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, "/login");
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
            const CircularProgressIndicator(), // animação enquanto carrega
          ],
        ),
      ),
    );
  }
}
