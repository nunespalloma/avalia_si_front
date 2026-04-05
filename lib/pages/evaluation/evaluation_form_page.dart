import 'package:flutter/material.dart';
import '../../widgets/evaluation_slider_item.dart';

class EvaluationFormPage extends StatefulWidget {
  final String disciplina;
  final String turma;

  const EvaluationFormPage({
    super.key,
    required this.disciplina,
    required this.turma,
  });

  @override
  State<EvaluationFormPage> createState() => _EvaluationFormPageState();
}

class _EvaluationFormPageState extends State<EvaluationFormPage> {
  double organizacaoConteudo = 2;
  double quantidadeExercicios = 1;
  double avaliacaoCondizente = 2;
  double relacaoRespeito = 1;
  double professorSolicito = 2;
  double assiduidadeProfessor = 2;

  final TextEditingController comentarioController = TextEditingController();

  @override
  void dispose() {
    comentarioController.dispose();
    super.dispose();
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

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Enviar avaliação',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}