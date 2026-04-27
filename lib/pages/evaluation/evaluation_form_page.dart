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
  double passagemConteudo = 2;
  double quantidadeExercicios = 1;
  double avaliacaoCondizente = 2;
  double relacaoRespeito = 1;
  double professorSolicito = 2;
  double assiduidadeProfessor = 2;
  double teoriaPratica = 2;

  bool trancouTurma = false;
  bool acreditaPassar = true;

  final TextEditingController comentarioController = TextEditingController();
  final TextEditingController porqueTrancouController =
      TextEditingController();
  final TextEditingController pontoQueAfligiuController =
      TextEditingController();

  bool _carregando = false;

  @override
  void dispose() {
    comentarioController.dispose();
    porqueTrancouController.dispose();
    pontoQueAfligiuController.dispose();
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
        passagemConteudo: passagemConteudo.round(),
        quantidadeExercicios: quantidadeExercicios.round(),
        avaliacaoCondizente: avaliacaoCondizente.round(),
        professorRespeitoso: relacaoRespeito.round(),
        professorSolicito: professorSolicito.round(),
        assiduidadeProfessor: assiduidadeProfessor.round(),
        teoriaPratica: teoriaPratica.round(),
        trancouTurma: trancouTurma,
        porqueTrancou: porqueTrancouController.text.trim(),
        acreditaPassar: acreditaPassar,
        pontoQueAfligiu: pontoQueAfligiuController.text.trim(),
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

  Widget _buildQuestionCard({
    required String titulo,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
              fontSize: 14,
              color: Colors.black,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildSwitchOption({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: onChanged,
      title: Text(
        value ? 'Sim' : 'Não',
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
      activeColor: Colors.black,
      activeTrackColor: Colors.black26,
      inactiveThumbColor: Colors.black54,
      inactiveTrackColor: Colors.black12,
    );
  }

  InputDecoration _buildTextFieldDecoration(String hintText) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      hintText: hintText,
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

                      const SizedBox(height: 34),

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
                        labelDireita: 'Excelente',
                      ),

                      const SizedBox(height: 34),

                      EvaluationSliderItem(
                        titulo: 'Didática na passagem do conteúdo:',
                        valor: passagemConteudo,
                        onChanged: (value) {
                          setState(() {
                            passagemConteudo = value;
                          });
                        },
                        labelEsquerda: 'Ruim',
                        labelCentro: 'Razoável',
                        labelDireita: 'Excelente',
                      ),

                      const SizedBox(height: 34),

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

                      const SizedBox(height: 34),

                      EvaluationSliderItem(
                        titulo:
                            'Avaliação condizente com o conteúdo dado:',
                        valor: avaliacaoCondizente,
                        onChanged: (value) {
                          setState(() {
                            avaliacaoCondizente = value;
                          });
                        },
                        labelEsquerda: 'Não',
                        labelCentro: 'Razoável',
                        labelDireita: 'Sim',
                      ),

                      const SizedBox(height: 34),

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
                        labelCentro: 'Razoável',
                        labelDireita: 'Excelente',
                      ),

                      const SizedBox(height: 34),

                      EvaluationSliderItem(
                        titulo: 'Professor(a) foi solícito(a)?',
                        valor: professorSolicito,
                        onChanged: (value) {
                          setState(() {
                            professorSolicito = value;
                          });
                        },
                        labelEsquerda: 'Não',
                        labelCentro: 'Razoável',
                        labelDireita: 'Sim',
                      ),

                      const SizedBox(height: 34),

                      EvaluationSliderItem(
                        titulo: 'Assiduidade do(a) professor(a):',
                        valor: assiduidadeProfessor,
                        onChanged: (value) {
                          setState(() {
                            assiduidadeProfessor = value;
                          });
                        },
                        labelEsquerda: 'Ruim',
                        labelCentro: 'Razoável',
                        labelDireita: 'Excelente',
                      ),

                      const SizedBox(height: 34),

                      EvaluationSliderItem(
                        titulo: 'Equilíbrio entre teoria e prática:',
                        valor: teoriaPratica,
                        onChanged: (value) {
                          setState(() {
                            teoriaPratica = value;
                          });
                        },
                        labelEsquerda: 'Ruim',
                        labelCentro: 'Razoável',
                        labelDireita: 'Excelente',
                      ),

                      const SizedBox(height: 34),

                      _buildQuestionCard(
                        titulo: 'Você trancou essa turma?',
                        child: Column(
                          children: [
                            _buildSwitchOption(
                              value: trancouTurma,
                              onChanged: (value) {
                                setState(() {
                                  trancouTurma = value;
                                });
                              },
                            ),
                            if (trancouTurma) ...[
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: porqueTrancouController,
                                minLines: 2,
                                maxLines: 4,
                                decoration: _buildTextFieldDecoration(
                                  'Por que você trancou a turma?',
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 26),

                      _buildQuestionCard(
                        titulo:
                            'Você acredita que irá passar nessa disciplina?',
                        child: _buildSwitchOption(
                          value: acreditaPassar,
                          onChanged: (value) {
                            setState(() {
                              acreditaPassar = value;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 26),

                      _buildQuestionCard(
                        titulo:
                            'Qual ponto mais te afligiu nessa disciplina?',
                        child: TextFormField(
                          controller: pontoQueAfligiuController,
                          minLines: 2,
                          maxLines: 4,
                          decoration: _buildTextFieldDecoration(
                            'Escreva aqui...',
                          ),
                        ),
                      ),

                      const SizedBox(height: 26),

                      _buildQuestionCard(
                        titulo:
                            'Deixe aqui sua avaliação detalhada, se desejar:',
                        child: TextFormField(
                          controller: comentarioController,
                          minLines: 4,
                          maxLines: 6,
                          decoration: _buildTextFieldDecoration(
                            'Escreva aqui...',
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