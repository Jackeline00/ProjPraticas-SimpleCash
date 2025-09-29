import 'dart:convert'; /// importa funcionalidades do Dart para codificar e decodificar JSON
import 'dart:nativewrappers/_internal/vm/lib/ffi_native_type_patch.dart';
import 'package:http/http.dart' as http; /// importa a biblioteca http que permite fazer requisições HTTP (GET, POST, etc)

class AuthService { /// classe que possui métodos de autenticação
  final String baseUrl = 'http://localhost:8090'; /// url da API

  Future<bool> login(String email, String senha) async { 
    final response = await http.post(                /// envia uma requisição POST à API
      Uri.parse('$baseUrl/usuarios/login'),          /// cria endereço da requisição
      headers: {"Content-Type": "application/json"}, /// diz à API que o corpo da requisição é JSON
      body: jsonEncode({                             /// transforma o objeto com email e senha em JSON
        "email": email,
        "senha": senha
      }),
    );

    if (response.statusCode == 201) {
      return true; // login OK
    } else {
      return false; // erro
    }
  }

  Future<bool> cadastro(String nome, String email, String senha, double saldoTotal) async{
    final response = await http.post(
      Uri.parse('$baseUrl/usuarios/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nome": nome,
        "email": email,
        "senha": senha,
        "saldoTotal":saldoTotal
      })
    );

    if(response.statusCode == 201){
      return true;
    }else{
      return false;
    }
  }

  Future<bool> editar(int id, String nome, String email, String senha) async{
    final response = await http.put(
      Uri.parse('$baseUrl/usuarios/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nome": nome,
        "email": email,
        "senha": senha
      })
    );

    if(response.statusCode == 200){
      return true;
    }else{
      return false;
    }
  }

  Future<bool> existe(String email) async{
    final response = await http.get(
      Uri.parse('$baseUrl/usuarios/del/$email'),
      headers: {"Contect-Type": "application/json"},
    );

    if (response.statusCode == 200) { /// caso o usuário for encontrado
      return true;
    }else{
      return false;
    }

  }

  Future<bool> apagarConta(String email) async{
      final response = await http.delete(
      Uri.parse('$baseUrl/usuarios/$email'),
      headers: {"Contect-Type": "application/json"},
    );
    
    if (response.statusCode == 200) { /// caso o usuário seja apagado
      return true;
    }else{
      return false;
    }

  }

}
