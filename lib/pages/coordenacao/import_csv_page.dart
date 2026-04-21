import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../widgets/error_message.dart';
import '../../widgets/success_popup.dart';
import '../../services/import_plano_aulas_service.dart';

class ImportCsvPage extends StatefulWidget {
  const ImportCsvPage({super.key});

  @override
  State<ImportCsvPage> createState() => _ImportCsvPageState();
}

class _ImportCsvPageState extends State<ImportCsvPage> {
  bool _carregando = false;

  String? _nomeArquivo;
  Uint8List? _arquivoBytes;

  String? _mensagemResultado;
  bool _importacaoComSucesso = false;
  List<String> _erros = [];

  List<SemestreOpcao> _semestres = [];
  int? _semestreSelecionadoId;
  bool _carregandoSemestres = true;

  bool _mensagemSucessoJaExibida = false;

  @override
  void initState() {
    super.initState();
    _carregarSemestres();
  }

  Future<void> _carregarSemestres() async {
    setState(() {
      _carregandoSemestres = true;
    });

    try {
      final semestres = await ImportPlanoAulasService.listarSemestres();

      if (!mounted) return;

      setState(() {
        _semestres = semestres;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _mensagemResultado = e.toString().replaceFirst('Exception: ', '');
        _importacaoComSucesso = false;
        _erros = [];
        _mensagemSucessoJaExibida = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _carregandoSemestres = false;
        });
      }
    }
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
          _mensagemSucessoJaExibida = false;
        });
        return;
      }

      setState(() {
        _nomeArquivo = arquivo.name;
        _arquivoBytes = arquivo.bytes;
        _mensagemResultado = null;
        _importacaoComSucesso = false;
        _erros = [];
        _mensagemSucessoJaExibida = false;
      });
    } catch (e) {
      setState(() {
        _nomeArquivo = null;
        _arquivoBytes = null;
        _mensagemResultado = 'Erro ao selecionar o arquivo: $e';
        _importacaoComSucesso = false;
        _erros = [];
        _mensagemSucessoJaExibida = false;
      });
    }
  }

  Future<void> _importarCsv() async {
    if (_semestreSelecionadoId == null) {
      setState(() {
        _mensagemResultado = 'Selecione o semestre.';
        _importacaoComSucesso = false;
        _erros = [];
        _mensagemSucessoJaExibida = false;
      });
      return;
    }

    if (_arquivoBytes == null || _nomeArquivo == null) {
      setState(() {
        _mensagemResultado = 'Selecione um arquivo CSV antes de continuar.';
        _importacaoComSucesso = false;
        _erros = [];
        _mensagemSucessoJaExibida = false;
      });
      return;
    }

    setState(() {
      _carregando = true;
      _mensagemResultado = null;
      _importacaoComSucesso = false;
      _erros = [];
      _mensagemSucessoJaExibida = false;
    });

    try {
      final body = await ImportPlanoAulasService.importarPlanoAulas(
        semestreId: _semestreSelecionadoId!,
        arquivoBytes: _arquivoBytes!,
        nomeArquivo: _nomeArquivo!,
      );

      if (!mounted) return;

      final List<dynamic> errosResposta =
          body['erros'] is List ? body['erros'] : [];

      final bool sucesso = errosResposta.isEmpty;

      setState(() {
        _importacaoComSucesso = sucesso;
        _mensagemResultado = body['message'] ??
            (sucesso
                ? 'Planos de aula importados com sucesso.'
                : 'Importação concluída com pendências.');
        _erros = errosResposta.map((e) => e.toString()).toList();
        _mensagemSucessoJaExibida = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _importacaoComSucesso = false;
        _mensagemResultado = e.toString().replaceFirst('Exception: ', '');
        _erros = [];
        _mensagemSucessoJaExibida = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  Widget _buildSemestreDropdown() {
    final ids = _semestres.map((s) => s.id).toList();
    final valorValido =
        _semestreSelecionadoId != null && ids.contains(_semestreSelecionadoId)
            ? _semestreSelecionadoId
            : null;

    return DropdownButtonFormField<int>(
      value: valorValido,
      isExpanded: true,
      decoration: InputDecoration(
        hintText: _carregandoSemestres
            ? 'Carregando semestres...'
            : 'Selecione o semestre',
        hintStyle: const TextStyle(
          fontSize: 12,
          color: Colors.black38,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black54),
        ),
      ),
      items: _semestres
          .map(
            (semestre) => DropdownMenuItem<int>(
              value: semestre.id,
              child: Text(
                semestre.nome,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: _carregandoSemestres
          ? null
          : (value) {
              setState(() {
                _semestreSelecionadoId = value;
              });
            },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_mensagemSucessoJaExibida &&
        _mensagemResultado != null &&
        _importacaoComSucesso) {
      _mensagemSucessoJaExibida = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _mensagemResultado == null) return;

        showTopMessageBanner(
          context,
          message: _mensagemResultado!,
        );

        setState(() {
          _mensagemResultado = null;
        });
      });
    }

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
                      _buildSemestreDropdown(),
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
                            SizedBox(
                              width: double.infinity,
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
                  onPressed: _carregando || _carregandoSemestres
                      ? null
                      : _importarCsv,
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