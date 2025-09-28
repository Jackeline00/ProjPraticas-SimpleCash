import 'package:flutter/material.dart'; /// importa ferramentas e widgets do flutter úteis
import '../services/auth_service.dart'; /// importa a classe AuthService

/// Tela e classe responsáveis por criar usuário/conta
//

class Cadastro extends StatefulWidget{
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _CadastroScreen();
}

class _CadastroScreen extends State<Cadastro>{
  /// Variáveis e outras coisas 
  final _formKey = GlobalKey<FormState>();  
  final _nomeController = TextEditingController();  /// controladores de texto para capturar os 
  final _emailController = TextEditingController(); /// valores digitados
  final _senhaController = TextEditingController();
  final _saldoAtualController = TextEditingController();
  
  void _cadatro() async{ /// método que será chamado quando o botão "Criar conta" for precionado
    if (_formKey.currentState!.validate()) { /// se todos os campos foram preenchidos
      final nome = _nomeController.text;
      final email = _emailController.text;
      final senha = _senhaController.text;
      final saldoTotal = double.tryParse(_saldoAtualController.text) ?? 0.0; /// será atribuído 0.0 caso o usuário coloque algo inválido

      final authService = AuthService();
      bool sucesso = await authService.cadastro(nome, email, senha, saldoTotal);
      bool existe = await authService.existe(email);
      
      if (existe){
        const SnackBar(content: Text("O email digitado já está sendo usado em uma outra conta."));
      }
      else if (sucesso) { 
      /// aqui futuramente irá mandar para uma nova tela
      // Navigator.pushReplacementNamed(context, "/home");

      ScaffoldMessenger.of(context).showSnackBar( 
        const SnackBar(content: Text("Conta criada com sucesso!")),
      );
      } 
        else {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao criar conta. Tente novamente.")),
      );
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
                
                )
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: 400,
                child: TextFormField(
                controller: _saldoAtualController, /// pega o valor digitado
                decoration: const InputDecoration(
                  labelText: "Saldo atual",
                  border: OutlineInputBorder(),

                ),
                

                )
              ),

              const SizedBox(height: 80),
              ElevatedButton(
                onPressed: _cadatro, //// botão vai chamar a função que vai criar o usuário 
                child: const Text(
                  "Criar conta",
                  style: TextStyle(color: Color.fromARGB(255, 108, 153, 252)),
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