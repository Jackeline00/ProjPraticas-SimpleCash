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

class CentralizedScreen extends StatelessWidget {
  const CentralizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // cor de fundo opcional
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // centraliza verticalmente
          crossAxisAlignment:
              CrossAxisAlignment.center, // centraliza horizontalmente
          children: [
            Image.asset(
              'assets/images/porquinho_provisorio.jpg', // caminho da imagem local
              width: 200, // tamanho opcional
            ),
            const SizedBox(height: 5), // espaçamento entre imagem e texto
            const Text(
              'SimpleCash',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: 'Arial',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
