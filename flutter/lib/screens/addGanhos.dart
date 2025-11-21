// Em flutter/lib/screens/addGanho.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/ganho_service.dart'; 

class AdicionarGanho extends StatefulWidget { 
  const AdicionarGanho({super.key});

  @override
  State<AdicionarGanho> createState() => _AdicionarGanhoScreen();
}

class _AdicionarGanhoScreen extends State<AdicionarGanho> {
  String email = '';
  int? idUsuario;

  final _formKey = GlobalKey<FormState>();

  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  
  // Variáveis para a UI (mantidas, mesmo que o backend as ignore temporariamente)
  final _parcelasController = TextEditingController();
  final _dataInicioController = TextEditingController();
  final _dataFinalController = TextEditingController();
  final _jurosController = TextEditingController();
  final _intervaloDiasController = TextEditingController();
  
  int? _opcaoSelecionada; 
  String? _frequenciaSelecionada;
  String? _tipoJuros;
  String? _ganhoParaPoupanca; 

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    email = args is String ? args : '';
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

  // Funções de Data (mantidas para a UI)
  Future<void> _selecionarData(BuildContext context, TextEditingController controller) async {
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

  // Função de conversão (mantida para a UI)
  String converterParaSql(String dataBR) {
    final partes = dataBR.split('/');
    final dia = int.parse(partes[0]);
    final mes = int.parse(partes[1]);
    final ano = int.parse(partes[2]);
    final DateTime dataUtc = DateTime.utc(ano, mes, dia); 
    return DateFormat('yyyy-MM-dd').format(dataUtc);
  }

  Future<void> _criarNovoGanho() async { 
    if (_formKey.currentState!.validate() && idUsuario != null) {
      
      // 1. CAPTURA APENAS OS CAMPOS NECESSÁRIOS PARA O BD
      final valor = double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0.0;
      final descricao = _descricaoController.text;
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
      
      // 3. MAPEAMENTO DO TIPO (BD: 'variavel' ou 'fixo')
      final tipoGanho = repeticaoBD == 'nenhuma' ? 'variavel' : 'fixo'; 
      
      // 4. CHAMADA AO SERVIÇO (Com APENAS 5 Parâmetros)
      try {
        await GanhoService().adicionarGanho( 
          idUsuario!,              // 1
          valor,                    // 2
          descricao,                // 3
          tipoGanho,                // 4
          repeticaoBD,              // 5
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ganho adicionado com sucesso!')), 
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar ganho: $e')), 
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (o restante do build é a UI completa que você pediu)
    // Eu incluí o build completo da minha resposta anterior para você
    
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
                          Navigator.pop(context); 
                        },
                      ),
                    ),
                    const Center(
                      child: Text(
                        "Novo ganho", 
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

                /// ------ Data de início ------
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
                
                /// ------ Ganho Destinado à Poupança? (IGNORADO PELO BD) ------
                const Text("Ganho destinado à poupança?"),
                RadioListTile<String>(
                  title: const Text('Sim'),
                  value: '1',
                  groupValue: _ganhoParaPoupanca,
                  onChanged: (value) {
                    setState(() => _ganhoParaPoupanca = value);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Não'),
                  value: '0',
                  groupValue: _ganhoParaPoupanca,
                  onChanged: (value) {
                    setState(() => _ganhoParaPoupanca = value);
                  },
                ),
                const SizedBox(height: 20),
                /// ------ FIM NOVO CAMPO ------

                /// ------ Juros (IGNORADO PELO BD) ------
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

                /// ------ Tipo de juros (IGNORADO PELO BD) ------
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
                      onPressed: _criarNovoGanho,
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