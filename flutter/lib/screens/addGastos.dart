import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/gasto_service.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

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
  final _dataInicioController = TextEditingController();
  final _dataFinalController = TextEditingController();
  final _jurosController = TextEditingController();

  int? _opcaoSelecionada; 
  String? _frequenciaSelecionada;
  String? _tipoJuros;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // recupera o email da rota, igual à tela de Gastos
    final args = ModalRoute.of(context)?.settings.arguments;
    email = args is String ? args : '';
    print("E-mail recebido: $email");

    _buscarIdUsuario();
  }

  Future<void> _buscarIdUsuario() async {
    try {
      final id = await AuthService().buscarIdUsuario(email);
      if (mounted) {
        setState(() {
          idUsuario = id;
        });
      }
    } catch (e) {
      print("Erro ao buscar ID do usuário: $e");
    }
  }

  Future<void> _selecionarData(BuildContext context, TextEditingController controller) async {
    try {
      final DateTime? selecionada = await showDatePicker(
        context: context, // ← usa o context normal, não o rootNavigator
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        helpText: 'Selecione uma data',
        cancelText: 'Cancelar',
        confirmText: 'Confirmar',
        locale: const Locale('pt', 'BR'),
      );

      if (selecionada != null) {
        setState(() {
          controller.text = DateFormat('dd/MM/yyyy').format(selecionada);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao abrir calendário: $e')),
      );
    }
  }

  String converterParaSql(String dataBR) {
    final partes = dataBR.split('/');
    final dia = partes[0];
    final mes = partes[1];
    final ano = partes[2];
    return "$ano-$mes-$dia"; // yyyy-MM-dd
  }

  Future<void> _criarNovoGasto() async {
    if (_formKey.currentState!.validate() && idUsuario != null) {
      final valor = double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0.0;
      final descricao = _descricaoController.text;
      final repeticao = _frequenciaSelecionada ?? '1';
      final dataInicio = _dataInicioController.text;
      final dataFinal = _opcaoSelecionada == 2 ? _dataFinalController.text : '';
      final dataInicioSql = converterParaSql(dataInicio);
      final dataFinalSql = dataFinal.isNotEmpty ? converterParaSql(dataFinal) : null;

      final quantidadeDeParcelas = _opcaoSelecionada == 1 ? int.tryParse(_parcelasController.text) ?? 1 : 1;
      final juros = double.tryParse(_jurosController.text.replaceAll(',', '.')) ?? 0.0;
      final tipoJuros = _tipoJuros ?? '0';

      try {
        await GastoService().adicionarGasto(
          idUsuario!,
          'Geral',
          descricao,
          valor,
          repeticao,
          dataInicioSql,
          dataFinal,
          quantidadeDeParcelas,
          juros,
          tipoJuros,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gasto adicionado com sucesso!')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar gasto: $e')),
        );
      }
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
      body: SafeArea(
        child: Container(
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
                          Navigator.pushNamed(context, '/gastos', arguments: email);
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
                const Text(
                  "Valor *",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),

                TextFormField(
                  controller: _valorController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Ex: 25.90',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe o valor';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                /// ------ Descrição ------
                const Text("Descrição *"),
                TextFormField(
                  controller: _descricaoController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe a descrição';
                    }
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
                    setState(() => _frequenciaSelecionada = value);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Mensal'),
                  value: '2',
                  groupValue: _frequenciaSelecionada,
                  onChanged: (value) {
                    setState(() => _frequenciaSelecionada = value);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Semanal'),
                  value: '3',
                  groupValue: _frequenciaSelecionada,
                  onChanged: (value) {
                    setState(() => _frequenciaSelecionada = value);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Diário'),
                  value: '4',
                  groupValue: _frequenciaSelecionada,
                  onChanged: (value) {
                    setState(() => _frequenciaSelecionada = value);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Personalizada'),
                  value: '5',
                  groupValue: _frequenciaSelecionada,
                  onChanged: (value) {
                    setState(() => _frequenciaSelecionada = value);
                  },
                ),

                const SizedBox(height: 20),

                /// ------ Data de início ------
                const Text("Data de início *"),
                TextFormField(
                  controller: _dataInicioController,
                  keyboardType: TextInputType.datetime,
                  decoration: const InputDecoration(
                    labelText: 'Data',
                    prefixIcon: Icon(Icons.calendar_today),
                    hintText: 'Ex: 13/11/2025',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe uma data';
                    }

                    // Expressão regular para validar formato dd/mm/aaaa
                    final regex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
                    if (!regex.hasMatch(value)) {
                      return 'Use o formato dd/mm/aaaa';
                    }

                    return null;
                  },
                ),


                const SizedBox(height: 20),

                /// ------ Parcelas / Data Final ------
                Column(
                  children: [
                    RadioListTile<int>(
                      title: const Text('Quantidade de parcelas'),
                      value: 1,
                      groupValue: _opcaoSelecionada,
                      onChanged: (value) {
                        setState(() => _opcaoSelecionada = value);
                      },
                    ),
                    if (_opcaoSelecionada == 1)
                      TextFormField(
                        controller: _parcelasController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration:
                            const InputDecoration(border: OutlineInputBorder()),
                      ),
                    RadioListTile<int>(
                      title: const Text('Data final'),
                      value: 2,
                      groupValue: _opcaoSelecionada,
                      onChanged: (value) {
                        setState(() => _opcaoSelecionada = value);
                      },
                    ),
                    if (_opcaoSelecionada == 2)
                     if (_opcaoSelecionada == 2)
                    if (_opcaoSelecionada == 2)
                    TextFormField(
                      controller: _dataFinalController,
                      keyboardType: TextInputType.datetime,
                      decoration: const InputDecoration(
                        labelText: 'Data final',
                        hintText: 'Ex: 13/11/2025',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (_opcaoSelecionada != 2) return null; 
                        if (value == null || value.isEmpty) {
                          return 'Informe uma data final';
                        }

                        final regex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
                        if (!regex.hasMatch(value)) {
                          return 'Use o formato dd/mm/aaaa';
                        }

                        final partes = value.split('/');
                        final dia = int.tryParse(partes[0]) ?? 0;
                        final mes = int.tryParse(partes[1]) ?? 0;
                        final ano = int.tryParse(partes[2]) ?? 0;

                        if (dia < 1 || dia > 31) return 'Dia inválido';
                        if (mes < 1 || mes > 12) return 'Mês inválido';
                        if (ano < 1900) return 'Ano inválido';

                        return null;
                      },
                    ),


                  ],
                ),

                const SizedBox(height: 20),

                /// ------ Juros ------
                const Text("Juros"),
                TextFormField(
                  controller: _jurosController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}')),
                  ],
                ),

                const SizedBox(height: 20),

                /// ------ Tipo de juros ------
                const Text("Tipo de juros"),
                RadioListTile<String>(
                  title: const Text('Simples'),
                  value: '0',
                  groupValue: _tipoJuros,
                  onChanged: (value) {
                    setState(() => _tipoJuros = value);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Composto'),
                  value: '1',
                  groupValue: _tipoJuros,
                  onChanged: (value) {
                    setState(() => _tipoJuros = value);
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
      ),
    );
  }
}

