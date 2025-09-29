import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'screens/cadastro.dart';

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
        /// fontFamily: 'MyFont',  COLOCAR AQUI A FONTE PARA TODO O APP
      ),
      initialRoute: "/login",
      routes: {
        "/login": (context) => const Login(),
        //"/cadastro": (context) => const Cadastro(),
      },
    );
  }
}
