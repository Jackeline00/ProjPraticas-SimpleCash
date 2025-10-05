import 'package:flutter/material.dart'; 
import '../services/auth_service.dart';

class Configuracao extends StatefulWidget{
  const Configuracao({super.key});

  @override
  State<Configuracao> createState() => _ConfiguracaoScreen();
  
}

class _ConfiguracaoScreen extends State<Configuracao> {
  /// variáveis
  



  /// métodos




  /// Tela
  /// 
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body:
        Container(
          width: double.infinity,
          height: 80,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          color: Colors.white,
          child: Stack(
            alignment: Alignment.center,
            children: [
              /// Botão de voltar (à esquerda)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Image.asset(
                    'assets/images/seta.png', /// imagem da setinha
                    width: 24,
                    height: 24,
                  ),
                  onPressed: () {
                    Navigator.pop(context); /// volta para a tela anterior
                  },
                ),
              ),

              /// texto superior
              const Center(
                child: Text(
                  "Dados pessoais",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D4590),
                  ),
                ),
              ),
            ],
          ),
        ),


    );
  }
  
}