import 'dart:convert'; 
import 'package:http/http.dart' as http;

class GanhoService {
  final String baseUrl = 'http://localhost:8090';

  Future<bool> adicionarGanho(int idUsuario, double valor, String descricao, String tipo, String repeticao) async{
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

    if(response.statusCode == 201){ /// se o ganho foi adicionado com sucesso
      return true;
    }else{
      return false;
    }
  }

   Future<bool> editar(int idUsuario, double valor, String descricao, String tipo, String repeticao) async{
    final response = await http.put(
      Uri.parse('$baseUrl/ganhos/$idUsuario'),
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
    
    if (response.statusCode == 200) { /// caso o usuário seja apagado
      return true;
    }else{
      return false;
    }

  }


}