import 'package:flutter/material.dart';

/// Tela iniciada, mas ainda falta tudo
//

class Historico extends StatefulWidget{
  const Historico({super.key});

  @override
  State<Historico> createState() => _HistoricoScreen();
}

class _HistoricoScreen extends State<Historico>{
  //
  @override
  Widget build(BuildContext context){
    return Scaffold(

      body:Container(
        width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              color: Colors.white,
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: Image.asset(
                            'assets/images/seta.png',
                            width: 24,
                            height: 24,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const Center(
                        child: Text(
                          "Histórico",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D4590),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  Row(children: [
                    ElevatedButton(
                      onPressed: () {
                       ///// o que vai acontecer ao precionar o botão "Filtrar"
                      },
                      child: const Text(
                        "Filtrar",
                        style: TextStyle(
                          color: Color.fromARGB(255, 108, 153, 252),
                        ),
                      ),
                    ),
                  ],
                  ),

                  const SizedBox(height: 40),

                  Row(children: [
                    /// onde aparecerão os filtros selecionados se existirem
                    ],
                  ),


                  const SizedBox(height: 40),

                  

                ],
              ),
            ),
      );

  }
}