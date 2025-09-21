import 'dart:convert'; /// importa funcionalidades do Dart para codificar e decodificar JSON
import 'package:http/http.dart' as http; /// importa a biblioteca http que permite fazer requisições HTTP (GET, POST, etc)

class AuthService { /// classe que possui métodos de autenticação
  final String baseUrl = 'http://localhost:8090'; /// url da API

  Future<bool> login(String email, String senha) async { 
    final response = await http.post(                /// envia uma requisição POST à API
      Uri.parse('$baseUrl/usuarios/login'),          /// cria endereço da requisição
      headers: {"Content-Type": "application/json"}, /// diz à API que o corpo da requisição é JSON
      body: jsonEncode({                             /// transforma o objeto com email e senha em JSON
        "email": email,
        "senha": senha,
      }),
    );

    if (response.statusCode == 200) {
      return true; // login OK
    } else {
      return false; // erro
    }
  }
}
