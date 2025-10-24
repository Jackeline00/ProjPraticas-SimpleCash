import 'package:flutter/material.dart'; /// importa ferramentas e widgets do flutter úteis
import '../services/auth_service.dart'; /// importa a classe AuthService

class Login extends StatefulWidget { /// tela que pode mudar seu estado interno
  const Login({super.key});

  @override
  State<Login> createState() => _LoginScreen();
}


class _LoginScreen extends State<Login> {
  final _formKey = GlobalKey<FormState>();          
  final _emailController = TextEditingController(); 
  final _senhaController = TextEditingController(); 

  bool _senhaVisivel = false; // controla se a senha está visível

  void _login() async { 
    if (_formKey.currentState!.validate()) { 
      final email = _emailController.text;
      final senha = _senhaController.text;

      final authService = AuthService(); 
      bool sucesso = await authService.login(email, senha); 

      if (sucesso) { 
        ScaffoldMessenger.of(context).showSnackBar( 
          const SnackBar(content: Text("Login realizado com sucesso!")),
        );
        Navigator.pushReplacementNamed(
          context,
          "/home",
          arguments: email 
        );

      } else { 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email ou senha incorretos.")),
        );
      }
    }
  }

  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      appBar: AppBar(
        centerTitle: true, 
        title: const Text(
          "Login",
          style: TextStyle( 
            color: Color.fromARGB(255, 13, 69, 144),
            fontSize: 30
          ),
        )
      ), 
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController, 
                decoration: const InputDecoration(
                  labelText: "E-mail",
                  border: OutlineInputBorder(),
                ),
                validator: (value) { 
                  if (value == null || value.isEmpty) { 
                    return "Digite seu e-mail"; 
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _senhaController, 
                obscureText: !_senhaVisivel, // usa a variável de visibilidade
                decoration: InputDecoration(
                  labelText: "Senha",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _senhaVisivel ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _senhaVisivel = !_senhaVisivel;
                      });
                    },
                  ),
                ),
                validator: (value) { 
                  if (value == null || value.isEmpty) { 
                    return "Digite sua senha";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _login, 
                child: const Text("Entrar"),
              ),
              TextButton(
                onPressed: () {
                  print("indo para a tela de cadastro...");
                  Navigator.pushNamed(context, '/cadastro'); 
                },
                child: const Text(
                  "Ainda não tem uma conta? Fazer cadastro",
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}