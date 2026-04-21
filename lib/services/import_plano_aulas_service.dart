import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class SemestreOpcao {
  final int id;
  final String nome;

  SemestreOpcao({
    required this.id,
    required this.nome,
  });

  factory SemestreOpcao.fromJson(Map<String, dynamic> json) {
    return SemestreOpcao(
      id: json['id'],
      nome: '${json['ano']}.${json['periodo']}',
    );
  }
}

class ImportPlanoAulasService {
  static const String baseUrl = 'http://localhost:3000';

  static Future<List<SemestreOpcao>> listarSemestres() async {
    final response = await http.get(
      Uri.parse('$baseUrl/semestres'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Não foi possível carregar os semestres.');
    }

    final List body = jsonDecode(response.body);
    return body
        .map((item) => SemestreOpcao.fromJson(item))
        .toList();
  }

  static Future<Map<String, dynamic>> importarPlanoAulas({
    required int semestreId,
    required Uint8List arquivoBytes,
    required String nomeArquivo,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/importacoes/plano_aulas'),
    );

    request.fields['semestre_id'] = semestreId.toString();

    request.files.add(
      http.MultipartFile.fromBytes(
        'arquivo',
        arquivoBytes,
        filename: nomeArquivo,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final Map<String, dynamic> body =
        response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode == 200 || response.statusCode == 201) {
      return body;
    }

    throw Exception(
      body['message'] ??
          body['error'] ??
          'Erro ao importar planos de aula.',
    );
  }
}