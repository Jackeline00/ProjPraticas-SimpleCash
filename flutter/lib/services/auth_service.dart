import 'dart:convert';

/// importa funcionalidades do Dart para codificar e decodificar JSON
import 'package:http/http.dart' as http;

/// importa a biblioteca http que permite fazer requisições HTTP (GET, POST, etc)
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  /// classe que possui métodos de autenticação
  final String baseUrl = 'http://localhost:8090';

  /// url da API

  Future<bool> login(String email, String senha) async {
    final response = await http.post(
      /// envia uma requisição POST à API
      Uri.parse('$baseUrl/usuarios/login'),

      /// cria endereço da requisição
      headers: {"Content-Type": "application/json"},

      /// diz à API que o corpo da requisição é JSON
      body: jsonEncode({
        /// transforma o objeto com email e senha em JSON
        "email": email,
        "senha": senha,
      }),
    );

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('logado', true);
      await prefs.setString('email', email); // guarda o email do usuário logado
      return true; // login OK
    } else {
      return false; // erro
    }
  }

  // Verifica se há login salvo localmente
  Future<bool> estaLogado() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('logado') ?? false;
  }

  // Retorna o email do usuário atual
  Future<String?> usuarioAtual() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  // Logout limpa dados salvos
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logado');
    await prefs.remove('email');
  }

  Future<bool> cadastro(
    String nome,
    String email,
    String senha,
    double saldoTotal,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/usuarios/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nome": nome,
        "email": email,
        "senha": senha,
        "saldoTotal": saldoTotal,
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> editar(
    String emailPk,
    String nome,
    String email,
    String senha,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/usuarios/$emailPk'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"nome": nome, "email": email, "senha": senha}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> existe(String email) async {
    final response = await http.get(
      Uri.parse('$baseUrl/usuarios/del/$email'),
      headers: {"Contect-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      /// caso o usuário for encontrado
      return true;
    } else {
      return false;
    }
  }

  Future<String?> buscarIdUsuario(String email) async {
    final response = await http.get(
      Uri.parse('$baseUrl/usuarios/id/$email'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['idUsuario'];
    } else {
      return null;
    }
  }

  Future<String?> buscarNomeUsuario(String email) async {
    final response = await http.get(
      Uri.parse('$baseUrl/usuarios/nome/$email'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['nome'];
    } else {
      return null;
    }
  }

  Future<String?> buscarSenhaUsuario(String email) async {
    final response = await http.get(
      Uri.parse('$baseUrl/usuarios/senha/$email'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['senha'];
    } else {
      return null;
    }
  }

  Future<String?> buscarSaldo(String email) async {
    final response = await http.get(
      Uri.parse('$baseUrl/usuarios/saldo/$email'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['saldoAtual'];
    } else {
      return null;
    }
  }

  Future<bool> apagarConta(String email) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/usuarios/$email'),
      headers: {"Contect-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      /// caso o usuário seja apagado
      // Se a conta for apagada, remove também o login local
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('logado');
      await prefs.remove('email');
      return true;
    } else {
      return false;
    }
  }
}
