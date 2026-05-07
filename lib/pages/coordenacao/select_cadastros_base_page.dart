import 'package:flutter/material.dart';
import '../../widgets/success_popup.dart';
import '../../widgets/confirm_delete_popup.dart';
import '../../widgets/error_message.dart';
import '../../services/cadastros_base_service.dart';
import '../../services/turmas_service.dart';

class SelectCadastrosBasePage extends StatefulWidget {
  const SelectCadastrosBasePage({super.key});

  @override
  State<SelectCadastrosBasePage> createState() =>
      _SelectCadastrosBasePageState();
}

class _SelectCadastrosBasePageState extends State<SelectCadastrosBasePage> {
  List<CadastroBaseItem> _itens = [];
  List<TurmaProfessorItem> _turmas = [];

  TipoCadastro _tipoSelecionado = TipoCadastro.disciplina;
  bool _abaTurmasSelecionada = false;

  String _pesquisa = '';
  int? _idEmEdicao;
  bool _adicionandoNovo = false;
  bool _carregando = false;

  String? _mensagemPendente;
  bool _mensagemJaExibida = false;
  bool _erroAtual = false;

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _anoController = TextEditingController();
  final TextEditingController _periodoController = TextEditingController();
  final TextEditingController _turmaController = TextEditingController();

  int? _disciplinaSelecionadaId;
  int? _professorSelecionadoId;
  int? _semestreSelecionadoId;

  List<OpcaoCadastro> _disciplinas = [];
  List<OpcaoCadastro> _professores = [];
  List<OpcaoCadastro> _semestres = [];

  @override
  void initState() {
    super.initState();
    _carregarItens();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _codigoController.dispose();
    _anoController.dispose();
    _periodoController.dispose();
    _turmaController.dispose();
    super.dispose();
  }

  Future<void> _carregarItens() async {
    setState(() {
      _carregando = true;
    });

    try {
      if (_abaTurmasSelecionada) {
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
      } else {
        final itens = await CadastrosBaseService.listar(_tipoSelecionado);

        if (!mounted) return;

        setState(() {
          _itens = itens;
        });
      }
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

  String _tituloTipo(TipoCadastro tipo) {
    switch (tipo) {
      case TipoCadastro.disciplina:
        return 'disciplina';
      case TipoCadastro.professor:
        return 'professor';
      case TipoCadastro.semestre:
        return 'semestre';
    }
  }

  String _tituloTipoPlural(TipoCadastro tipo) {
    switch (tipo) {
      case TipoCadastro.disciplina:
        return 'disciplinas';
      case TipoCadastro.professor:
        return 'professores';
      case TipoCadastro.semestre:
        return 'semestres';
    }
  }

  String _hintPesquisa(TipoCadastro tipo) {
    if (_abaTurmasSelecionada) {
      return 'Pesquisar disciplina, turma, professor ou semestre';
    }

    switch (tipo) {
      case TipoCadastro.disciplina:
        return 'Pesquisar disciplina ou código';
      case TipoCadastro.professor:
        return 'Pesquisar professor';
      case TipoCadastro.semestre:
        return 'Pesquisar ano ou período';
    }
  }

  List<CadastroBaseItem> get _itensFiltrados {
    final termo = _pesquisa.toLowerCase().trim();

    return _itens.where((item) {
      if (_tipoSelecionado == TipoCadastro.disciplina) {
        return (item.nome ?? '').toLowerCase().contains(termo) ||
            (item.codigo ?? '').toLowerCase().contains(termo);
      }

      if (_tipoSelecionado == TipoCadastro.professor) {
        return (item.nome ?? '').toLowerCase().contains(termo);
      }

      return (item.ano ?? '').toLowerCase().contains(termo) ||
          (item.periodo ?? '').toLowerCase().contains(termo);
    }).toList();
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

  void _limparEdicao() {
    _idEmEdicao = null;
    _adicionandoNovo = false;
    _nomeController.clear();
    _codigoController.clear();
    _anoController.clear();
    _periodoController.clear();
    _turmaController.clear();
    _disciplinaSelecionadaId = null;
    _professorSelecionadoId = null;
    _semestreSelecionadoId = null;
  }

  void _trocarTipo(TipoCadastro tipo) {
    setState(() {
      _abaTurmasSelecionada = false;
      _tipoSelecionado = tipo;
      _pesquisa = '';
      _limparEdicao();
    });

    _carregarItens();
  }

  void _trocarParaTurmas() {
    setState(() {
      _abaTurmasSelecionada = true;
      _pesquisa = '';
      _limparEdicao();
    });

    _carregarItens();
  }

  void _iniciarEdicao(CadastroBaseItem item) {
    setState(() {
      _adicionandoNovo = false;
      _idEmEdicao = item.id;
      _nomeController.text = item.nome ?? '';
      _codigoController.text = item.codigo ?? '';
      _anoController.text = item.ano ?? '';
      _periodoController.text = item.periodo ?? '';
    });
  }

  void _iniciarEdicaoTurma(TurmaProfessorItem item) {
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
      _nomeController.clear();
      _codigoController.clear();
      _anoController.clear();
      _periodoController.clear();
      _turmaController.clear();
      _disciplinaSelecionadaId = null;
      _professorSelecionadoId = null;
      _semestreSelecionadoId = null;
    });
  }

  void _cancelarEdicao() {
    setState(() {
      _limparEdicao();
    });
  }

  Future<void> _salvarEdicao(CadastroBaseItem item) async {
    try {
      String mensagem;

      if (_tipoSelecionado == TipoCadastro.disciplina) {
        final nome = _nomeController.text.trim();
        final codigo = _codigoController.text.trim();

        if (nome.isEmpty || codigo.isEmpty) {
          _agendarAviso('Preencha nome e código da disciplina.', erro: true);
          return;
        }

        mensagem = await CadastrosBaseService.atualizarDisciplina(
          id: item.id,
          nome: nome,
          codigo: codigo,
        );
      } else if (_tipoSelecionado == TipoCadastro.professor) {
        final nome = _nomeController.text.trim();

        if (nome.isEmpty) {
          _agendarAviso('Preencha o nome do professor.', erro: true);
          return;
        }

        mensagem = await CadastrosBaseService.atualizarProfessor(
          id: item.id,
          nome: nome,
        );
      } else {
        final ano = _anoController.text.trim();
        final periodo = _periodoController.text.trim();

        if (ano.isEmpty || periodo.isEmpty) {
          _agendarAviso('Preencha ano e período.', erro: true);
          return;
        }

        mensagem = await CadastrosBaseService.atualizarSemestre(
          id: item.id,
          ano: ano,
          periodo: periodo,
        );
      }

      if (!mounted) return;

      setState(() {
        _limparEdicao();
      });

      await _carregarItens();
      _agendarAviso(mensagem);
    } catch (e) {
      if (!mounted) return;
      _agendarAviso(e.toString().replaceFirst('Exception: ', ''), erro: true);
    }
  }

  Future<void> _salvarEdicaoTurma(TurmaProfessorItem item) async {
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
        _limparEdicao();
      });

      await _carregarItens();
      _agendarAviso(mensagem);
    } catch (e) {
      if (!mounted) return;
      _agendarAviso(e.toString().replaceFirst('Exception: ', ''), erro: true);
    }
  }

  Future<void> _salvarNovoCadastro() async {
    if (_abaTurmasSelecionada) {
      await _salvarNovaTurma();
      return;
    }

    try {
      String mensagem;

      if (_tipoSelecionado == TipoCadastro.disciplina) {
        final nome = _nomeController.text.trim();
        final codigo = _codigoController.text.trim();

        if (nome.isEmpty || codigo.isEmpty) {
          _agendarAviso('Preencha nome e código da disciplina.', erro: true);
          return;
        }

        mensagem = await CadastrosBaseService.criarDisciplina(
          nome: nome,
          codigo: codigo,
        );
      } else if (_tipoSelecionado == TipoCadastro.professor) {
        final nome = _nomeController.text.trim();

        if (nome.isEmpty) {
          _agendarAviso('Preencha o nome do professor.', erro: true);
          return;
        }

        mensagem = await CadastrosBaseService.criarProfessor(
          nome: nome,
        );
      } else {
        final ano = _anoController.text.trim();
        final periodo = _periodoController.text.trim();

        if (ano.isEmpty || periodo.isEmpty) {
          _agendarAviso('Preencha ano e período.', erro: true);
          return;
        }

        mensagem = await CadastrosBaseService.criarSemestre(
          ano: ano,
          periodo: periodo,
        );
      }

      if (!mounted) return;

      setState(() {
        _limparEdicao();
      });

      await _carregarItens();
      _agendarAviso(mensagem);
    } catch (e) {
      if (!mounted) return;
      _agendarAviso(e.toString().replaceFirst('Exception: ', ''), erro: true);
    }
  }

  Future<void> _salvarNovaTurma() async {
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
        _limparEdicao();
      });

      await _carregarItens();
      _agendarAviso(mensagem);
    } catch (e) {
      if (!mounted) return;
      _agendarAviso(e.toString().replaceFirst('Exception: ', ''), erro: true);
    }
  }

  void _excluirItem(CadastroBaseItem item) {
    String titulo;
    String mensagem;

    if (item.tipo == TipoCadastro.disciplina) {
      titulo = 'Excluir disciplina';
      mensagem = 'Tem certeza que deseja excluir esta disciplina?';
    } else if (item.tipo == TipoCadastro.professor) {
      titulo = 'Excluir professor';
      mensagem = 'Tem certeza que deseja excluir este professor?';
    } else {
      titulo = 'Excluir semestre';
      mensagem = 'Tem certeza que deseja excluir este semestre?';
    }

    showDeletePopup(
      context,
      title: titulo,
      message: mensagem,
      onConfirm: () async {
        try {
          String mensagemRetorno;

          if (item.tipo == TipoCadastro.disciplina) {
            mensagemRetorno =
                await CadastrosBaseService.excluirDisciplina(item.id);
          } else if (item.tipo == TipoCadastro.professor) {
            mensagemRetorno =
                await CadastrosBaseService.excluirProfessor(item.id);
          } else {
            mensagemRetorno =
                await CadastrosBaseService.excluirSemestre(item.id);
          }

          if (!mounted) return;

          setState(() {
            if (_idEmEdicao == item.id) {
              _limparEdicao();
            }
          });

          await _carregarItens();
          _agendarAviso(mensagemRetorno);
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

  void _excluirTurma(TurmaProfessorItem item) {
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
              _limparEdicao();
            }
          });

          await _carregarItens();
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

  Widget _buildTipoButton({
    required String label,
    required bool selecionado,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: selecionado ? Colors.black : Colors.white,
          foregroundColor: selecionado ? Colors.white : Colors.black,
          elevation: 0,
          side: BorderSide(
            color: selecionado ? Colors.black : Colors.black12,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCardVisualizacao(CadastroBaseItem item) {
    Widget conteudo;

    if (item.tipo == TipoCadastro.disciplina) {
      conteudo = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.nome ?? '',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Código: ${item.codigo ?? ''}',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ],
      );
    } else if (item.tipo == TipoCadastro.professor) {
      conteudo = Text(
        item.nome ?? '',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      );
    } else {
      conteudo = Text(
        '${item.ano ?? ''}.${item.periodo ?? ''}',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      );
    }

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
          conteudo,
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

  Widget _buildCardVisualizacaoTurma(TurmaProfessorItem item) {
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
                  onPressed: () => _iniciarEdicaoTurma(item),
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
                  onPressed: () => _excluirTurma(item),
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

  Widget _buildCardEdicao({CadastroBaseItem? item}) {
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
          if (_tipoSelecionado == TipoCadastro.disciplina) ...[
            _buildCampo(
              controller: _nomeController,
              hint: 'Nome da disciplina',
            ),
            const SizedBox(height: 12),
            _buildCampo(
              controller: _codigoController,
              hint: 'Código da disciplina',
            ),
          ],
          if (_tipoSelecionado == TipoCadastro.professor)
            _buildCampo(
              controller: _nomeController,
              hint: 'Nome do professor',
            ),
          if (_tipoSelecionado == TipoCadastro.semestre) ...[
            _buildCampo(
              controller: _anoController,
              hint: 'Ano',
            ),
            const SizedBox(height: 12),
            _buildCampo(
              controller: _periodoController,
              hint: 'Período',
            ),
          ],
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

  Widget _buildCardEdicaoTurma({TurmaProfessorItem? item}) {
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
                          : () => _salvarEdicaoTurma(item),
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
    if (!_mensagemJaExibida && _mensagemPendente != null && !_erroAtual) {
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

    final itensFiltrados = _itensFiltrados;
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
                  'Gerenciar cadastros',
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
              Row(
                children: [
                  _buildTipoButton(
                    label: 'Disciplina',
                    selecionado: !_abaTurmasSelecionada &&
                        _tipoSelecionado == TipoCadastro.disciplina,
                    onTap: () => _trocarTipo(TipoCadastro.disciplina),
                  ),
                  const SizedBox(width: 8),
                  _buildTipoButton(
                    label: 'Professor',
                    selecionado: !_abaTurmasSelecionada &&
                        _tipoSelecionado == TipoCadastro.professor,
                    onTap: () => _trocarTipo(TipoCadastro.professor),
                  ),
                  const SizedBox(width: 8),
                  _buildTipoButton(
                    label: 'Semestre',
                    selecionado: !_abaTurmasSelecionada &&
                        _tipoSelecionado == TipoCadastro.semestre,
                    onTap: () => _trocarTipo(TipoCadastro.semestre),
                  ),
                  const SizedBox(width: 8),
                  _buildTipoButton(
                    label: 'Turma',
                    selecionado: _abaTurmasSelecionada,
                    onTap: _trocarParaTurmas,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (value) {
                  setState(() {
                    _pesquisa = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: _hintPesquisa(_tipoSelecionado),
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
                  child: Text(
                    _abaTurmasSelecionada
                        ? 'Adicionar turma'
                        : 'Adicionar ${_tituloTipo(_tipoSelecionado)}',
                    style: const TextStyle(
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
                    : _abaTurmasSelecionada
                        ? turmasFiltradas.isEmpty && !_adicionandoNovo
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
                                itemCount: turmasFiltradas.length +
                                    (_adicionandoNovo ? 1 : 0),
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 14),
                                itemBuilder: (context, index) {
                                  if (_adicionandoNovo && index == 0) {
                                    return _buildCardEdicaoTurma();
                                  }

                                  final item = turmasFiltradas[
                                      _adicionandoNovo ? index - 1 : index];

                                  if (_idEmEdicao == item.id) {
                                    return _buildCardEdicaoTurma(item: item);
                                  }

                                  return _buildCardVisualizacaoTurma(item);
                                },
                              )
                        : itensFiltrados.isEmpty && !_adicionandoNovo
                            ? Center(
                                child: Text(
                                  'Nenhum ${_tituloTipoPlural(_tipoSelecionado)} encontrado.',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                itemCount: itensFiltrados.length +
                                    (_adicionandoNovo ? 1 : 0),
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 14),
                                itemBuilder: (context, index) {
                                  if (_adicionandoNovo && index == 0) {
                                    return _buildCardEdicao();
                                  }

                                  final item = itensFiltrados[
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