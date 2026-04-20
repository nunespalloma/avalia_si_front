import 'dart:convert';
import 'package:http/http.dart' as http;

class TurmaProfessorItem {
  final int id;
  String disciplina;
  String turma;
  String professor;
  String semestre;

  final int disciplinaId;
  final int? professorId;
  final int semestreId;

  TurmaProfessorItem({
    required this.id,
    required this.disciplina,
    required this.turma,
    required this.professor,
    required this.semestre,
    required this.disciplinaId,
    required this.professorId,
    required this.semestreId,
  });

  factory TurmaProfessorItem.fromJson(Map<String, dynamic> json) {
    return TurmaProfessorItem(
      id: json['id'],
      turma: json['nome'] ?? '',
      disciplina: json['disciplina_nome'] ?? '',
      professor: json['professor_nome'] ?? '',
      semestre: json['semestre_nome'] ?? '',
      disciplinaId: json['disciplina_id'],
      professorId: json['professor_id'],
      semestreId: json['semestre_id'],
    );
  }
}

class OpcaoCadastro {
  final int id;
  final String nome;

  OpcaoCadastro({
    required this.id,
    required this.nome,
  });
}

class TurmasService {
  static const String baseUrl = 'http://localhost:3000';

  static Future<List<TurmaProfessorItem>> listarTurmas() async {
    final response = await http.get(
      Uri.parse('$baseUrl/turmas'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar turmas.');
    }

    final List data = jsonDecode(response.body);
    return data.map((item) => TurmaProfessorItem.fromJson(item)).toList();
  }

  static Future<List<OpcaoCadastro>> listarDisciplinas() async {
    final response = await http.get(
      Uri.parse('$baseUrl/disciplinas'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar disciplinas.');
    }

    final List data = jsonDecode(response.body);
    return data.map((item) {
      return OpcaoCadastro(
        id: item['id'],
        nome: item['nome'].toString(),
      );
    }).toList();
  }

  static Future<List<OpcaoCadastro>> listarProfessores() async {
    final response = await http.get(
      Uri.parse('$baseUrl/professores'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar professores.');
    }

    final List data = jsonDecode(response.body);
    return data.map((item) {
      return OpcaoCadastro(
        id: item['id'],
        nome: item['nome'].toString(),
      );
    }).toList();
  }

  static Future<List<OpcaoCadastro>> listarSemestres() async {
    final response = await http.get(
      Uri.parse('$baseUrl/semestres'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar semestres.');
    }

    final List data = jsonDecode(response.body);
    return data.map((item) {
      return OpcaoCadastro(
        id: item['id'],
        nome: '${item['ano']}.${item['periodo']}',
      );
    }).toList();
  }

  static Future<String> criarTurma({
    required String nome,
    required int disciplinaId,
    required int semestreId,
    int? professorId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/turmas'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'turma': {
          'nome': nome,
          'disciplina_id': disciplinaId,
          'professor_id': professorId,
          'semestre_id': semestreId,
        }
      }),
    );

    return _tratarResposta(
      response,
      sucessoPadrao: 'Turma criada com sucesso.',
    );
  }

  static Future<String> atualizarTurma({
    required int id,
    required String nome,
    required int disciplinaId,
    required int semestreId,
    int? professorId,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/turmas/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'turma': {
          'nome': nome,
          'disciplina_id': disciplinaId,
          'professor_id': professorId,
          'semestre_id': semestreId,
        }
      }),
    );

    return _tratarResposta(
      response,
      sucessoPadrao: 'Turma atualizada com sucesso.',
    );
  }

  static Future<String> excluirTurma(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/turmas/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    return _tratarResposta(
      response,
      sucessoPadrao: 'Turma excluída com sucesso.',
    );
  }

  static String _tratarResposta(
    http.Response response, {
    required String sucessoPadrao,
  }) {
    final dynamic body =
        response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body is Map<String, dynamic> && body['message'] != null) {
        return body['message'];
      }
      return sucessoPadrao;
    }

    if (body is Map<String, dynamic>) {
      final errors = body['errors'];
      final error = body['error'];
      final message = body['message'];

      if (errors is List) {
        throw Exception(errors.join(', '));
      }

      if (errors is String) {
        throw Exception(errors);
      }

      if (error is String) {
        throw Exception(error);
      }

      if (message is String) {
        throw Exception(message);
      }
    }

    throw Exception('Ocorreu um erro ao processar a requisição.');
  }
}