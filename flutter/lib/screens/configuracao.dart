import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// Tela quase pronta
/// Ainda não funciona corretamente
//

class Configuracao extends StatefulWidget {
  const Configuracao({super.key});

  @override
  State<Configuracao> createState() => _ConfiguracaoScreen();
}

class _ConfiguracaoScreen extends State<Configuracao> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  late TextEditingController _senhaController;

  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _emailController = TextEditingController();
    _senhaController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // recupera o email enviado via Navigator
    final args = ModalRoute.of(context)?.settings.arguments;
    final emailRecuperado = args is String ? args : '';

    // carrega os dados do usuário
    if (emailRecuperado.isNotEmpty) {
      carregarDadosUsuario(emailRecuperado);
    } else {
      setState(() => _carregando = false);
    }
  }

  Future<void> carregarDadosUsuario(String email) async {
    final authService = AuthService();

    final nome = await authService.buscarNomeUsuario(email);
    final senha = await authService.buscarSaldo(email);

    setState(() {
      _emailController.text = email;
      _nomeController.text = nome ?? '';
      _senhaController.text = senha ?? '';
      _carregando = false;
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _salvarAlteracoes(String emailPk) async {
    final nome = _nomeController.text;
    final email = _emailController.text;
    final senha = _senhaController.text;

    final authService = AuthService();
    bool atualizou = await authService.editar(emailPk, nome, email, senha);

    if (atualizou) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Os dados foram atualizados com sucesso!")),
      );
      Navigator.pushReplacementNamed(context, "/home", arguments: email);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao tentar atualizar os dados.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final emailRecuperado = args is String ? args : '';

    return Scaffold(
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Container(
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
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Center(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 400,
                                child: TextFormField(
                                  controller: _nomeController,
                                  decoration: const InputDecoration(
                                    labelText: "Nome",
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Este campo não pode ficar vazio.";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: 400,
                                child: TextFormField(
                                  controller: _emailController,
                                  readOnly: true,
                                  decoration: const InputDecoration(
                                    labelText: "E-mail",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: 400,
                                child: TextFormField(
                                  controller: _senhaController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    labelText: "Senha",
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Este campo não pode ficar vazio.";
                                    }
                                    if (value.length < 6) {
                                      return "A senha precisa ter no mínimo 6 caracteres.";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 80),
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _salvarAlteracoes(emailRecuperado);
                                  }
                                },
                                child: const Text(
                                  "Salvar",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 108, 153, 252),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
