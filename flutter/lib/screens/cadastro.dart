import 'package:flutter/material.dart'; /// importa ferramentas e widgets do flutter úteis
import 'package:flutter/services.dart';
import '../services/auth_service.dart'; /// importa a classe AuthService

/// Tela e classe responsáveis por criar usuário/conta
/// Tela funcionando corretamente, mas o design não está correto
//

class Cadastro extends StatefulWidget{
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _CadastroScreen();
}

class _CadastroScreen extends State<Cadastro>{
  /// Controladores de texto para capturar os valores digitados 
  final _formKey = GlobalKey<FormState>();  
  final _nomeController = TextEditingController();  
  final _emailController = TextEditingController(); 
  final _senhaController = TextEditingController();
  final _saldoAtualController = TextEditingController();
  
  // Método
  void _cadastro() async{ /// método que será chamado quando o botão "Criar conta" for precionado
    if (_formKey.currentState!.validate()) { /// se todos os campos foram preenchidos
      final nome = _nomeController.text;
      final email = _emailController.text;
      final senha = _senhaController.text;
      final saldoTotal = double.tryParse(_saldoAtualController.text) ?? 0.0; /// será atribuído 0.0 caso o usuário coloque algo inválido

      final authService = AuthService();
      bool existe = await authService.existe(email);

      if (existe){
        const SnackBar(content: Text("O email digitado já está sendo usado em uma outra conta."));
      }
      else{ 
        bool sucesso = await authService.cadastro(nome, email, senha, saldoTotal);

        if(sucesso){
          ScaffoldMessenger.of(context).showSnackBar( 
            const SnackBar(content: Text("Conta criada com sucesso!")),
          );

          /// aqui irá mandar para a tela Home
          Navigator.pushReplacementNamed(
            context,
            "/home",
            arguments: email /// parâmetro: email será passado para a tela home
          );
        } 
        else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Erro ao criar conta. Tente novamente.")),
          );
        }
      }
    }
  }


  /// design visual da tela
  @override 
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, /// deixa o título centralizado
        title: const Text(
          "Cadastro",
          style: TextStyle( /// estilo do título Login
            color: Color.fromARGB(255, 13, 69, 144),
            fontSize: 40,
            fontFamily: 'Arial'
        ),
        )
      ),
      body:Padding(
        padding: const EdgeInsets.all(4.0),
        child: Center(child: 
          Form(
          key: _formKey, 
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
              SizedBox(
                width: 400,
                child: TextFormField(
                controller: _nomeController, /// pega o valor digitado
                decoration: const InputDecoration(
                  labelText: "Nome",
                  border: OutlineInputBorder(),
                ),
                validator: (value) { /// valida o nome
                  if (value == null || value.isEmpty) { /// verifica se ele foi digitado corretamente
                    return "Digite seu nome"; 
                  }
                  return null;
                },

                )
              ),
              
              const SizedBox(height: 16),

              SizedBox(
                width: 400,
                child: TextFormField(
                controller: _emailController, /// pega o valor digitado
                decoration: const InputDecoration(
                  labelText: "E-mail",
                  border: OutlineInputBorder(),
                ),

                validator: (value) { /// valida o email
                  if (value == null || value.isEmpty) { /// verifica se ele foi digitado corretamente
                    return "Digite seu e-mail"; 
                  }
                  return null;
                },
                
                )
              ),
              
              const SizedBox(height: 16),
              
              SizedBox(
                width: 400,
                child: TextFormField(
                controller: _senhaController, /// pega a senha digitada
                decoration: const InputDecoration(
                  labelText: "Senha",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) { /// valida a senha
                  if (value == null || value.isEmpty) { /// verifica se ela foi digitada corretamente
                    return "Digite sua senha"; 
                  }
                  if (value.length < 6){
                    return "A senha precisa ter no mínimo 6 caracteres";
                  }
                  return null;
                },
                
                )
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: 400,
                child: TextFormField(
                controller: _saldoAtualController, /// pega o valor digitado
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')), /// faz esse campo aceitar somente números do tipo 20.0
                ],
                decoration: const InputDecoration(
                  labelText: "Saldo atual",
                  border: OutlineInputBorder(),
                ),

                validator: (value) { /// valida o saldo
                  if (value == null || value.isEmpty) { /// verifica se ele foi digitado corretamente
                    return "Por favor, digite seu saldo atual (seu saldo inicial pode ser 0.0)"; 
                  }
                  if (double.tryParse(value) == null) { /// verifica se ele é um número 
                    return 'Por favor, digite um número válido';
                  }
                  else{
                    return null;
                  }
                },

                )
              ),

              const SizedBox(height: 80),
              ElevatedButton(
                onPressed: _cadastro, //// botão vai chamar a função que vai criar o usuário 
                child: const Text(
                  "Criar conta",
                  style: TextStyle(color: Color.fromARGB(255, 108, 153, 252)),
                ),
                  
              ),


               /// ----------- Link para a tela de login ------------
              TextButton(
                onPressed: () {
                  print("indo para a tela de login...");
                  Navigator.pushNamed(context, '/login'); /// rota da tela de cadastro
                },
                child: const Text(
                  "Já tem uma conta? Fazer login",
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline, // opcional
                  ),
                ),
              ),
            ],
          ),
          )
        ),
      )
    );
  }
}