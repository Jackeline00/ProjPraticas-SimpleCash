import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// Tela funcionando corretamente
/// Falta:
/// 1 - Design visual igual ao figma e/ou com as cores do app
/// 2 - Revisar o código
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
  late String emailPk; // email original (chave primária)

  bool _senhaVisivel = false;

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

    if (emailRecuperado.isNotEmpty) {
      emailPk = emailRecuperado; // guarda o email original
      carregarDadosUsuario(emailRecuperado);
    } else {
      setState(() => _carregando = false);
    }
  }

  /// Busca os dados atuais do usuário e preenche nome e e-mail
  Future<void> carregarDadosUsuario(String email) async {
    try {
      final authService = AuthService();
      final dados = await authService.buscarDadosUsuario(email);

      if (dados != null) {
        setState(() {
          _emailController.text = dados['email'] ?? '';
          _nomeController.text = dados['nome'] ?? '';
          _senhaController.text = ''; // deixa em branco
          _carregando = false;
        });
      } else {
        setState(() => _carregando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Não foi possível carregar os dados.")),
        );
      }
    } catch (e) {
      setState(() => _carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao carregar dados: $e")),
      );
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  /// Atualiza os dados no backend
  void _salvarAlteracoes() async {
    if (!_formKey.currentState!.validate()) return;

    final nome = _nomeController.text;
    final email = _emailController.text;
    final senha = _senhaController.text; // se vazio, backend não altera

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
                                  decoration: const InputDecoration(
                                    labelText: "E-mail",
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Este campo não pode ficar vazio.";
                                    }
                                    if (!value.contains("@") || !value.contains(".")) {
                                      return "Digite um e-mail válido.";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: 400,
                                child: TextFormField(
                                  controller: _senhaController,
                                  obscureText: !_senhaVisivel,
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
                                    if (value != null && value.isNotEmpty && value.length < 6) {
                                      return "A senha precisa ter no mínimo 6 caracteres.";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 80),
                              ElevatedButton(
                                onPressed: _salvarAlteracoes,
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
