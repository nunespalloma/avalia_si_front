import 'package:flutter/material.dart';
import 'widgets/evaluation_comment_card.dart';

class EvaluationDashboardPage extends StatefulWidget {
  final String disciplina;
  final String turma;
  final String professor;

  final double organizacaoConteudo;
  final double quantidadeExercicios;
  final double avaliacaoCondizente;
  final double relacaoRespeito;
  final double professorSolicito;
  final double assiduidadeProfessor;

  final List<String> comentarios;

  const EvaluationDashboardPage({
    super.key,
    required this.disciplina,
    required this.turma,
    required this.professor,
    this.organizacaoConteudo = 2,
    this.quantidadeExercicios = 1,
    this.avaliacaoCondizente = 2,
    this.relacaoRespeito = 1,
    this.professorSolicito = 2,
    this.assiduidadeProfessor = 2,
    this.comentarios = const [
      'O semestre foi bom, contando com boa experiência de aprendizado, exercício e materiais condizentes com a prova.',
      'O semestre foi proveitoso, porém, o trabalho da disciplina ficou muito extenso para um semestre.',
      'Professor muito respeitoso e organizado. As aulas foram claras e o conteúdo foi passado de forma bem objetiva.',
      'A disciplina foi boa, mas senti falta de mais exercícios práticos ao longo do semestre.',
      'No geral gostei bastante. A avaliação foi coerente com o que foi trabalhado em sala.',
    ],
  });

  @override
  State<EvaluationDashboardPage> createState() =>
      _EvaluationDashboardPageState();
}

class _EvaluationDashboardPageState extends State<EvaluationDashboardPage> {
  bool _mostrarTodosComentarios = false;

  double get _mediaGeral {
    final soma =
        widget.organizacaoConteudo +
        widget.quantidadeExercicios +
        widget.avaliacaoCondizente +
        widget.relacaoRespeito +
        widget.professorSolicito +
        widget.assiduidadeProfessor;

    return soma / 6;
  }

  double get _notaEstrelas {
    return ((_mediaGeral / 2) * 5);
  }

  String _notaFormatada() {
    return _notaEstrelas.toStringAsFixed(1);
  }

  String _textoAvaliacaoGeral() {
    if (_notaEstrelas <= 1) return 'Muito ruim';
    if (_notaEstrelas <= 2) return 'Ruim';
    if (_notaEstrelas <= 3) return 'Razoável';
    if (_notaEstrelas <= 4) return 'Boa';
    return 'Excelente';
  }

  String _valorParaTexto(
    double valor, {
    required String esquerda,
    required String centro,
    required String direita,
  }) {
    if (valor <= 0) return esquerda;
    if (valor <= 1) return centro;
    return direita;
  }

  List<Widget> _buildStars(double rating) {
    final estrelas = <Widget>[];

    for (int i = 1; i <= 5; i++) {
      IconData icon;

      if (rating >= i) {
        icon = Icons.star_rounded;
      } else if (rating >= i - 0.5) {
        icon = Icons.star_half_rounded;
      } else {
        icon = Icons.star_border_rounded;
      }

      estrelas.add(
        Icon(
          icon,
          size: 28,
          color: Colors.black,
        ),
      );
    }

    return estrelas;
  }

  Widget _buildSummaryCard(String titulo, String valor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              valor,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final comentariosExibidos =
        _mostrarTodosComentarios
            ? widget.comentarios
            : widget.comentarios.take(2).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Row(
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
                ],
              ),

              const SizedBox(height: 8),

              const Text(
                'Resumo da Avaliação',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                '${widget.disciplina} - ${widget.professor} - ${widget.turma}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 22),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 22,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Nota geral',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _buildStars(_notaEstrelas),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${_notaFormatada()} / 5.0',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _textoAvaliacaoGeral(),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${widget.comentarios.length} avaliações',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      Row(
                        children: [
                          _buildSummaryCard(
                            'Organização do conteúdo',
                            _valorParaTexto(
                              widget.organizacaoConteudo,
                              esquerda: 'Ruim',
                              centro: 'Razoável',
                              direita: 'Boa',
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildSummaryCard(
                            'Quantidade de exercícios',
                            _valorParaTexto(
                              widget.quantidadeExercicios,
                              esquerda: 'Pouco',
                              centro: 'Razoável',
                              direita: 'Suficiente',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          _buildSummaryCard(
                            'Avaliação condizente',
                            _valorParaTexto(
                              widget.avaliacaoCondizente,
                              esquerda: 'Não',
                              centro: 'Média',
                              direita: 'Sim',
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildSummaryCard(
                            'Relação com respeito',
                            _valorParaTexto(
                              widget.relacaoRespeito,
                              esquerda: 'Ruim',
                              centro: 'Média',
                              direita: 'Boa',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          _buildSummaryCard(
                            'Professor(a) foi solícito(a)?',
                            _valorParaTexto(
                              widget.professorSolicito,
                              esquerda: 'Não',
                              centro: 'Médio',
                              direita: 'Sim',
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildSummaryCard(
                            'Assiduidade do(a) professor(a)',
                            _valorParaTexto(
                              widget.assiduidadeProfessor,
                              esquerda: 'Ruim',
                              centro: 'Média',
                              direita: 'Boa',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Comentários',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      if (widget.comentarios.isEmpty)
                        Container(
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
                          child: const Text(
                            'Ainda não há comentários para esta turma.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              height: 1.4,
                            ),
                          ),
                        )
                      else ...[
                        ...comentariosExibidos.map(
                          (comentario) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: EvaluationCommentCard(
                              texto: comentario,
                            ),
                          ),
                        ),

                        if (widget.comentarios.length > 2)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, bottom: 8),
                            child: SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _mostrarTodosComentarios =
                                        !_mostrarTodosComentarios;
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  side: const BorderSide(
                                    color: Colors.black26,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  _mostrarTodosComentarios
                                      ? 'Ver menos comentários'
                                      : 'Ver mais comentários',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}