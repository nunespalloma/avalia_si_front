import 'dart:convert';
import 'package:http/http.dart' as http;

class EvaluationDashboardData {
  final double organizacaoConteudo;
  final double passagemConteudo;
  final double quantidadeExercicios;
  final double avaliacaoCondizente;
  final double professorRespeitoso;
  final double professorSolicito;
  final double assiduidadeProfessor;
  final double teoriaPratica;
  final double percentualTrancouTurma;
  final double percentualAcreditaPassar;
  final List<String> comentarios;
  final List<String> motivosTrancamento;
  final List<String> pontosQueAfligiram;
  final double notaEstrelas;

  EvaluationDashboardData({
    required this.organizacaoConteudo,
    required this.passagemConteudo,
    required this.quantidadeExercicios,
    required this.avaliacaoCondizente,
    required this.professorRespeitoso,
    required this.professorSolicito,
    required this.assiduidadeProfessor,
    required this.teoriaPratica,
    required this.percentualTrancouTurma,
    required this.percentualAcreditaPassar,
    required this.comentarios,
    required this.motivosTrancamento,
    required this.pontosQueAfligiram,
    required this.notaEstrelas,
  });

  factory EvaluationDashboardData.fromJson(Map<String, dynamic> json) {
    final comentariosJson = json['comentarios'] as List? ?? [];
    final motivosTrancamentoJson = json['motivos_trancamento'] as List? ?? [];
    final pontosQueAfligiramJson = json['pontos_que_afligiram'] as List? ?? [];

    return EvaluationDashboardData(
      organizacaoConteudo:
          (json['organizacao_conteudo'] as num? ?? 0).toDouble(),
      passagemConteudo:
          (json['passagem_conteudo'] as num? ?? 0).toDouble(),
      quantidadeExercicios:
          (json['quantidade_exercicios'] as num? ?? 0).toDouble(),
      avaliacaoCondizente:
          (json['avaliacao_condizente'] as num? ?? 0).toDouble(),
      professorRespeitoso:
          (json['professor_respeitoso'] as num? ?? 0).toDouble(),
      professorSolicito:
          (json['professor_solicito'] as num? ?? 0).toDouble(),
      assiduidadeProfessor:
          (json['assiduidade_professor'] as num? ?? 0).toDouble(),
      teoriaPratica: (json['teoria_pratica'] as num? ?? 0).toDouble(),
      percentualTrancouTurma:
          (json['percentual_trancou_turma'] as num? ?? 0).toDouble(),
      percentualAcreditaPassar:
          (json['percentual_acredita_passar'] as num? ?? 0).toDouble(),
      comentarios: comentariosJson.map((e) => e.toString()).toList(),
      motivosTrancamento:
          motivosTrancamentoJson.map((e) => e.toString()).toList(),
      pontosQueAfligiram:
          pontosQueAfligiramJson.map((e) => e.toString()).toList(),
      notaEstrelas: (json['nota_estrelas'] as num? ?? 0).toDouble(),
    );
  }

  String get notaFormatada => notaEstrelas.toStringAsFixed(1);

  String get percentualTrancouTurmaFormatado =>
      '${percentualTrancouTurma.toStringAsFixed(0)}%';

  String get percentualAcreditaPassarFormatado =>
      '${percentualAcreditaPassar.toStringAsFixed(0)}%';
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