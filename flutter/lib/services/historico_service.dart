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

  Future<bool> mostrarHistorico(int idUsuario) async{ // de um determinado usuário
    final response = await http.get(
      Uri.parse('$baseUrl/historico/$idUsuario'),
      headers: {"Content-Type": "application/json"},
    );

     if(response.statusCode == 201){
      return true;
    }else{
      return false;
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