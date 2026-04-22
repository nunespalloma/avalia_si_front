import 'dart:convert';
import 'package:http/http.dart' as http;

class EvaluationDashboardData {
  final double organizacaoConteudo;
  final double quantidadeExercicios;
  final double avaliacaoCondizente;
  final double professorRespeitoso;
  final double professorSolicito;
  final double assiduidadeProfessor;
  final List<String> comentarios;
  final double notaEstrelas;

  EvaluationDashboardData({
    required this.organizacaoConteudo,
    required this.quantidadeExercicios,
    required this.avaliacaoCondizente,
    required this.professorRespeitoso,
    required this.professorSolicito,
    required this.assiduidadeProfessor,
    required this.comentarios,
    required this.notaEstrelas,
  });

  factory EvaluationDashboardData.fromJson(Map<String, dynamic> json) {
    final comentariosJson = json['comentarios'] as List? ?? [];

    return EvaluationDashboardData(
      organizacaoConteudo: (json['organizacao_conteudo'] ?? 0).toDouble(),
      quantidadeExercicios: (json['quantidade_exercicios'] ?? 0).toDouble(),
      avaliacaoCondizente: (json['avaliacao_condizente'] ?? 0).toDouble(),
      professorRespeitoso: (json['professor_respeitoso'] ?? 0).toDouble(),
      professorSolicito: (json['professor_solicito'] ?? 0).toDouble(),
      assiduidadeProfessor: (json['assiduidade_professor'] ?? 0).toDouble(),
      comentarios: comentariosJson.map((e) => e.toString()).toList(),
      notaEstrelas: (json['nota_estrelas'] ?? 0).toDouble(),
    );
  }

  String get notaFormatada => notaEstrelas.toStringAsFixed(1);
}

class EvaluationDashboardService {
  static const String baseUrl = 'http://localhost:3000';

  static Future<EvaluationDashboardData> buscarDashboard({
    required int turmaId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/turmas/$turmaId/dashboard_avaliacao'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Não foi possível carregar o resumo da avaliação.');
    }

    final body = jsonDecode(response.body);
    return EvaluationDashboardData.fromJson(body);
  }
}