import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/gasto_service.dart';

class EditarGasto extends StatefulWidget {
  const EditarGasto({super.key});

  @override
  State<EditarGasto> createState() => _EditarGastoScreen();
}

class _EditarGastoScreen extends State<EditarGasto> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _tipoController;
  late TextEditingController _descricaoController;
  late TextEditingController _valorController;
  late TextEditingController _dataInicioController;
  late TextEditingController _dataFinalController;
  late TextEditingController _repeticaoController;
  late TextEditingController _intervaloDiasController;
  late TextEditingController _quantidadeDeParcelasController;
  late TextEditingController _jurosController;
  late TextEditingController _tipoJurosController;

  bool _carregando = true;
  late String emailPk; // email original (chave primária)

  bool _senhaVisivel = false;

  @override
  void initState() {
    super.initState();
    _tipoController = TextEditingController();
    _descricaoController = TextEditingController();
    _valorController = TextEditingController();
    _dataInicioController = TextEditingController();
    _dataFinalController = TextEditingController(); 
    _repeticaoController = TextEditingController(); 
    _intervaloDiasController = TextEditingController(); 
    _quantidadeDeParcelasController = TextEditingController(); 
    _jurosController = TextEditingController(); 
    _tipoJurosController = TextEditingController();

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
          _tipoController.text = dados['email'] ?? '';
          _descricaoController.text = dados['nome'] ?? '';
          _valorController.text = ''; // deixa em branco

          /// ...
          /// ...
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
    _tipoController.dispose();
    _descricaoController.dispose();
    _valorController.dispose();
    /// ...
    super.dispose();
  }

  /// Atualiza os dados no backend
  void _salvarAlteracoes() async {
    if (!_formKey.currentState!.validate()) return;

    final nome = _tipoController.text;
    final email = _descricaoController.text;
    final senha = _valorController.text; // se vazio, backend não altera

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
                                  controller: _tipoController,
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
                                  controller: _descricaoController,
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
                                  controller: _valorController,
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
                              /// . . .

                              /// ------------ Botão de salvar --------------
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
