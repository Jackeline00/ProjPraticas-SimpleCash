import 'dart:convert'; 
import 'package:http/http.dart' as http;

class GastoService {
  final String baseUrl = 'http://localhost:8090';

  Future<bool> adicionarGasto(int idUsuario, String tipo, String descricao, double valor, String repeticao, int? intervaloDias, String dataInicio, String dataFinal, int quantidadeDeParcelas, double juros, String tipoJuros) async{
    final response = await http.post(
      Uri.parse('$baseUrl/gastos/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "idUsuario": idUsuario,
        "tipo" : tipo,
        "descricao": descricao,
        "valor": valor,
        "repeticao": repeticao,
        "intervaloDias": intervaloDias,
        "dataInicio" : dataInicio,
        "dataFinal": dataFinal,
        "quantidadeDeParcelas": quantidadeDeParcelas,
        "juros": juros,
        "tipoJuros" : tipoJuros
      })
    );

    if(response.statusCode == 201){ /// se o gasto foi adicionado com sucesso
      return true;
    }else{
      return false;
    }
  }

  /// Lista dinâmica de gastos de uma usuário (se tudo der certo esse método vai deixar de existir)
  Future<List<dynamic>> buscarGastos(String email) async {
    final response = await http.get(Uri.parse('$baseUrl/gastos/$email'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao buscar gastos');
    }
  }

  Future<List<dynamic>> mostrarGastos(int idUsuario) async {
    final response = await http.get(
      Uri.parse('$baseUrl/gastos/$idUsuario'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao buscar gastos');
    }
  }

  Future<bool> editar(int id, int idUsuario, String tipo, String descricao, double valor, String repeticao, String dataInicio, String dataFinal, int quantidadeDeParcelas, double juros, String tipoJuros) async{
    final response = await http.put(
      Uri.parse('$baseUrl/gastos/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "idUsuario": idUsuario,
        "tipo" : tipo,
        "descricao": descricao,
        "valor": valor,
        "repeticao": repeticao,
        "dataInicio" : dataInicio,
        "dataFinal": dataFinal,
        "quantidadeDeParcelas": quantidadeDeParcelas,
        "juros": juros,
        "tipoJuros" : tipoJuros
      })
    );

    if(response.statusCode == 200){
      return true;
    }else{
      return false;
    }
  }

  Future<bool> deletarGasto(int id) async{
      final response = await http.delete(
      Uri.parse('$baseUrl/gastos/$id'),
      headers: {"Contect-Type": "application/json"},
    );
    
    if (response.statusCode == 200) { 
      return true;
    }else{
      return false;
    }

  }


}