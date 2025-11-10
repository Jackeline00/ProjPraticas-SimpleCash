import 'package:flutter/material.dart';
import 'package:frontend/screens/addGastos.dart';
import 'package:frontend/screens/historico.dart';
import 'package:frontend/screens/poupanca.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login.dart';
import 'screens/cadastro.dart';
import 'screens/home.dart';
import 'screens/configuracao.dart';
import 'screens/gastos.dart';
import 'screens/ganhos.dart';
import 'screens/inicio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SimpleCash',
      debugShowCheckedModeBanner: false,

      /// tira o DEBUG das telas na execução
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.interTextTheme(
          /// fonte usada em todo o app
          Theme.of(context).textTheme,
        ),
      ),
      home: Inicio(), 
      //initialRoute: '/login', /// tela para testes

      routes: {
        "/login": (context) => const Login(),
        "/cadastro": (context) => const Cadastro(),
        "/home": (context) => const Home(),
        "/configuracao": (context) => const Configuracao(),
        "/gastos": (context) => const Gastos(),
        "/adicionarGasto":(context) => const AdicionarGasto(),
        "/ganhos": (context) => const Ganhos(),
        //"/poupanca": (context) => const Poupanca(),
        "/historico": (context) => const Historico(),
      },
    );
  }
}
