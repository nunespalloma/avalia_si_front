import 'dart:convert';
import 'package:http/http.dart' as http;

enum TipoCadastro {
  disciplina,
  professor,
  semestre,
}

class CadastroBaseItem {
  final int id;
  final TipoCadastro tipo;

  String? nome;
  String? codigo;
  String? ano;
  String? periodo;

  CadastroBaseItem({
    required this.id,
    required this.tipo,
    this.nome,
    this.codigo,
    this.ano,
    this.periodo,
  });

  factory CadastroBaseItem.fromJsonDisciplina(Map<String, dynamic> json) {
    return CadastroBaseItem(
      id: json['id'],
      tipo: TipoCadastro.disciplina,
      nome: json['nome'],
      codigo: json['codigo'],
    );
  }

  factory CadastroBaseItem.fromJsonProfessor(Map<String, dynamic> json) {
    return CadastroBaseItem(
      id: json['id'],
      tipo: TipoCadastro.professor,
      nome: json['nome'],
    );
  }

  factory CadastroBaseItem.fromJsonSemestre(Map<String, dynamic> json) {
    return CadastroBaseItem(
      id: json['id'],
      tipo: TipoCadastro.semestre,
      ano: json['ano']?.toString(),
      periodo: json['periodo']?.toString(),
    );
  }
}

class CadastrosBaseService {
  static const String baseUrl = 'http://localhost:3000';

  static Future<List<CadastroBaseItem>> listar(TipoCadastro tipo) async {
    late final Uri url;

    switch (tipo) {
      case TipoCadastro.disciplina:
        url = Uri.parse('$baseUrl/disciplinas');
        break;
      case TipoCadastro.professor:
        url = Uri.parse('$baseUrl/professores');
        break;
      case TipoCadastro.semestre:
        url = Uri.parse('$baseUrl/semestres');
        break;
    }

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar dados.');
    }

    final List data = jsonDecode(response.body);

    switch (tipo) {
      case TipoCadastro.disciplina:
        return data
            .map((item) => CadastroBaseItem.fromJsonDisciplina(item))
            .toList();
      case TipoCadastro.professor:
        return data
            .map((item) => CadastroBaseItem.fromJsonProfessor(item))
            .toList();
      case TipoCadastro.semestre:
        return data
            .map((item) => CadastroBaseItem.fromJsonSemestre(item))
            .toList();
    }
  }

  static Future<String> criarDisciplina({
    required String nome,
    required String codigo,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/disciplinas'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'disciplina': {
          'nome': nome,
          'codigo': codigo,
        }
      }),
    );

    return _tratarResposta(
      response,
      sucessoPadrao: 'Disciplina adicionada com sucesso.',
    );
  }

  static Future<String> atualizarDisciplina({
    required int id,
    required String nome,
    required String codigo,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/disciplinas/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'disciplina': {
          'nome': nome,
          'codigo': codigo,
        }
      }),
    );

    return _tratarResposta(
      response,
      sucessoPadrao: 'Disciplina atualizada com sucesso.',
    );
  }

  static Future<String> excluirDisciplina(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/disciplinas/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    return _tratarResposta(
      response,
      sucessoPadrao: 'Disciplina excluída com sucesso.',
    );
  }

  static Future<String> criarProfessor({
    required String nome,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/professores'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'professor': {
          'nome': nome,
        }
      }),
    );

    return _tratarResposta(
      response,
      sucessoPadrao: 'Professor adicionado com sucesso.',
    );
  }

  static Future<String> atualizarProfessor({
    required int id,
    required String nome,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/professores/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'professor': {
          'nome': nome,
        }
      }),
    );

    return _tratarResposta(
      response,
      sucessoPadrao: 'Professor atualizado com sucesso.',
    );
  }

  static Future<String> excluirProfessor(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/professores/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    return _tratarResposta(
      response,
      sucessoPadrao: 'Professor excluído com sucesso.',
    );
  }

  static Future<String> criarSemestre({
    required String ano,
    required String periodo,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/semestres'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'semestre': {
          'ano': ano,
          'periodo': periodo,
        }
      }),
    );

    return _tratarResposta(
      response,
      sucessoPadrao: 'Semestre adicionado com sucesso.',
    );
  }

  static Future<String> atualizarSemestre({
    required int id,
    required String ano,
    required String periodo,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/semestres/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'semestre': {
          'ano': ano,
          'periodo': periodo,
        }
      }),
    );

    return _tratarResposta(
      response,
      sucessoPadrao: 'Semestre atualizado com sucesso.',
    );
  }

  static Future<String> excluirSemestre(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/semestres/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    return _tratarResposta(
      response,
      sucessoPadrao: 'Semestre excluído com sucesso.',
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