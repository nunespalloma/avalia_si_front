import 'package:flutter/material.dart';
import 'register_professor_page.dart';

class TurmaProfessorItem {
  final int id;
  final String disciplina;
  final String turma;
  final String? professor;

  TurmaProfessorItem({
    required this.id,
    required this.disciplina,
    required this.turma,
    this.professor,
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
      professor: null,
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
      professor: null,
    ),
  ];

  String _pesquisa = '';

  List<TurmaProfessorItem> get _turmasFiltradas {
    final termo = _pesquisa.toLowerCase();

    return _turmas.where((turma) {
      return turma.disciplina.toLowerCase().contains(termo) ||
          turma.turma.toLowerCase().contains(termo) ||
          (turma.professor?.toLowerCase().contains(termo) ?? false);
    }).toList();
  }

  void _abrirCadastroProfessor(TurmaProfessorItem turma) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterProfessorPage(turma: turma),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                  'Cadastrar\nProfessor',
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
              const SizedBox(height: 24),
              Expanded(
                child: _turmasFiltradas.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhuma turma encontrada.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _turmasFiltradas.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final turma = _turmasFiltradas[index];
                          final bool semProfessor = turma.professor == null;

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
                                  turma.disciplina,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Turma: ${turma.turma}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  semProfessor
                                      ? 'Professor: Não cadastrado'
                                      : 'Professor: ${turma.professor}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: semProfessor
                                        ? Colors.black54
                                        : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        _abrirCadastroProfessor(turma),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    child: Text(
                                      semProfessor
                                          ? 'Cadastrar Professor'
                                          : 'Alterar Professor',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
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