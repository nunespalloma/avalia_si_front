import 'dart:convert';
import 'package:http/http.dart' as http;

class EvaluationFormService {
  static const String baseUrl = 'http://localhost:3000';

  static Future<String> enviarAvaliacao({
    required int alunoId,
    required int planoAulaAlunoId,
    required int avaliacaoGeral,
    required int organizacaoConteudo,
    required int quantidadeExercicios,
    required int avaliacaoCondizente,
    required int professorRespeitoso,
    required int professorSolicito,
    required int assiduidadeProfessor,
    required String aspectosGerais,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/alunos/$alunoId/avaliacoes'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'avaliacao': {
          'plano_aula_aluno_id': planoAulaAlunoId,
          'avaliacao_geral': avaliacaoGeral,
          'organizacao_conteudo': organizacaoConteudo,
          'quantidade_exercicios': quantidadeExercicios,
          'avaliacao_condizente': avaliacaoCondizente,
          'professor_respeitoso': professorRespeitoso,
          'professor_solicito': professorSolicito,
          'assiduidade_professor': assiduidadeProfessor,
          'aspectos_gerais': aspectosGerais,
        }
      }),
    );

    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (response.statusCode == 200 || response.statusCode == 201) {
      return body?['message'] ?? 'Avaliação enviada com sucesso!';
    } else {
      throw Exception(
        body?['error'] ??
            (body != null && body['errors'] is List
                ? body['errors'].join(', ')
                : null) ??
            body?['message'] ??
            'Erro ao enviar avaliação.',
      );
    }
  }
}