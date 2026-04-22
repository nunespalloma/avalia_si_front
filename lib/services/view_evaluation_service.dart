import 'dart:convert';
import 'package:http/http.dart' as http;

class TurmaResultado {
  final int id;
  final String disciplina;
  final String turma;
  final String professor;

  TurmaResultado({
    required this.id,
    required this.disciplina,
    required this.turma,
    required this.professor,
  });

  factory TurmaResultado.fromJson(Map<String, dynamic> json) {
    return TurmaResultado(
      id: json['id'],
      disciplina: json['disciplina'] ?? '',
      turma: json['turma'] ?? '',
      professor: json['professor'] ?? '',
    );
  }
}

class ViewEvaluationService {
  static const String baseUrl = 'http://localhost:3000';

  static Future<List<TurmaResultado>> listarTurmasComAvaliacoes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/resultados_avaliacoes'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Não foi possível carregar as turmas avaliadas.');
    }

    final List body = jsonDecode(response.body);
    return body.map((item) => TurmaResultado.fromJson(item)).toList();
  }
}