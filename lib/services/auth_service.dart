import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = 'http://10.0.2.2:3000'; //Emulador Android falando com backend no PC

  Future<Map<String, dynamic>> login(String email, String senha) async {
    final url = Uri.parse('$baseUrl/login');// http://localhost:3000/login

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
      // sucesso – devolve dados do usuário/token/etc
      return body as Map<String, dynamic>;
    } else {
      // erro – lança exceção com mensagem vinda do backend (se tiver)
      throw Exception(body['error'] ?? 'Erro ao fazer login');
    }
  }
}