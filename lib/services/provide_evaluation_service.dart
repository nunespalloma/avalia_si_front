import 'dart:convert';
import 'package:http/http.dart' as http;

class TurmaAvaliacao {
  final int id;
  final String disciplina;
  final String turma;
  final String semestre;
  bool avaliada;

  TurmaAvaliacao({
    required this.id,
    required this.disciplina,
    required this.turma,
    required this.semestre,
    required this.avaliada,
  });

  factory TurmaAvaliacao.fromJson(Map<String, dynamic> json) {
    return TurmaAvaliacao(
      id: json['id'],
      disciplina: json['disciplina'] ?? '',
      turma: json['turma'] ?? '',
      semestre: json['semestre'] ?? '',
      avaliada: json['avaliada'] == true,
    );
  }
}

class ProvideEvaluationService {
  static const String baseUrl = 'http://localhost:3000';

  static Future<List<TurmaAvaliacao>> listarTurmasParaAvaliacao({
    required int alunoId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/alunos/$alunoId/avaliacoes_disponiveis'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Não foi possível carregar as turmas para avaliação.');
    }

    final List body = jsonDecode(response.body);
    return body.map((item) => TurmaAvaliacao.fromJson(item)).toList();
  }
}