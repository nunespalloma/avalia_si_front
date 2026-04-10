import 'package:flutter/material.dart';
import 'evaluation_dashboard_page.dart';

class TurmaResultado {
  final String disciplina;
  final String turma;
  final String professor;

  TurmaResultado({
    required this.disciplina,
    required this.turma,
    required this.professor,
  });
}

class ViewEvaluationPage extends StatefulWidget {
  const ViewEvaluationPage({super.key});

  @override
  State<ViewEvaluationPage> createState() => _ViewEvaluationPageState();
}

class _ViewEvaluationPageState extends State<ViewEvaluationPage> {
  final List<TurmaResultado> _turmasAvaliadas = [
    TurmaResultado(
      disciplina: 'Algoritmos e Programação',
      turma: 'T1',
      professor: 'Prof. Carlos',
    ),
    TurmaResultado(
      disciplina: 'Estrutura de Dados',
      turma: 'T3',
      professor: 'Profa. Renata',
    ),
    TurmaResultado(
      disciplina: 'Banco de Dados',
      turma: 'T2',
      professor: 'Profa. Mariana',
    ),
  ];

  void _abrirDashboard(TurmaResultado item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EvaluationDashboardPage(
          disciplina: item.disciplina,
          turma: item.turma,
          professor: item.professor,
        ),
      ),
    );
  }

  void _voltarParaHome() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
                onPressed: _voltarParaHome,
              ),

              const SizedBox(height: 24),

              const Center(
                child: Text(
                  'Ver Avaliações',
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
                'Escolha uma turma já avaliada para visualizar os resultados.',
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
                        'Turmas disponíveis',
                        _turmasAvaliadas.length,
                      ),
                      const SizedBox(height: 12),

                      if (_turmasAvaliadas.isEmpty)
                        _buildEmptyState(
                          'Você ainda não possui turmas avaliadas para visualizar.',
                        )
                      else
                        ..._turmasAvaliadas.map(_buildTurmaCardResultado),
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

  Widget _buildTurmaCardResultado(TurmaResultado item) {
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
            '${item.turma} - ${item.professor}',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
        ),
        trailing: ElevatedButton(
          onPressed: () {
            _abrirDashboard(item);
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
            'Ver',
            style: TextStyle(
              fontSize: 11,
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