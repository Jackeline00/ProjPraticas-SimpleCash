import 'package:flutter/material.dart';
import 'package:frontend/screens/addGastos.dart';
import 'package:frontend/screens/editarGanhos.dart';
import 'package:frontend/screens/historico.dart';
import 'package:frontend/screens/poupanca.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'screens/login.dart';
import 'screens/cadastro.dart';
import 'screens/home.dart';
import 'screens/configuracao.dart';
import 'screens/gastos.dart';
import 'screens/ganhos.dart';
import 'screens/inicio.dart';
import "screens/editarGastos.dart";
import "screens/addGanhos.dart";
import "screens/addDeposito.dart";

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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'), // Suporte ao Português do Brasil
        Locale('en', 'US'), // Suporte ao Inglês (bom ter por padrão)
      ],

      /// tira o DEBUG das telas na execução
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.interTextTheme(
          /// fonte usada em todo o app
          Theme.of(context).textTheme,
        ),
      ),
      home: Inicio(), 

      routes: {
        "/login": (context) => const Login(),
        "/cadastro": (context) => const Cadastro(),
        "/home": (context) => const Home(),
        "/configuracao": (context) => const Configuracao(),
        "/gastos": (context) => const Gastos(),
        "/adicionarGasto":(context) => const AdicionarGasto(),
        "/editarGasto": (context) => const EditarGasto(),
        "/ganhos": (context) => const Ganhos(),
        "/poupanca": (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            final email = args is String ? args : ''; 
            return Poupanca(email: email);
        },
        "/adicionarDeposito": (context) { 
          final args = ModalRoute.of(context)?.settings.arguments;
          // O argumento é o idUsuario (int), conforme enviado pela tela Poupança
          final idUsuario = args is int ? args : 0; 
          return AdicionarDeposito(idUsuario: idUsuario);
        },
        "/historico": (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final email = args is String ? args : '';
          // Agora o construtor ACEITA o email
          return Historico(email: email); 
        },
        "/adicionarGanho": (context) => const AdicionarGanho(),
        "/editarGanho": (context) => const EditarGanho(),
      
      },
    );
  }
}
