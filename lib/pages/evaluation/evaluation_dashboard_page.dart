import 'package:flutter/material.dart';
import 'widgets/evaluation_comment_card.dart';
import '../../widgets/error_message.dart';
import '../../services/evaluation_dashboard_service.dart';

class EvaluationDashboardPage extends StatefulWidget {
  final int turmaId;
  final String disciplina;
  final String turma;
  final String professor;

  const EvaluationDashboardPage({
    super.key,
    required this.turmaId,
    required this.disciplina,
    required this.turma,
    required this.professor,
  });

  @override
  State<EvaluationDashboardPage> createState() =>
      _EvaluationDashboardPageState();
}

class _EvaluationDashboardPageState extends State<EvaluationDashboardPage> {
  bool _mostrarTodosComentarios = false;
  bool _carregando = true;
  String? _mensagemErro;
  EvaluationDashboardData? _dados;

  @override
  void initState() {
    super.initState();
    _carregarDashboard();
  }

  Future<void> _carregarDashboard() async {
    setState(() {
      _carregando = true;
      _mensagemErro = null;
    });

    try {
      final dados = await EvaluationDashboardService.buscarDashboard(
        turmaId: widget.turmaId,
      );

      if (!mounted) return;

      setState(() {
        _dados = dados;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _mensagemErro = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  String _textoAvaliacaoGeral(double nota) {
    if (nota <= 1) return 'Muito ruim';
    if (nota <= 2) return 'Ruim';
    if (nota <= 3) return 'Razoável';
    if (nota <= 4) return 'Boa';
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
      child: SizedBox(
        height: 96,
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
              SizedBox(
                height: 34,
                child: Text(
                  titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    height: 1.3,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                valor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
      ),
    );
  }

  Widget _buildEmptyMessage(String texto) {
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

  @override
  Widget build(BuildContext context) {
    final comentarios = _dados?.comentarios ?? [];
    final motivosTrancamento = _dados?.motivosTrancamento ?? [];
    final pontosQueAfligiram = _dados?.pontosQueAfligiram ?? [];

    final comentariosExibidos = _mostrarTodosComentarios
        ? comentarios
        : comentarios.take(2).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
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
                child: _carregando
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : _mensagemErro != null
                        ? SingleChildScrollView(
                            child: Column(
                              children: [
                                ErrorMessage(
                                  message: _mensagemErro!,
                                  onClose: () {
                                    setState(() {
                                      _mensagemErro = null;
                                    });
                                  },
                                ),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: _buildStars(
                                          _dados!.notaEstrelas,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        '${_dados!.notaFormatada} / 5.0',
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _textoAvaliacaoGeral(
                                          _dados!.notaEstrelas,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${comentarios.length} avaliações',
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
                                        _dados!.organizacaoConteudo,
                                        esquerda: 'Ruim',
                                        centro: 'Razoável',
                                        direita: 'Excelente',
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    _buildSummaryCard(
                                      'Didática na passagem',
                                      _valorParaTexto(
                                        _dados!.passagemConteudo,
                                        esquerda: 'Ruim',
                                        centro: 'Razoável',
                                        direita: 'Excelente',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _buildSummaryCard(
                                      'Quantidade de exercícios',
                                      _valorParaTexto(
                                        _dados!.quantidadeExercicios,
                                        esquerda: 'Pouco',
                                        centro: 'Razoável',
                                        direita: 'Suficiente',
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    _buildSummaryCard(
                                      'Avaliação condizente',
                                      _valorParaTexto(
                                        _dados!.avaliacaoCondizente,
                                        esquerda: 'Não',
                                        centro: 'Razoável',
                                        direita: 'Sim',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _buildSummaryCard(
                                      'Relação com respeito',
                                      _valorParaTexto(
                                        _dados!.professorRespeitoso,
                                        esquerda: 'Ruim',
                                        centro: 'Razoável',
                                        direita: 'Excelente',
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    _buildSummaryCard(
                                      'Professor(a) foi solícito(a)?',
                                      _valorParaTexto(
                                        _dados!.professorSolicito,
                                        esquerda: 'Não',
                                        centro: 'Razoável',
                                        direita: 'Sim',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _buildSummaryCard(
                                      'Assiduidade do(a) professor(a)',
                                      _valorParaTexto(
                                        _dados!.assiduidadeProfessor,
                                        esquerda: 'Ruim',
                                        centro: 'Razoável',
                                        direita: 'Excelente',
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    _buildSummaryCard(
                                      'Teoria x prática',
                                      _valorParaTexto(
                                        _dados!.teoriaPratica,
                                        esquerda: 'Ruim',
                                        centro: 'Razoável',
                                        direita: 'Excelente',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _buildSummaryCard(
                                      '% que trancou',
                                      _dados!
                                          .percentualTrancouTurmaFormatado,
                                    ),
                                    const SizedBox(width: 12),
                                    _buildSummaryCard(
                                      '% que acredita passar',
                                      _dados!
                                          .percentualAcreditaPassarFormatado,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Motivos de trancamento',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (motivosTrancamento.isEmpty)
                                  _buildEmptyMessage(
                                    'Nenhum motivo de trancamento informado.',
                                  )
                                else
                                  ...motivosTrancamento.map(
                                    (texto) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: EvaluationCommentCard(
                                        texto: texto,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 24),
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Pontos que mais afligiram',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (pontosQueAfligiram.isEmpty)
                                  _buildEmptyMessage(
                                    'Nenhum ponto informado.',
                                  )
                                else
                                  ...pontosQueAfligiram.map(
                                    (texto) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: EvaluationCommentCard(
                                        texto: texto,
                                      ),
                                    ),
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
                                if (comentarios.isEmpty)
                                  _buildEmptyMessage(
                                    'Ainda não há comentários para esta turma.',
                                  )
                                else ...[
                                  ...comentariosExibidos.map(
                                    (comentario) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: EvaluationCommentCard(
                                        texto: comentario,
                                      ),
                                    ),
                                  ),
                                  if (comentarios.length > 2)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 4,
                                        bottom: 20,
                                      ),
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
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
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