import 'package:flutter/material.dart';
import '../../widgets/success_popup.dart';
import '../../widgets/confirm_delete_popup.dart';
import '../../widgets/error_message.dart';
import '../../services/turmas_service.dart';

class SelectTurmaProfessorPage extends StatefulWidget {
  const SelectTurmaProfessorPage({super.key});

  @override
  State<SelectTurmaProfessorPage> createState() =>
      _SelectTurmaProfessorPageState();
}

class _SelectTurmaProfessorPageState extends State<SelectTurmaProfessorPage> {
  List<TurmaProfessorItem> _turmas = [];

  String _pesquisa = '';
  int? _idEmEdicao;
  bool _adicionandoNovo = false;

  String? _mensagemPendente;
  bool _mensagemJaExibida = false;
  bool _erroAtual = false;

  final TextEditingController _turmaController = TextEditingController();

  int? _disciplinaSelecionadaId;
  int? _professorSelecionadoId;
  int? _semestreSelecionadoId;

  List<OpcaoCadastro> _disciplinas = [];
  List<OpcaoCadastro> _professores = [];
  List<OpcaoCadastro> _semestres = [];

  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarTudo();
  }

  @override
  void dispose() {
    _turmaController.dispose();
    super.dispose();
  }

  Future<void> _carregarTudo() async {
    setState(() {
      _carregando = true;
    });

    try {
      final results = await Future.wait([
        TurmasService.listarTurmas(),
        TurmasService.listarDisciplinas(),
        TurmasService.listarProfessores(),
        TurmasService.listarSemestres(),
      ]);

      if (!mounted) return;

      setState(() {
        _turmas = results[0] as List<TurmaProfessorItem>;
        _disciplinas = results[1] as List<OpcaoCadastro>;
        _professores = results[2] as List<OpcaoCadastro>;
        _semestres = results[3] as List<OpcaoCadastro>;
      });
    } catch (e) {
      if (!mounted) return;
      _agendarAviso(e.toString().replaceFirst('Exception: ', ''), erro: true);
    } finally {
      if (!mounted) return;
      setState(() {
        _carregando = false;
      });
    }
  }

  void _agendarAviso(String mensagem, {bool erro = false}) {
    setState(() {
      _mensagemPendente = mensagem;
      _erroAtual = erro;
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
      _disciplinaSelecionadaId = item.disciplinaId;
      _turmaController.text = item.turma;
      _professorSelecionadoId = item.professorId;
      _semestreSelecionadoId = item.semestreId;
    });
  }

  void _iniciarNovoCadastro() {
    setState(() {
      _idEmEdicao = null;
      _adicionandoNovo = true;
      _disciplinaSelecionadaId = null;
      _turmaController.clear();
      _professorSelecionadoId = null;
      _semestreSelecionadoId = null;
    });
  }

  void _cancelarEdicao() {
    setState(() {
      _idEmEdicao = null;
      _adicionandoNovo = false;
      _disciplinaSelecionadaId = null;
      _turmaController.clear();
      _professorSelecionadoId = null;
      _semestreSelecionadoId = null;
    });
  }

  Future<void> _salvarEdicao(TurmaProfessorItem item) async {
    final turma = _turmaController.text.trim();

    if (_disciplinaSelecionadaId == null ||
        turma.isEmpty ||
        _semestreSelecionadoId == null) {
      _agendarAviso(
        'Preencha disciplina, turma e semestre.',
        erro: true,
      );
      return;
    }

    try {
      final mensagem = await TurmasService.atualizarTurma(
        id: item.id,
        nome: turma,
        disciplinaId: _disciplinaSelecionadaId!,
        professorId: _professorSelecionadoId,
        semestreId: _semestreSelecionadoId!,
      );

      if (!mounted) return;

      setState(() {
        _idEmEdicao = null;
        _disciplinaSelecionadaId = null;
        _turmaController.clear();
        _professorSelecionadoId = null;
        _semestreSelecionadoId = null;
      });

      await _carregarTudo();
      _agendarAviso(mensagem);
    } catch (e) {
      if (!mounted) return;
      _agendarAviso(e.toString().replaceFirst('Exception: ', ''), erro: true);
    }
  }

  Future<void> _salvarNovoCadastro() async {
    final turma = _turmaController.text.trim();

    if (_disciplinaSelecionadaId == null ||
        turma.isEmpty ||
        _semestreSelecionadoId == null) {
      _agendarAviso(
        'Preencha disciplina, turma e semestre.',
        erro: true,
      );
      return;
    }

    try {
      final mensagem = await TurmasService.criarTurma(
        nome: turma,
        disciplinaId: _disciplinaSelecionadaId!,
        professorId: _professorSelecionadoId,
        semestreId: _semestreSelecionadoId!,
      );

      if (!mounted) return;

      setState(() {
        _adicionandoNovo = false;
        _disciplinaSelecionadaId = null;
        _turmaController.clear();
        _professorSelecionadoId = null;
        _semestreSelecionadoId = null;
      });

      await _carregarTudo();
      _agendarAviso(mensagem);
    } catch (e) {
      if (!mounted) return;
      _agendarAviso(e.toString().replaceFirst('Exception: ', ''), erro: true);
    }
  }

  void _excluirItem(TurmaProfessorItem item) {
    showDeletePopup(
      context,
      title: 'Excluir turma',
      message: 'Tem certeza que deseja excluir esta turma?',
      onConfirm: () async {
        try {
          final mensagem = await TurmasService.excluirTurma(item.id);

          if (!mounted) return;

          setState(() {
            if (_idEmEdicao == item.id) {
              _idEmEdicao = null;
              _disciplinaSelecionadaId = null;
              _turmaController.clear();
              _professorSelecionadoId = null;
              _semestreSelecionadoId = null;
            }
          });

          await _carregarTudo();
          _agendarAviso(mensagem);
        } catch (e) {
          if (!mounted) return;
          _agendarAviso(
            e.toString().replaceFirst('Exception: ', ''),
            erro: true,
          );
        }
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
    required int? value,
    required List<OpcaoCadastro> items,
    required ValueChanged<int?> onChanged,
  }) {
    final ids = items.map((e) => e.id).toList();
    final valorValido = value != null && ids.contains(value) ? value : null;

    return DropdownButtonFormField<int>(
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
            (item) => DropdownMenuItem<int>(
              value: item.id,
              child: Text(
                item.nome,
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
            value: _disciplinaSelecionadaId,
            items: _disciplinas,
            onChanged: (value) {
              setState(() {
                _disciplinaSelecionadaId = value;
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
            value: _professorSelecionadoId,
            items: _professores,
            onChanged: (value) {
              setState(() {
                _professorSelecionadoId = value;
              });
            },
          ),
          const SizedBox(height: 12),
          _buildDropdown(
            hint: 'Semestre',
            value: _semestreSelecionadoId,
            items: _semestres,
            onChanged: (value) {
              setState(() {
                _semestreSelecionadoId = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _carregando
                      ? null
                      : isNovo
                          ? _salvarNovoCadastro
                          : () => _salvarEdicao(item),
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
    if (!_mensagemJaExibida &&
        _mensagemPendente != null &&
        !_erroAtual) {
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
                  onPressed: (_adicionandoNovo || _carregando)
                      ? null
                      : _iniciarNovoCadastro,
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
              if (_mensagemPendente != null && _erroAtual) ...[
                const SizedBox(height: 16),
                ErrorMessage(
                  message: _mensagemPendente!,
                  onClose: () {
                    setState(() {
                      _mensagemPendente = null;
                      _erroAtual = false;
                    });
                  },
                ),
              ],
              const SizedBox(height: 24),
              Expanded(
                child: _carregando
                    ? const Center(child: CircularProgressIndicator())
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