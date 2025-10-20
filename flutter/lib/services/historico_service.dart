import 'dart:convert'; 
import 'package:http/http.dart' as http;

class HistoricoService {
  final String baseUrl = 'http://localhost:8090';

  Future<bool> adicionarAoHistorico(int idUsuario, String tipoAtividade, int idReferencia, String descricao, double valor) async{
    final response = await http.post(
      Uri.parse('$baseUrl/historico/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "idUsuario": idUsuario, 
        "tipoAtividade": tipoAtividade, 
        "idReferencia": idReferencia, 
        "descricao": descricao, 
        "valor": valor
      })
    );

    if(response.statusCode == 201){ 
      return true;
    }else{
      return false;
    }
  }

  Future<List<dynamic>> mostrarHistorico(int idUsuario) async {
    final response = await http.get(
      Uri.parse('$baseUrl/historico/$idUsuario'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) { 
      final data = jsonDecode(response.body);

      // Se a API retorna um array de registros, o decode já será uma lista
      if (data is List) {
        return data;
      } else if (data is Map && data.containsKey('historico')) {
        // caso sua API devolva um objeto com uma chave "historico"
        return data['historico'];
      } else {
        return [];
      }
    } else {
      throw Exception(
        'Erro ao carregar histórico: código ${response.statusCode}',
      );
    }
  }

  Future<List<Map<String, dynamic>>> mostrarGastos(int idUsuario) async {
    final response = await http.get(
      Uri.parse('$baseUrl/historico/gastos/$idUsuario'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      } else if (data is Map && data.containsKey('historico')) {
        return List<Map<String, dynamic>>.from(data['historico']);
      } else {
        return [];
      }
    } else {
      throw Exception(
        'Erro ao carregar histórico: código ${response.statusCode}',
      );
    }
  }

  Future<List<Map<String, dynamic>>> mostrarGanhos(int idUsuario) async {
    final response = await http.get(
      Uri.parse('$baseUrl/historico/ganhos/$idUsuario'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      } else if (data is Map && data.containsKey('historico')) {
        return List<Map<String, dynamic>>.from(data['historico']);
      } else {
        return [];
      }
    } else {
      throw Exception(
        'Erro ao carregar histórico: código ${response.statusCode}',
      );
    }
  }


  Future<List<Map<String, dynamic>>> mostrarPoupancas(int idUsuario) async {
    final response = await http.get(
      Uri.parse('$baseUrl/historico/poupancas/$idUsuario'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      } else if (data is Map && data.containsKey('historico')) {
        return List<Map<String, dynamic>>.from(data['historico']);
      } else {
        return [];
      }
    } else {
      throw Exception(
        'Erro ao carregar histórico: código ${response.statusCode}',
      );
    }
  }

  

  Future<bool> editar(int id, int idUsuario, String tipoAtividade, int idReferencia, String descricao, double valor) async{
    final response = await http.put(
      Uri.parse('$baseUrl/historico/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
       "idUsuario": idUsuario, 
        "tipoAtividade": tipoAtividade, 
        "idReferencia": idReferencia, 
        "descricao": descricao, 
        "valor": valor
      })
    );

    if(response.statusCode == 200){
      return true;
    }else{
      return false;
    }
  }

  Future<bool> deletarItemDoHistorico(int id) async{
      final response = await http.delete(
      Uri.parse('$baseUrl/historico/$id'),
      headers: {"Contect-Type": "application/json"},
    );
    
    if (response.statusCode == 200) { 
      return true;
    }else{
      return false;
    }
  }


}