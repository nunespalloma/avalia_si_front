import 'package:flutter/material.dart';
import 'evaluation_form_page.dart';
import '../../widgets/success_popup.dart';

class TurmaAvaliacao {
  final String disciplina;
  final String turma;
  bool avaliada;

  TurmaAvaliacao({
    required this.disciplina,
    required this.turma,
    required this.avaliada,
  });
}

class ProvideEvaluationPage extends StatefulWidget {
  const ProvideEvaluationPage({super.key});

  @override
  State<ProvideEvaluationPage> createState() => _ProvideEvaluationPageState();
}

class _ProvideEvaluationPageState extends State<ProvideEvaluationPage> {
  final List<TurmaAvaliacao> _turmasSemestreAnterior = [
    TurmaAvaliacao(
      disciplina: 'Algoritmos e Programação',
      turma: 'T1 - Prof. Carlos',
      avaliada: true,
    ),
    TurmaAvaliacao(
      disciplina: 'Banco de Dados',
      turma: 'T2 - Profa. Mariana',
      avaliada: false,
    ),
    TurmaAvaliacao(
      disciplina: 'Engenharia de Software',
      turma: 'T1 - Prof. Roberto',
      avaliada: false,
    ),
    TurmaAvaliacao(
      disciplina: 'Estrutura de Dados',
      turma: 'T3 - Profa. Renata',
      avaliada: true,
    ),
  ];

  Future<void> _abrirTelaAvaliacao(TurmaAvaliacao item) async {
    final avaliacaoEnviada = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EvaluationFormPage(
          disciplina: item.disciplina,
          turma: item.turma,
        ),
      ),
    );

    if (avaliacaoEnviada == true) {
      setState(() {
        item.avaliada = true;
      });

      showTopMessageBanner(
        context,
        message: 'Avaliação enviada com sucesso!',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final avaliadas =
        _turmasSemestreAnterior.where((item) => item.avaliada).toList();

    final pendentes =
        _turmasSemestreAnterior.where((item) => !item.avaliada).toList();

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
                onPressed: () {
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 24),

              const Center(
                child: Text(
                  'Fornecer\navaliação',
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

              const Text(
                'Avalie as turmas cursadas no semestre anterior.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildSectionTitle(
                        'Turmas pendentes',
                        pendentes.length,
                      ),
                      const SizedBox(height: 12),

                      if (pendentes.isEmpty)
                        _buildEmptyState(
                          'Você já avaliou todas as turmas.',
                        )
                      else
                        ...pendentes.map(_buildTurmaCardPendente),

                      const SizedBox(height: 24),

                      _buildSectionTitle(
                        'Turmas avaliadas',
                        avaliadas.length,
                      ),
                      const SizedBox(height: 12),

                      if (avaliadas.isEmpty)
                        _buildEmptyState(
                          'Nenhuma turma avaliada ainda.',
                        )
                      else
                        ...avaliadas.map(_buildTurmaCardAvaliada),
                    ],
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

  Widget _buildSectionTitle(String titulo, int quantidade) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black,
          ),
        ),
        Text(
          '$quantidade',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildTurmaCardPendente(TurmaAvaliacao item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),
        title: Text(
          item.disciplina,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            item.turma,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
        ),
        trailing: ElevatedButton(
          onPressed: () async {
            await _abrirTelaAvaliacao(item);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'Avaliar',
            style: TextStyle(
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTurmaCardAvaliada(TurmaAvaliacao item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),
        title: Text(
          item.disciplina,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            item.turma,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFECECEC),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Avaliada',
            style: TextStyle(
              fontSize: 11,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String texto) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black54,
          height: 1.4,
        ),
      ),
    );
  }
}