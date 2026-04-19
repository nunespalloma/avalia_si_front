import 'package:flutter/material.dart';
import '../../widgets/success_popup.dart';
import '../../widgets/confirm_delete_popup.dart';

class TurmaProfessorItem {
  final int id;
  String disciplina;
  String turma;
  String professor;

  TurmaProfessorItem({
    required this.id,
    required this.disciplina,
    required this.turma,
    required this.professor,
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
      professor: '',
    ),
    TurmaProfessorItem(
      id: 2,
      disciplina: 'Projeto de Aplicação II',
      turma: 'A1',
      professor: 'Profa. Mariana',
    ),
    TurmaProfessorItem(
      id: 3,
      disciplina: 'Tópicos em Redes de Computadores I',
      turma: 'A1',
      professor: '',
    ),
  ];

  String _pesquisa = '';
  int? _idEmEdicao;
  bool _adicionandoNovo = false;
  int _proximoId = 4;

  String? _mensagemPendente;
  bool _mensagemJaExibida = false;

  final TextEditingController _disciplinaController = TextEditingController();
  final TextEditingController _turmaController = TextEditingController();
  final TextEditingController _professorController = TextEditingController();

  @override
  void dispose() {
    _disciplinaController.dispose();
    _turmaController.dispose();
    _professorController.dispose();
    super.dispose();
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
          item.professor.toLowerCase().contains(termo);
    }).toList();
  }

  void _iniciarEdicao(TurmaProfessorItem item) {
    setState(() {
      _adicionandoNovo = false;
      _idEmEdicao = item.id;
      _disciplinaController.text = item.disciplina;
      _turmaController.text = item.turma;
      _professorController.text = item.professor;
    });
  }

  void _iniciarNovoCadastro() {
    setState(() {
      _idEmEdicao = null;
      _adicionandoNovo = true;
      _disciplinaController.clear();
      _turmaController.clear();
      _professorController.clear();
    });
  }

  void _cancelarEdicao() {
    setState(() {
      _idEmEdicao = null;
      _adicionandoNovo = false;
      _disciplinaController.clear();
      _turmaController.clear();
      _professorController.clear();
    });
  }

  void _salvarEdicao(TurmaProfessorItem item) {
    final disciplina = _disciplinaController.text.trim();
    final turma = _turmaController.text.trim();
    final professor = _professorController.text.trim();

    if (disciplina.isEmpty || turma.isEmpty || professor.isEmpty) {
      _agendarAviso('Preencha disciplina, turma e professor.');
      return;
    }

    setState(() {
      item.disciplina = disciplina;
      item.turma = turma;
      item.professor = professor;
      _idEmEdicao = null;
      _disciplinaController.clear();
      _turmaController.clear();
      _professorController.clear();
    });

    _agendarAviso('Informações atualizadas com sucesso.');
  }

  void _salvarNovoCadastro() {
    final disciplina = _disciplinaController.text.trim();
    final turma = _turmaController.text.trim();
    final professor = _professorController.text.trim();

    if (disciplina.isEmpty || turma.isEmpty || professor.isEmpty) {
      _agendarAviso('Preencha disciplina, turma e professor.');
      return;
    }

    setState(() {
      _turmas.add(
        TurmaProfessorItem(
          id: _proximoId++,
          disciplina: disciplina,
          turma: turma,
          professor: professor,
        ),
      );
      _adicionandoNovo = false;
      _disciplinaController.clear();
      _turmaController.clear();
      _professorController.clear();
    });

    _agendarAviso('Registro adicionado com sucesso.');
  }

 void _excluirItem(TurmaProfessorItem item) {
    showDeletePopup(
      context,
      onConfirm: () {
        setState(() {
          _turmas.removeWhere((t) => t.id == item.id);

          if (_idEmEdicao == item.id) {
            _idEmEdicao = null;
            _disciplinaController.clear();
            _turmaController.clear();
            _professorController.clear();
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
          _buildCampo(
            controller: _disciplinaController,
            hint: 'Disciplina',
          ),
          const SizedBox(height: 12),
          _buildCampo(
            controller: _turmaController,
            hint: 'Turma',
          ),
          const SizedBox(height: 12),
          _buildCampo(
            controller: _professorController,
            hint: 'Professor',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: isNovo
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
                  'Revisar disciplinas,\nturmas e professores',
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
                  hintText: 'Pesquisar disciplina, turma ou professor',
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
                    'Adicionar disciplina, turma e professor',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: turmasFiltradas.isEmpty && !_adicionandoNovo
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
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
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