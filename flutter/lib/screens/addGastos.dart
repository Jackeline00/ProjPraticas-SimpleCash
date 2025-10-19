import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/gasto_service.dart';

class AdicionarGasto extends StatefulWidget {
  const AdicionarGasto({super.key});

  @override
  State<AdicionarGasto> createState() => _AdicionarGastoScreen();
}

class _AdicionarGastoScreen extends State<AdicionarGasto> {
  String email = '';
  int? idUsuario;

  final _formKey = GlobalKey<FormState>();

  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  final _parcelasController = TextEditingController();
  final _dataController = TextEditingController();
  final _jurosController = TextEditingController();

  int? _opcaoSelecionada; // quantidade de parcelas ou data final
  String? _frequenciaSelecionada;
  String? _tipoJuros; // '0' simples ou '1' composto
  DateTime? _dataSelecionada;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    email = args is String ? args : '';
    print("E-mail recebido: $email");

    _buscarIdUsuario();
  }

  Future<void> _buscarIdUsuario() async {
    try {
      final id = await AuthService().buscarIdUsuario(email);
      setState(() {
        idUsuario = id as int?;
      });
    } catch (e) {
      print("Erro ao buscar ID do usuário: $e");
    }
  }

  Future<void> _criarNovoGasto() async {
    if (_formKey.currentState!.validate() && idUsuario != null) {
      final valor = double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0.0;
      final descricao = _descricaoController.text;
      final repeticao = _frequenciaSelecionada ?? '1';
      final dataInicio = _dataController.text;
      final dataFinal = _opcaoSelecionada == 2 ? _dataController.text : '';
      final quantidadeDeParcelas = _opcaoSelecionada == 1 ? int.tryParse(_parcelasController.text) ?? 1 : 1;
      final juros = double.tryParse(_jurosController.text.replaceAll(',', '.')) ?? 0.0;
      final tipoJuros = _tipoJuros ?? '0';

      try {
        await GastoService().adicionarGasto(
          idUsuario!,
          'Geral', // tipo pode ser outro, se quiser criar dropdown depois
          descricao,
          valor,
          repeticao,
          dataInicio,
          dataFinal,
          quantidadeDeParcelas,
          juros,
          tipoJuros,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gasto adicionado com sucesso!')),
        );

        Navigator.pop(context); // volta para a tela anterior
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar gasto: $e')),
        );
      }
    }
  }

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? selecionada = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );

    if (selecionada != null) {
      setState(() {
        _dataSelecionada = selecionada;
        _dataController.text = DateFormat('dd/MM/yyyy').format(selecionada);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (idUsuario == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        color: Colors.white,
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              /// ------ Cabeçalho ------
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
                      onPressed: () {
                        Navigator.pushNamed(context, '/home', arguments: email);
                      },
                    ),
                  ),
                  const Center(
                    child: Text(
                      "Novo gasto",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 33, 37, 41),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// ------ Valor ------
              Text("Valor:"),
              TextFormField(
                controller: _valorController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Informe o valor';
                  return null;
                },
              ),

              const SizedBox(height: 20),

              /// ------ Descrição ------
              Text("Descrição do gasto *"),
              TextFormField(
                controller: _descricaoController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Informe a descrição';
                  return null;
                },
              ),

              const SizedBox(height: 20),

              /// ------ Frequência ------
              const Text("Frequência *"),
              RadioListTile<String>(
                title: const Text('Sem repetição'),
                value: '1',
                groupValue: _frequenciaSelecionada,
                onChanged: (value) {
                  setState(() {
                    _frequenciaSelecionada = value;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Mensal'),
                value: '2',
                groupValue: _frequenciaSelecionada,
                onChanged: (value) {
                  setState(() {
                    _frequenciaSelecionada = value;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Semanal'),
                value: '3',
                groupValue: _frequenciaSelecionada,
                onChanged: (value) {
                  setState(() {
                    _frequenciaSelecionada = value;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Diário'),
                value: '4',
                groupValue: _frequenciaSelecionada,
                onChanged: (value) {
                  setState(() {
                    _frequenciaSelecionada = value;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Personalizada'),
                value: '5',
                groupValue: _frequenciaSelecionada,
                onChanged: (value) {
                  setState(() {
                    _frequenciaSelecionada = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              /// ------ Data de início ------
              Text("Data de início *"),
              TextFormField(
                controller: _dataController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Data',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                onTap: () => _selecionarData(context),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Informe a data';
                  return null;
                },
              ),

              const SizedBox(height: 20),

              /// ------ Quantidade de parcelas / Data final ------
              Column(
                children: [
                  RadioListTile<int>(
                    title: const Text('Quantidade de parcelas'),
                    value: 1,
                    groupValue: _opcaoSelecionada,
                    onChanged: (value) {
                      setState(() {
                        _opcaoSelecionada = value;
                      });
                    },
                  ),
                  if (_opcaoSelecionada == 1)
                    TextFormField(
                      controller: _parcelasController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                  RadioListTile<int>(
                    title: const Text('Data final'),
                    value: 2,
                    groupValue: _opcaoSelecionada,
                    onChanged: (value) {
                      setState(() {
                        _opcaoSelecionada = value;
                      });
                    },
                  ),
                  if (_opcaoSelecionada == 2)
                    TextFormField(
                      controller: _dataController,
                      readOnly: true,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      onTap: () => _selecionarData(context),
                    ),
                ],
              ),

              const SizedBox(height: 20),

              /// ------ Juros ------
              Text("Juros"),
              TextFormField(
                controller: _jurosController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}')),
                ],
              ),

              const SizedBox(height: 20),

              /// ------ Tipo de juros ------
              const Text("Tipo do juros"),
              RadioListTile<String>(
                title: const Text('Simples'),
                value: '0',
                groupValue: _tipoJuros,
                onChanged: (value) {
                  setState(() {
                    _tipoJuros = value;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Composto'),
                value: '1',
                groupValue: _tipoJuros,
                onChanged: (value) {
                  setState(() {
                    _tipoJuros = value;
                  });
                },
              ),

              const SizedBox(height: 30),

              /// ------ Botão Criar ------
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _criarNovoGasto,
                    child: const Text('Criar'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
