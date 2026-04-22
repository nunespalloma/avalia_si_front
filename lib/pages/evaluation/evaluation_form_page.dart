import 'package:flutter/material.dart';
import '../../widgets/evaluation_slider_item.dart';
import '../../widgets/success_popup.dart';
import '../../services/evaluation_form_service.dart';

class EvaluationFormPage extends StatefulWidget {
  final int alunoId;
  final int planoAulaAlunoId;
  final String disciplina;
  final String turma;

  const EvaluationFormPage({
    super.key,
    required this.alunoId,
    required this.planoAulaAlunoId,
    required this.disciplina,
    required this.turma,
  });

  @override
  State<EvaluationFormPage> createState() => _EvaluationFormPageState();
}

class _EvaluationFormPageState extends State<EvaluationFormPage> {
  int avaliacaoGeral = 4;

  double organizacaoConteudo = 2;
  double quantidadeExercicios = 1;
  double avaliacaoCondizente = 2;
  double relacaoRespeito = 1;
  double professorSolicito = 2;
  double assiduidadeProfessor = 2;

  final TextEditingController comentarioController = TextEditingController();

  bool _carregando = false;

  @override
  void dispose() {
    comentarioController.dispose();
    super.dispose();
  }

  String _textoAvaliacaoGeral() {
    switch (avaliacaoGeral) {
      case 1:
        return 'Muito ruim';
      case 2:
        return 'Ruim';
      case 3:
        return 'Razoável';
      case 4:
        return 'Boa';
      case 5:
        return 'Excelente';
      default:
        return '';
    }
  }

  Future<void> _enviarAvaliacao() async {
    setState(() {
      _carregando = true;
    });

    try {
      await EvaluationFormService.enviarAvaliacao(
        alunoId: widget.alunoId,
        planoAulaAlunoId: widget.planoAulaAlunoId,
        avaliacaoGeral: avaliacaoGeral,
        organizacaoConteudo: organizacaoConteudo.round(),
        quantidadeExercicios: quantidadeExercicios.round(),
        avaliacaoCondizente: avaliacaoCondizente.round(),
        professorRespeitoso: relacaoRespeito.round(),
        professorSolicito: professorSolicito.round(),
        assiduidadeProfessor: assiduidadeProfessor.round(),
        aspectosGerais: comentarioController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      final mensagem = e.toString().replaceFirst('Exception: ', '');

      showTopMessageBanner(
        context,
        message: mensagem,
      );
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  Widget _buildStarRating() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          const Text(
            'Avaliação geral',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Como foi sua experiência geral nessa turma?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final estrela = index + 1;

              return IconButton(
                onPressed: () {
                  setState(() {
                    avaliacaoGeral = estrela;
                  });
                },
                splashRadius: 22,
                icon: Icon(
                  estrela <= avaliacaoGeral
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  size: 34,
                  color: Colors.black,
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          Text(
            '$avaliacaoGeral/5 - ${_textoAvaliacaoGeral()}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotaoPrincipal({
    required String texto,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _carregando ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: _carregando
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                texto,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.disciplina,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.turma,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildStarRating(),
                      const SizedBox(height: 26),
                      EvaluationSliderItem(
                        titulo: 'Organização do conteúdo:',
                        valor: organizacaoConteudo,
                        onChanged: (value) {
                          setState(() {
                            organizacaoConteudo = value;
                          });
                        },
                        labelEsquerda: 'Ruim',
                        labelCentro: 'Razoável',
                        labelDireita: 'Boa',
                      ),
                      const SizedBox(height: 26),
                      EvaluationSliderItem(
                        titulo: 'Quantidade de exercícios:',
                        valor: quantidadeExercicios,
                        onChanged: (value) {
                          setState(() {
                            quantidadeExercicios = value;
                          });
                        },
                        labelEsquerda: 'Pouco',
                        labelCentro: 'Razoável',
                        labelDireita: 'Suficiente',
                      ),
                      const SizedBox(height: 26),
                      EvaluationSliderItem(
                        titulo: 'Avaliação condizente com o conteúdo dado:',
                        valor: avaliacaoCondizente,
                        onChanged: (value) {
                          setState(() {
                            avaliacaoCondizente = value;
                          });
                        },
                        labelEsquerda: 'Não',
                        labelCentro: 'Média',
                        labelDireita: 'Sim',
                      ),
                      const SizedBox(height: 26),
                      EvaluationSliderItem(
                        titulo:
                            'Relação com o(a) professor(a) no quesito respeito:',
                        valor: relacaoRespeito,
                        onChanged: (value) {
                          setState(() {
                            relacaoRespeito = value;
                          });
                        },
                        labelEsquerda: 'Ruim',
                        labelCentro: 'Média',
                        labelDireita: 'Boa',
                      ),
                      const SizedBox(height: 26),
                      EvaluationSliderItem(
                        titulo: 'Professor(a) foi solícito(a)?',
                        valor: professorSolicito,
                        onChanged: (value) {
                          setState(() {
                            professorSolicito = value;
                          });
                        },
                        labelEsquerda: 'Não',
                        labelCentro: 'Médio',
                        labelDireita: 'Sim',
                      ),
                      const SizedBox(height: 26),
                      EvaluationSliderItem(
                        titulo: 'Assiduidade do(a) professor(a):',
                        valor: assiduidadeProfessor,
                        onChanged: (value) {
                          setState(() {
                            assiduidadeProfessor = value;
                          });
                        },
                        labelEsquerda: 'Ruim',
                        labelCentro: 'Média',
                        labelDireita: 'Boa',
                      ),
                      const SizedBox(height: 30),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Deixe aqui sua avaliação detalhada, se desejar:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: comentarioController,
                        minLines: 4,
                        maxLines: 6,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Escreva aqui...',
                          hintStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.black38,
                          ),
                          contentPadding: const EdgeInsets.all(16),
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
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              _buildBotaoPrincipal(
                texto: 'Enviar avaliação',
                onPressed: _enviarAvaliacao,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}