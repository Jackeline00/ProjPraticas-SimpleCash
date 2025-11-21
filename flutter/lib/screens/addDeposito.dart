// Em flutter/lib/screens/addDeposito.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/poupanca_service.dart';

class AdicionarDeposito extends StatefulWidget { 
  final int idUsuario;
  const AdicionarDeposito({super.key, required this.idUsuario});

  @override
  State<AdicionarDeposito> createState() => _AdicionarDepositoScreen();
}

class _AdicionarDepositoScreen extends State<AdicionarDeposito> {
  
  late final int idUsuario = widget.idUsuario; 

  final _formKey = GlobalKey<FormState>();

  // NOVO: Objetivo (Descrição)
  final _objetivoController = TextEditingController(); 
  // NOVO: Origem (Antiga Fonte)
  final _origemController = TextEditingController(); 
  final _valorController = TextEditingController();

  // Controladores para UI (Não essenciais para o save do Depósito)
  final _parcelasController = TextEditingController();
  final _dataInicioController = TextEditingController();
  final _dataFinalController = TextEditingController();
  final _jurosController = TextEditingController();
  final _intervaloDiasController = TextEditingController(); 

  int? _opcaoSelecionada; 
  String? _frequenciaSelecionada;

  // Funções de Data (mantidas)
  Future<void> _selecionarData(BuildContext context, TextEditingController controller) async {
    // ... (lógica de seleção de data)
    try {
      final DateTime? selecionada = await showDatePicker(
        context: context, 
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

  // Função de conversão corrigida para UTC
  String converterParaSql(String dataBR) {
    final partes = dataBR.split('/');
    final dia = int.parse(partes[0]);
    final mes = int.parse(partes[1]);
    final ano = int.parse(partes[2]);

    final DateTime dataUtc = DateTime.utc(ano, mes, dia); 
    return DateFormat('yyyy-MM-dd').format(dataUtc);
  }

  Future<void> _criarNovoDeposito() async { 
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos obrigatórios.')),
      );
      return;
    }
      
    // 1. CAPTURA DOS CAMPOS ESSENCIAIS
    final valor = double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0.0;
    final origem = _origemController.text; // NOVO: Campo obrigatório
    final objetivo = _objetivoController.text; // NOVO: Campo opcional (descricao)
    final repeticao = _frequenciaSelecionada ?? '1';

    // 2. MAPEAMENTO DA REPETIÇÃO (Flutter -> BD)
    String repeticaoBD;
    switch (repeticao) {
      case '1': repeticaoBD = 'nenhuma'; break;
      case '2': repeticaoBD = 'mensal'; break;
      case '3': repeticaoBD = 'semanal'; break;
      case '4': 
      case '5': repeticaoBD = 'x_dias'; break;
      default: repeticaoBD = 'nenhuma'; break;
    }
    
    // 3. MAPEAMENTO DO TIPO (BD: 'fixa' ou 'variavel')
    final tipoDeposito = repeticaoBD == 'nenhuma' ? 'variavel' : 'fixa'; 
    
    // 4. CHAMADA AO SERVIÇO (Com 6 Parâmetros)
    try {
      await PoupancaService().criarPoupanca( 
        idUsuario, 
        tipoDeposito, 
        objetivo, // <--- 3º ARG: descricao (objetivo)
        valor, 
        repeticaoBD, 
        origem, // <--- 6º ARG: origem
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Depósito adicionado com sucesso!')), 
      );
      
      Navigator.pop(context, true); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar depósito: $e')), 
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                          Navigator.pop(context); 
                        },
                      ),
                    ),
                    const Center(
                      child: Text(
                        "Novo depósito", 
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

                /// ------ Origem do valor depositado (NOVO CAMPO, OBRIGATÓRIO) ------
                const Text("Origem do valor depositado *"),
                TextFormField(
                  controller: _origemController, 
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(), 
                    hintText: 'Ex. 13º salário', // <--- TEXTO DE EXEMPLO
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe a origem do valor';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),
                
                /// ------ Objetivo para o depósito (Antiga Descrição, AGORA OPCIONAL) ------
                const Text("Objetivo para o depósito"),
                TextFormField(
                  controller: _objetivoController, // <--- CONTROLLER DO OBJETIVO
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(), 
                    hintText: 'Ex: Viagem de férias',
                  ),
                  // O campo é opcional, então não precisa de validator.
                ),

                const SizedBox(height: 20),

                /// ------ Frequência (Repetição) ------
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
                
                // Campo Intervalo de Dias
                if (_frequenciaSelecionada == '4' || _frequenciaSelecionada == '5')
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Intervalo de Dias (para Personalizada/Diário)"),
                      TextFormField(
                        controller: _intervaloDiasController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration:
                            const InputDecoration(border: OutlineInputBorder(), hintText: 'Ex: 30'),
                      ),
                    ],
                  ),
                ),

                /// ------ Data de início (IGNORADO PELO BD) ------
                const Text("Data de início *"),
                TextFormField(
                  controller: _dataInicioController,
                  readOnly: true, 
                  onTap: () => _selecionarData(context, _dataInicioController), 
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
                    final regex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
                    if (!regex.hasMatch(value)) {
                      return 'Use o formato dd/mm/aaaa';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                /// ------ Parcelas / Data Final (IGNORADO PELO BD) ------
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
                    TextFormField(
                      controller: _dataFinalController,
                      readOnly: true, 
                      onTap: () => _selecionarData(context, _dataFinalController), 
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
                        return null;
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                
                /// ------ Juros (Campo Único e OBRIGATÓRIO) ------
                const Text("Juros *"),
                TextFormField(
                  controller: _jurosController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}')),
                  ],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Ex: 0.50',
                  ),
                  validator: (value) { 
                    if (value == null || value.isEmpty) {
                      return 'Informe o valor dos juros (pode ser 0)';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 30),

                /// ------ Botão Criar ------
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: _criarNovoDeposito,
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