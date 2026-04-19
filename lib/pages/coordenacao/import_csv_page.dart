import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../widgets/error_message.dart';
import 'widgets/semestre_name_field.dart';

class ImportCsvPage extends StatefulWidget {
  const ImportCsvPage({super.key});

  @override
  State<ImportCsvPage> createState() => _ImportCsvPageState();
}

class _ImportCsvPageState extends State<ImportCsvPage> {
  final TextEditingController _semestreNomeController = TextEditingController();

  bool _carregando = false;

  String? _nomeArquivo;
  Uint8List? _arquivoBytes;

  String? _mensagemResultado;
  bool _importacaoComSucesso = false;
  List<String> _erros = [];

  @override
  void dispose() {
    _semestreNomeController.dispose();
    super.dispose();
  }

  Future<void> _selecionarArquivo() async {
    try {
      final resultado = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (resultado == null || resultado.files.isEmpty) {
        return;
      }

      final arquivo = resultado.files.first;

      if (arquivo.bytes == null || arquivo.bytes!.isEmpty) {
        setState(() {
          _nomeArquivo = null;
          _arquivoBytes = null;
          _mensagemResultado =
              'Não foi possível ler o arquivo selecionado. Tente novamente.';
          _importacaoComSucesso = false;
          _erros = [];
        });
        return;
      }

      setState(() {
        _nomeArquivo = arquivo.name;
        _arquivoBytes = arquivo.bytes;
        _mensagemResultado = null;
        _importacaoComSucesso = false;
        _erros = [];
      });
    } catch (e) {
      setState(() {
        _nomeArquivo = null;
        _arquivoBytes = null;
        _mensagemResultado = 'Erro ao selecionar o arquivo: $e';
        _importacaoComSucesso = false;
        _erros = [];
      });
    }
  }

  Future<void> _importarCsv() async {
    final semestreNome = _semestreNomeController.text.trim();

    if (semestreNome.isEmpty) {
      setState(() {
        _mensagemResultado =
            'Informe o nome do semestre no formato esperado.';
        _importacaoComSucesso = false;
        _erros = [];
      });
      return;
    }

    final semestreValido = RegExp(r'^\d{4}\.\d$').hasMatch(semestreNome);

    if (!semestreValido) {
      setState(() {
        _mensagemResultado = 'Informe o semestre no formato 2026.1.';
        _importacaoComSucesso = false;
        _erros = [];
      });
      return;
    }

    if (_arquivoBytes == null || _nomeArquivo == null) {
      setState(() {
        _mensagemResultado = 'Selecione um arquivo CSV antes de continuar.';
        _importacaoComSucesso = false;
        _erros = [];
      });
      return;
    }

    setState(() {
      _carregando = true;
      _mensagemResultado = null;
      _importacaoComSucesso = false;
      _erros = [];
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:3000/coordenacao/importar_turmas_csv'),
      );

      request.fields['semestre_nome'] = semestreNome;

      request.files.add(
        http.MultipartFile.fromBytes(
          'arquivo',
          _arquivoBytes!,
          filename: _nomeArquivo!,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final Map<String, dynamic> body =
          response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _importacaoComSucesso = true;
          _mensagemResultado =
              body['message'] ?? 'CSV importado com sucesso.';
          _erros = [];
        });
      } else {
        final errosResposta = body['erros'];

        setState(() {
          _importacaoComSucesso = false;
          _mensagemResultado =
              body['message'] ?? body['error'] ?? 'Erro ao importar CSV.';
          _erros = errosResposta is List
              ? errosResposta.map((e) => e.toString()).toList()
              : [];
        });
      }
    } catch (e) {
      setState(() {
        _importacaoComSucesso = false;
        _mensagemResultado = 'Erro ao conectar com o servidor: $e';
        _erros = [];
      });
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  void _limparArquivo() {
    setState(() {
      _nomeArquivo = null;
      _arquivoBytes = null;
      _mensagemResultado = null;
      _importacaoComSucesso = false;
      _erros = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 24,
                    color: Colors.black,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Importar\nPlanos de Aula',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 62),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildFieldLabel('Nome do semestre'),
                      const SizedBox(height: 8),
                      SemesterNameField(
                        controller: _semestreNomeController,
                      ),
                      const SizedBox(height: 62),
                      _buildFieldLabel('Arquivo CSV'),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nomeArquivo ?? 'Nenhum arquivo selecionado',
                              style: TextStyle(
                                fontSize: 13,
                                color: _nomeArquivo == null
                                    ? Colors.black54
                                    : Colors.black,
                                fontWeight: _nomeArquivo == null
                                    ? FontWeight.w400
                                    : FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed:
                                        _carregando ? null : _selecionarArquivo,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.black,
                                      side: const BorderSide(
                                        color: Colors.black12,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Selecionar arquivo',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ),
                                if (_nomeArquivo != null) ...[
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed:
                                          _carregando ? null : _limparArquivo,
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.black54,
                                        side: const BorderSide(
                                          color: Colors.black12,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        'Remover',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInfoCard(),
                      if (_mensagemResultado != null && !_importacaoComSucesso)
                        ErrorMessage(
                          message: _mensagemResultado!,
                          onClose: () {
                            setState(() {
                              _mensagemResultado = null;
                            });
                          },
                        ),
                      if (_mensagemResultado != null && _importacaoComSucesso) ...[
                        const SizedBox(height: 20),
                        _buildResultCard(),
                      ],
                      if (_erros.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildErrorsCard(),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _carregando ? null : _importarCsv,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: _carregando
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Importar planos de aula',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String texto) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Formato esperado para o Arquivo CSV',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'MATRICULA;CODIGODISCIPLINA;NOMEDISCIPLINA;TURMA',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Exemplo:',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '219083000;TCC00254;TOPICOS ESPECIAIS EM SISTEMAS DE PROGRAMACAO II;A1',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    final Color corFundo = _importacaoComSucesso
        ? const Color(0xFFF2F8F2)
        : const Color(0xFFFFF4F4);

    final Color corBorda = _importacaoComSucesso
        ? const Color(0xFFB9D7BC)
        : const Color(0xFFE3B5B5);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: corBorda),
      ),
      child: Text(
        _mensagemResultado!,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black87,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildErrorsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Erros encontrados',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          ..._erros.map(
            (erro) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '• $erro',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}