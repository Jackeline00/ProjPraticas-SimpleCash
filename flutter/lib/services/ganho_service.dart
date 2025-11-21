import 'dart:convert'; 
import 'package:http/http.dart' as http;

class GanhoService {
  final String baseUrl = 'http://localhost:8090';

  Future<bool> adicionarGanho(
    int idUsuario, 
    double valor, 
    String descricao, 
    String tipo, 
    String repeticao
    // Os outros 7 campos (datas, juros, poupanca) serão ignorados aqui
  ) async{
    final response = await http.post(
      Uri.parse('$baseUrl/ganhos/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "idUsuario": idUsuario,
        "valor": valor,
        "descricao": descricao,
        "tipo": tipo,
        "repeticao": repeticao
      })
    );

    if(response.statusCode == 201){ 
      return true;
    }else{
      return false;
    }
  }

  /// Lista de ganhos de um usuário por email
  Future<List<dynamic>> buscarGanhos(String email) async {
    final response = await http.get(Uri.parse('$baseUrl/ganhos/$email'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao buscar ganhos');
    }
  }


  Future<List<dynamic>> mostrarGanhos(int idUsuario) async {
    final response = await http.get(
      Uri.parse('$baseUrl/ganhos/$idUsuario'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data; /// supondo que o backend retorne uma lista de ganhos
    } else {
      throw Exception('Erro ao carregar ganhos (status: ${response.statusCode})');
    }
  }

   Future<bool> editar(int id, int idUsuario, double valor, String descricao, String tipo, String repeticao) async{
    final response = await http.put(
      Uri.parse('$baseUrl/ganhos/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "valor": valor,
        "descricao": descricao,
        "tipo": tipo,
        "repeticao": repeticao
      })
    );

    if(response.statusCode == 200){
      return true;
    }else{
      return false;
    }
  }

  Future<bool> deletarGanho(int id) async{
      final response = await http.delete(
      Uri.parse('$baseUrl/ganhos/$id'),
      headers: {"Contect-Type": "application/json"},
    );
    
    if (response.statusCode == 200) { 
      return true;
    }else{
      return false;
    }

  }


}