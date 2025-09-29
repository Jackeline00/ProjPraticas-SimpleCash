import 'dart:convert'; 
import 'package:http/http.dart' as http;

class PoupancaService {
  final String baseUrl = 'http://localhost:8090';

  Future<bool> criarPoupanca(int idUsuario, String tipo, String descricao, double valor, String data, int repeticao, String origem) async{
    final response = await http.post(
      Uri.parse('$baseUrl/poupanca/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "idUsuario":idUsuario, 
        "tipo":tipo, 
        "descricao":descricao, 
        "valor":valor, 
        "data":data, 
        "repeticao":repeticao, 
        "origem":origem
      })
    );

    if(response.statusCode == 201){ 
      return true;
    }else{
      return false;
    }
  }

  Future<bool> mostrarPoupancas(int idUsuario) async{
    final response = await http.get(
      Uri.parse('$baseUrl/poupanca/$idUsuario'),
      headers: {"Content-Type": "application/json"},
    );

     if(response.statusCode == 201){
      return true;
    }else{
      return false;
    }
  }

   Future<bool> editar(int id, String tipo, String descricao, double valor, String data, int repeticao, String origem) async{
    final response = await http.put(
      Uri.parse('$baseUrl/poupanca/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "tipo":tipo, 
        "descricao":descricao, 
        "valor":valor, 
        "data":data, 
        "repeticao":repeticao, 
        "origem":origem
      })
    );

    if(response.statusCode == 200){
      return true;
    }else{
      return false;
    }
  }

  Future<bool> deletarPoupanca(int id) async{
      final response = await http.delete(
      Uri.parse('$baseUrl/poupanca/$id'),
      headers: {"Contect-Type": "application/json"},
    );
    
    if (response.statusCode == 200) { 
      return true;
    }else{
      return false;
    }
  }


}