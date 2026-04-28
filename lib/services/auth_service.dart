import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  //final String baseUrl = 'http://10.0.2.2:3000'; //Emulador Android falando com backend no PC
  final String baseUrl = 'http://localhost:3000'; //Chrome falando com backend no PC

  Future<Map<String, dynamic>> login(String email, String senha) async {
    final url = Uri.parse('$baseUrl/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': senha,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return body as Map<String, dynamic>;
    } else {
      throw Exception(body['error'] ?? 'Erro ao fazer login');
    }
  }

  Future<Map<String, dynamic>> cadastrar({
    required String nome,
    required String email,
    required String matricula,
    required String senha,
  }) async {
    final url = Uri.parse('$baseUrl/alunos');

    final payload = {
      'usuario': {
        'nome': nome,
        'email': email,
        'password': senha,
        'password_confirmation': senha,
      },
      'aluno': {
        'matricula': matricula,
      }
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );

    print('ENVIANDO: ${jsonEncode(payload)}');
    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');

    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (body is Map<String, dynamic>) {
        return body;
      }

      return {
        'message': 'Cadastro realizado com sucesso',
      };
    } else {
      throw Exception(
        body?['error'] ??
            (body != null && body['errors'] is List
                ? body['errors'].join(', ')
                : null) ??
            body?['message'] ??
            'Erro ao realizar cadastro',
      );
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final url = Uri.parse('$baseUrl/password/forgot');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
      }),
    );

    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (response.statusCode == 200) {
      if (body is Map<String, dynamic>) {
        return body;
      }

      return {
        'message': 'Solicitação de recuperação enviada com sucesso',
      };
    } else {
      throw Exception(
        body?['error'] ??
            body?['message'] ??
            'Erro ao solicitar recuperação de senha',
      );
    }
  }

  Future<void> resetPassword({
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    final url = Uri.parse('$baseUrl/password/reset');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'token': token,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (response.statusCode != 200) {
      throw Exception(
        body?['error'] ??
            body?['message'] ??
            'Erro ao alterar senha',
      );
    }
  }
}