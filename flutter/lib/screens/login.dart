import 'package:flutter/material.dart'; /// importa ferramentas e widgets do flutter úteis
import '../services/auth_service.dart'; /// importa a classe AuthService

class Login extends StatefulWidget { /// tela que pode mudar seu estado interno
  const Login({super.key});

  @override
  State<Login> createState() => _LoginScreen();
}

class _LoginScreen extends State<Login> {
  final _formKey = GlobalKey<FormState>();          /// chave global que vai validar os campos
  final _emailController = TextEditingController(); // controladores de texto para capturar os 
  final _senhaController = TextEditingController(); // valores digitados

  void _login() async { // método chamado quando o botão Entrar for precionado
    if (_formKey.currentState!.validate()) { /// verifica se todos os campos foram preenchidos corretamente
      final email = _emailController.text;
      final senha = _senhaController.text;

      final authService = AuthService(); /// instância da classe AuthService
      bool sucesso = await authService.login(email, senha); /// chama o método login dessa classe

      if (sucesso) { 
        /// se o login estiver correto
        ScaffoldMessenger.of(context).showSnackBar( 
          const SnackBar(content: Text("Login realizado com sucesso!")),
        );
        /// aqui irá mandar para a tela Home
        Navigator.pushReplacementNamed(
          context,
          "/home",
          arguments: email, /// parâmetro: email será passado para a tela home
        );

      } else { // falha no login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email ou senha incorretos.")),
        );
      }
    }
  }

  @override 
  Widget build(BuildContext context) { /// início da criação da tela
    return Scaffold( /// layout base da tela
      appBar: AppBar(
        centerTitle: true, /// deixa o título centralizado
        title: const Text(
          "Login",
          style: TextStyle( /// estilo do título Login
            color: Color.fromARGB(255, 13, 69, 144),
            fontSize: 30
        ),
      )), /// título principal
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
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
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _senhaController, /// pega a senha digitada
                decoration: const InputDecoration(
                  labelText: "Senha",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) { /// valida a senha
                  if (value == null || value.isEmpty) { /// verifica se o campo não está vazio
                    return "Digite sua senha";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _login, /// botão chama a função _login ao ser precionado
                child: const Text("Entrar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}