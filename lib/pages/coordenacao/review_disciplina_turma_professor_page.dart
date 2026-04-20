import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../widgets/success_popup.dart';
import '../../widgets/confirm_delete_popup.dart';

class TurmaProfessorItem {
  final int id;
  String disciplina;
  String turma;
  String professor;
  String semestre;

  TurmaProfessorItem({
    required this.id,
    required this.disciplina,
    required this.turma,
    required this.professor,
    required this.semestre,
  });
}

class SelectTurmaProfessorPage extends StatefulWidget {
  const SelectTurmaProfessorPage({super.key});

  @override
  State<SelectTurmaProfessorPage> createState() =>
      _SelectTurmaProfessorPageState();
}

class _SelectTurmaProfessorPageState extends State<SelectTurmaProfessorPage> {
  final List<TurmaProfessorItem> _turmas = [
    TurmaProfessorItem(
      id: 1,
      disciplina: 'Segurança da Informação',
      turma: 'A1',
      professor: 'Profa. Mariana',
      semestre: '2025.2',
    ),
    TurmaProfessorItem(
      id: 2,
      disciplina: 'Projeto de Aplicação II',
      turma: 'A1',
      professor: 'Prof. Carlos Henrique',
      semestre: '2025.2',
    ),
    TurmaProfessorItem(
      id: 3,
      disciplina: 'Tópicos em Redes de Computadores I',
      turma: 'A1',
      professor: '',
      semestre: '2025.2',
    ),
  ];

  String _pesquisa = '';
  int? _idEmEdicao;
  bool _adicionandoNovo = false;
  int _proximoId = 4;

  String? _mensagemPendente;
  bool _mensagemJaExibida = false;

  final TextEditingController _turmaController = TextEditingController();

  String? _disciplinaSelecionada;
  String? _professorSelecionado;
  String? _semestreSelecionado;

  List<String> _disciplinas = [];
  List<String> _professores = [];
  List<String> _semestres = [];

  bool _carregandoOpcoes = true;

  static const String _baseUrl = 'http://localhost:3000';

  @override
  void initState() {
    super.initState();
    _carregarOpcoes();
  }

  @override
  void dispose() {
    _turmaController.dispose();
    super.dispose();
  }

  Future<void> _carregarOpcoes() async {
    setState(() {
      _carregandoOpcoes = true;
    });

    try {
      final responses = await Future.wait([
        http.get(Uri.parse('$_baseUrl/disciplinas')),
        http.get(Uri.parse('$_baseUrl/professores')),
        http.get(Uri.parse('$_baseUrl/semestres')),
      ]);

      final disciplinasResponse = responses[0];
      final professoresResponse = responses[1];
      final semestresResponse = responses[2];

      if (disciplinasResponse.statusCode == 200 &&
          professoresResponse.statusCode == 200 &&
          semestresResponse.statusCode == 200) {
        final disciplinasJson = jsonDecode(disciplinasResponse.body) as List;
        final professoresJson = jsonDecode(professoresResponse.body) as List;
        final semestresJson = jsonDecode(semestresResponse.body) as List;

        setState(() {
          _disciplinas = disciplinasJson
              .map((item) => item['nome'].toString())
              .toList();

          _professores = professoresJson
              .map((item) => item['nome'].toString())
              .toList();

          _semestres = semestresJson
              .map((item) => '${item['ano']}.${item['periodo']}')
              .toList();
        });
      } else {
        _agendarAviso('Não foi possível carregar disciplinas, professores e semestres.');
      }
    } catch (_) {
      _agendarAviso('Erro ao carregar disciplinas, professores e semestres.');
    } finally {
      if (mounted) {
        setState(() {
          _carregandoOpcoes = false;
        });
      }
    }
  }

  void _agendarAviso(String mensagem) {
    setState(() {
      _mensagemPendente = mensagem;
      _mensagemJaExibida = false;
    });
  }

  List<TurmaProfessorItem> get _turmasFiltradas {
    final termo = _pesquisa.toLowerCase().trim();

    if (termo.isEmpty) return _turmas;

    return _turmas.where((item) {
      return item.disciplina.toLowerCase().contains(termo) ||
          item.turma.toLowerCase().contains(termo) ||
          item.professor.toLowerCase().contains(termo) ||
          item.semestre.toLowerCase().contains(termo);
    }).toList();
  }

  void _iniciarEdicao(TurmaProfessorItem item) {
    setState(() {
      _adicionandoNovo = false;
      _idEmEdicao = item.id;
      _disciplinaSelecionada = item.disciplina;
      _turmaController.text = item.turma;
      _professorSelecionado = item.professor.isEmpty ? null : item.professor;
      _semestreSelecionado = item.semestre;
    });
  }

  void _iniciarNovoCadastro() {
    setState(() {
      _idEmEdicao = null;
      _adicionandoNovo = true;
      _disciplinaSelecionada = null;
      _turmaController.clear();
      _professorSelecionado = null;
      _semestreSelecionado = null;
    });
  }

  void _cancelarEdicao() {
    setState(() {
      _idEmEdicao = null;
      _adicionandoNovo = false;
      _disciplinaSelecionada = null;
      _turmaController.clear();
      _professorSelecionado = null;
      _semestreSelecionado = null;
    });
  }

  void _salvarEdicao(TurmaProfessorItem item) {
    final disciplina = _disciplinaSelecionada?.trim() ?? '';
    final turma = _turmaController.text.trim();
    final professor = _professorSelecionado?.trim() ?? '';
    final semestre = _semestreSelecionado?.trim() ?? '';

    if (disciplina.isEmpty ||
        turma.isEmpty ||
        professor.isEmpty ||
        semestre.isEmpty) {
      _agendarAviso('Preencha disciplina, turma, professor e semestre.');
      return;
    }

    setState(() {
      item.disciplina = disciplina;
      item.turma = turma;
      item.professor = professor;
      item.semestre = semestre;
      _idEmEdicao = null;
      _disciplinaSelecionada = null;
      _turmaController.clear();
      _professorSelecionado = null;
      _semestreSelecionado = null;
    });

    _agendarAviso('Informações atualizadas com sucesso.');
  }

  void _salvarNovoCadastro() {
    final disciplina = _disciplinaSelecionada?.trim() ?? '';
    final turma = _turmaController.text.trim();
    final professor = _professorSelecionado?.trim() ?? '';
    final semestre = _semestreSelecionado?.trim() ?? '';

    if (disciplina.isEmpty ||
        turma.isEmpty ||
        professor.isEmpty ||
        semestre.isEmpty) {
      _agendarAviso('Preencha disciplina, turma, professor e semestre.');
      return;
    }

    setState(() {
      _turmas.add(
        TurmaProfessorItem(
          id: _proximoId++,
          disciplina: disciplina,
          turma: turma,
          professor: professor,
          semestre: semestre,
        ),
      );
      _adicionandoNovo = false;
      _disciplinaSelecionada = null;
      _turmaController.clear();
      _professorSelecionado = null;
      _semestreSelecionado = null;
    });

    _agendarAviso('Registro adicionado com sucesso.');
  }

  void _excluirItem(TurmaProfessorItem item) {
    showDeletePopup(
      context,
      title: 'Excluir registro',
      message: 'Tem certeza que deseja excluir este registro?',
      onConfirm: () {
        setState(() {
          _turmas.removeWhere((t) => t.id == item.id);

          if (_idEmEdicao == item.id) {
            _idEmEdicao = null;
            _disciplinaSelecionada = null;
            _turmaController.clear();
            _professorSelecionado = null;
            _semestreSelecionado = null;
          }
        });

        _agendarAviso('Registro excluído com sucesso.');
      },
    );
  }

  Widget _buildCampo({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
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
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final valorValido =
        value != null && items.contains(value) ? value : null;

    return DropdownButtonFormField<String>(
      value: valorValido,
      isExpanded: true,
      decoration: InputDecoration(
        hintText: hint,
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
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildCardVisualizacao(TurmaProfessorItem item) {
    final semProfessor = item.professor.trim().isEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.disciplina,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Turma: ${item.turma}',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            semProfessor
                ? 'Professor: Não cadastrado'
                : 'Professor: ${item.professor}',
            style: TextStyle(
              fontSize: 13,
              color: semProfessor ? Colors.black54 : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Semestre: ${item.semestre}',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _iniciarEdicao(item),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Editar',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _excluirItem(item),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black26),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Excluir',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardEdicao({TurmaProfessorItem? item}) {
    final bool isNovo = item == null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isNovo ? 'Novo registro' : 'Editar registro',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            hint: 'Disciplina',
            value: _disciplinaSelecionada,
            items: _disciplinas,
            onChanged: (value) {
              setState(() {
                _disciplinaSelecionada = value;
              });
            },
          ),
          const SizedBox(height: 12),
          _buildCampo(
            controller: _turmaController,
            hint: 'Turma',
          ),
          const SizedBox(height: 12),
          _buildDropdown(
            hint: 'Professor',
            value: _professorSelecionado,
            items: _professores,
            onChanged: (value) {
              setState(() {
                _professorSelecionado = value;
              });
            },
          ),
          const SizedBox(height: 12),
          _buildDropdown(
            hint: 'Semestre',
            value: _semestreSelecionado,
            items: _semestres,
            onChanged: (value) {
              setState(() {
                _semestreSelecionado = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _carregandoOpcoes
                      ? null
                      : isNovo
                          ? _salvarNovoCadastro
                          : () => _salvarEdicao(item!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    isNovo ? 'Adicionar' : 'Salvar',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: _cancelarEdicao,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black26),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_mensagemJaExibida && _mensagemPendente != null) {
      _mensagemJaExibida = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _mensagemPendente == null) return;

        showTopMessageBanner(
          context,
          message: _mensagemPendente!,
        );

        setState(() {
          _mensagemPendente = null;
        });
      });
    }

    final turmasFiltradas = _turmasFiltradas;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
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
                  'Montar turmas',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                onChanged: (value) {
                  setState(() {
                    _pesquisa = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Pesquisar disciplina, turma, professor ou semestre',
                  hintStyle: const TextStyle(
                    fontSize: 12,
                    color: Colors.black38,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.black54),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
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
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _adicionandoNovo ? null : _iniciarNovoCadastro,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Adicionar turma',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _carregandoOpcoes
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : turmasFiltradas.isEmpty && !_adicionandoNovo
                        ? const Center(
                            child: Text(
                              'Nenhum registro encontrado.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount:
                                turmasFiltradas.length + (_adicionandoNovo ? 1 : 0),
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              if (_adicionandoNovo && index == 0) {
                                return _buildCardEdicao();
                              }

                              final item = turmasFiltradas[
                                  _adicionandoNovo ? index - 1 : index];

                              if (_idEmEdicao == item.id) {
                                return _buildCardEdicao(item: item);
                              }

                              return _buildCardVisualizacao(item);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}