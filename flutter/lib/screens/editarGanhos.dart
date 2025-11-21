// Em flutter/lib/screens/editarGanho.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/ganho_service.dart';

class EditarGanho extends StatefulWidget {
  const EditarGanho({super.key});

  @override
  State<EditarGanho> createState() => _EditarGanhoScreen();
}

class _EditarGanhoScreen extends State<EditarGanho> {
  // Variáveis de Estado
  late int idGanhoPK; 
  late Map<String, dynamic> dadosGanhoOriginal; 
  int? idUsuario;

  final _formKey = GlobalKey<FormState>();

  // Controladores (Juros agora é um simples TextFormField)
  late TextEditingController _descricaoController;
  late TextEditingController _valorController;
  late TextEditingController _jurosController; // Mantido
  
  // Controladores para UI (Não essenciais para o save do Ganho)
  late TextEditingController _parcelasController;
  late TextEditingController _dataInicioController;
  late TextEditingController _dataFinalController;
  late TextEditingController _intervaloDiasController;

  // Variáveis de seleção (Estado)
  String? _frequenciaSelecionada; // '1' a '5'
  String? _ganhoParaPoupanca; // '0' para Não, '1' para Sim
  
  // Variáveis de seleção (Estado - Ignoradas no Save)
  int? _opcaoSelecionada; // 1 para Parcelas, 2 para Data Final
  // String? _tipoJuros; // <--- REMOVIDO/IGNORADO

  bool _carregando = true;
  bool _dadosCarregados = false; // Flag de controle

  @override
  void initState() {
    super.initState();
    _descricaoController = TextEditingController();
    _valorController = TextEditingController();
    _parcelasController = TextEditingController();
    _dataInicioController = TextEditingController();
    _dataFinalController = TextEditingController(); 
    _intervaloDiasController = TextEditingController(); 
    _jurosController = TextEditingController(); 
  }

  // Função para formatar data (Leitura - do SQL para BR)
  String _formatDate(String? dateSql) {
    if (dateSql == null || dateSql.isEmpty || dateSql.startsWith('1900-01-01')) {
      return '';
    }
    try {
      final date = DateTime.parse(dateSql);
      return DateFormat('dd/MM/yyyy').format(date.toLocal()); 
    } catch (e) {
      return '';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;

    if (_dadosCarregados) {
      return;
    }
    
    if (args is Map<String, dynamic>) {
      dadosGanhoOriginal = args;
      idGanhoPK = dadosGanhoOriginal['idGanho'] as int;
      idUsuario = dadosGanhoOriginal['idUsuario'] as int; 
      
      // 1. PREENCHER CONTROLADORES PRINCIPAIS
      _descricaoController.text = dadosGanhoOriginal['descricao'] ?? '';
      _valorController.text = dadosGanhoOriginal['valor']?.toString().replaceAll('.', ',') ?? ''; 
      
      // 2. INVERTER MAPEAMENTO
      final String repeticaoBD = dadosGanhoOriginal['repeticao'] ?? 'nenhuma';
      
      _frequenciaSelecionada = switch (repeticaoBD) {
        'nenhuma' => '1',
        'mensal' => '2',
        'semanal' => '3',
        'x_dias' => '5', 
        _ => '1' 
      };

      final String poupancaDestinoBD = dadosGanhoOriginal['poupancaDestino'] ?? 'nao';
      _ganhoParaPoupanca = poupancaDestinoBD == 'sim' ? '1' : '0';


      // 3. PREENCHER CONTROLADORES E VARIÁVEIS DA UI NÃO ESSENCIAIS
      _dataInicioController.text = _formatDate(dadosGanhoOriginal['dataInicio']); 
      _dataFinalController.text = _formatDate(dadosGanhoOriginal['dataFinal']);
      
      // Juros: Preenche o valor (ignora o tipo de juros)
      _jurosController.text = dadosGanhoOriginal['juros']?.toString().replaceAll('.', ',') ?? '';
      
      setState(() {
        _carregando = false;
        _dadosCarregados = true;
      });

    } else {
      setState(() => _carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro: ID do Ganho não fornecido.")),
      );
    }
  }
  
  // Função para abrir o DatePicker
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


  // Função para converter data BR para SQL (Escrita - Correção de Fuso)
  String converterParaSql(String dataBR) {
    final partes = dataBR.split('/');
    final dia = int.parse(partes[0]);
    final mes = int.parse(partes[1]);
    final ano = int.parse(partes[2]);

    final DateTime dataUtc = DateTime.utc(ano, mes, dia); 
    return DateFormat('yyyy-MM-dd').format(dataUtc);
  }

  // Função principal para salvar alterações
  Future<void> _salvarAlteracoes() async {
    if (!_formKey.currentState!.validate() || idUsuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha o formulário corretamente.')),
      );
      return;
    }

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
      await GanhoService().editar( 
        idGanhoPK,                  
        idUsuario!,                 
        valor,                      
        descricao,                  
        tipoGanho,                  
        repeticaoBD,                
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ganho atualizado com sucesso!')), 
      );

      Navigator.pop(context); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar ganho: $e')), 
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
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
                        "Editar ganho", 
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
                
                /// ------ Ganho Destinado à Poupança? ------
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

                /// ------ Juros (CAMPO ÚNICO) ------
                const Text("Juros"),
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
                ),
                // --- O BLOCO 'Tipo de juros' FOI REMOVIDO AQUI ---
                const SizedBox(height: 30),

                /// ------ Botão Salvar ------
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: _salvarAlteracoes,
                      child: const Text('Salvar'),
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