import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
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
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Usuário ainda não logado → vai pra tela de login
        Navigator.pushReplacementNamed(context, '/login');
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
