import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'screens/cadastro.dart';
import 'screens/home.dart';
import 'screens/configuracao.dart';
import 'screens/gastos.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SimpleCash',
      debugShowCheckedModeBanner: false, /// tira o DEBUG das telas na execução
      theme: ThemeData(
        primarySwatch: Colors.blue,
        /// fontFamily: '',  COLOCAR AQUI A FONTE PARA TODO O APP
      ),
      initialRoute: "/gastos",        /// primeira tela que vai abrir
      
      routes: {
        "/login": (context) => const Login(),
        "/cadastro": (context) => const Cadastro(),
        "/home": (context) => const Home(),
        "/configuracao": (context) => const Configuracao(),
        "/gastos": (context) => const Gastos(),
      },
    );
  }
}
