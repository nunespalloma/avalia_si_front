import 'package:flutter/material.dart';
import '../../widgets/success_popup.dart';
import 'select_turma_professor_page.dart';

class RegisterProfessorPage extends StatefulWidget {
  final TurmaProfessorItem turma;

  const RegisterProfessorPage({
    super.key,
    required this.turma,
  });

  @override
  State<RegisterProfessorPage> createState() => _RegisterProfessorPageState();
}

class _RegisterProfessorPageState extends State<RegisterProfessorPage> {
  late final TextEditingController _professorController;

  @override
  void initState() {
    super.initState();
    _professorController = TextEditingController(
      text: widget.turma.professor ?? '',
    );
  }

  @override
  void dispose() {
    _professorController.dispose();
    super.dispose();
  }

  void _salvarProfessor() {
    final nomeProfessor = _professorController.text.trim();

    if (nomeProfessor.isEmpty) {
      showTopMessageBanner(
        context,
        message: 'Informe o nome do professor.',
      );
      return;
    }

    showTopMessageBanner(
      context,
      message: 'Professor cadastrado com sucesso!',
    );

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      Navigator.pop(context, true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool jaPossuiProfessor = widget.turma.professor != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 24,
                  color: Colors.black,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Professor\nda Turma',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Container(
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
                      widget.turma.disciplina,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Turma: ${widget.turma.turma}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      jaPossuiProfessor
                          ? 'Professor atual: ${widget.turma.professor}'
                          : 'Professor atual: Não cadastrado',
                      style: TextStyle(
                        fontSize: 13,
                        color: jaPossuiProfessor
                            ? Colors.black87
                            : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Nome do Professor',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _professorController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Digite o nome do professor',
                  hintStyle: const TextStyle(
                    fontSize: 12,
                    color: Colors.black38,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.black12,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.black12,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _salvarProfessor,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    jaPossuiProfessor
                        ? 'Salvar Alteração'
                        : 'Cadastrar Professor',
                    style: const TextStyle(
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
}