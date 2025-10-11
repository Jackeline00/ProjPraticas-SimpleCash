import 'package:flutter/material.dart';

/// Tela iniciada, mas ainda falta tudo 
//

class Gastos extends StatefulWidget{
  const Gastos({super.key});

  @override
  State<Gastos> createState() => _GastosScreen();
}

class _GastosScreen extends State<Gastos>{
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
                          "Gastos",
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
                        "Novo gasto +",
                        style: TextStyle(
                          color: Color.fromARGB(255, 13, 69, 144),
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

                  Row(children: [
                    Center(child: 
                         ElevatedButton(
                          onPressed: () {
                          ///// o que vai acontecer ao precionar o botão "Filtrar"
                          },
                          child: const Text(
                            "Acessar histórico",
                            style: TextStyle(
                              color: Color.fromARGB(255, 13, 69, 144),
                            ),
                          ),
                        ),
                      )

                    ],
                  ),

                  const SizedBox(height: 40),

                  Column(
                    children: [
                      /// onde aparecerá a lista dos gastos
                    ],
                  )

                ],
              ),
            ),
      );

  }
}