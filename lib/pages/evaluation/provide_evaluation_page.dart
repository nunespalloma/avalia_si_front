import 'package:flutter/material.dart';
import 'evaluation_form_page.dart';
import '../../widgets/success_popup.dart';
import '../../widgets/error_message.dart';
import '../../services/provide_evaluation_service.dart';

class ProvideEvaluationPage extends StatefulWidget {
  final int alunoId;

  const ProvideEvaluationPage({
    super.key,
    required this.alunoId,
  });

  @override
  State<ProvideEvaluationPage> createState() =>
      _ProvideEvaluationPageState();
}

class _ProvideEvaluationPageState
    extends State<ProvideEvaluationPage> {
  List<TurmaAvaliacao> _turmasSemestreAnterior =
      [];
  bool _carregando = true;
  String? _mensagemErro;

  bool get _todasAvaliadas =>
      _turmasSemestreAnterior.isNotEmpty &&
      _turmasSemestreAnterior.every(
        (item) => item.avaliada,
      );

  @override
  void initState() {
    super.initState();
    _carregarTurmas();
  }

  Future<void> _carregarTurmas() async {
    setState(() {
      _carregando = true;
      _mensagemErro = null;
    });

    try {
      final turmas =
          await ProvideEvaluationService
              .listarTurmasParaAvaliacao(
        alunoId: widget.alunoId,
      );

      if (!mounted) return;

      setState(() {
        _turmasSemestreAnterior = turmas;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _mensagemErro = e
            .toString()
            .replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  Future<void> _abrirTelaAvaliacao(
    TurmaAvaliacao item,
  ) async {
    final avaliacaoEnviada =
        await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EvaluationFormPage(
          alunoId: widget.alunoId,
          planoAulaAlunoId: item.id,
          disciplina: item.disciplina,
          turma: item.turma,
        ),
      ),
    );

    if (avaliacaoEnviada == true) {
      await _carregarTurmas();

      if (!mounted) return;

      showTopMessageBanner(
        context,
        message:
            'Avaliação enviada com sucesso!',
      );
    }
  }

  void _voltarParaHome() {
    Navigator.pop(
      context,
      _todasAvaliadas,
    );
  }

  Widget _buildBotaoPrincipal({
    required String texto,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          padding:
              const EdgeInsets.symmetric(
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(6),
          ),
        ),
        child: Text(
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
    final avaliadas =
        _turmasSemestreAnterior
            .where(
              (item) => item.avaliada,
            )
            .toList();

    final pendentes =
        _turmasSemestreAnterior
            .where(
              (item) => !item.avaliada,
            )
            .toList();

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.fromLTRB(
            24,
            32,
            24,
            24,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 24,
                  color: Colors.black,
                ),
                onPressed:
                    _voltarParaHome,
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Fornecer\navaliação',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight:
                        FontWeight.w500,
                    color: Colors.black,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Avalie as turmas cursadas no semestre anterior.',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: _carregando
                    ? const Center(
                        child:
                            CircularProgressIndicator(),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            if (_mensagemErro !=
                                null) ...[
                              ErrorMessage(
                                message:
                                    _mensagemErro!,
                                onClose: () {
                                  setState(() {
                                    _mensagemErro =
                                        null;
                                  });
                                },
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                            ],
                            _buildSectionTitle(
                              'Turmas pendentes',
                              pendentes.length,
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            if (pendentes
                                .isEmpty)
                              _buildEmptyState(
                                'Você já avaliou todas as turmas.',
                              )
                            else
                              ...pendentes.map(
                                _buildTurmaCardPendente,
                              ),
                            const SizedBox(
                              height: 24,
                            ),
                            _buildSectionTitle(
                              'Turmas avaliadas',
                              avaliadas.length,
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            if (avaliadas
                                .isEmpty)
                              _buildEmptyState(
                                'Nenhuma turma avaliada ainda.',
                              )
                            else
                              ...avaliadas.map(
                                _buildTurmaCardAvaliada,
                              ),
                          ],
                        ),
                      ),
              ),
              if (_todasAvaliadas) ...[
                const SizedBox(height: 8),
                _buildBotaoPrincipal(
                  texto:
                      'Voltar para início',
                  onPressed:
                      _voltarParaHome,
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    String titulo,
    int quantidade,
  ) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment
              .spaceBetween,
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

  Widget _buildTurmaCardPendente(
    TurmaAvaliacao item,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(10),
        border: Border.all(
          color: Colors.black12,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    item.disciplina,
                    softWrap: true,
                    style:
                        const TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight
                              .w600,
                      color:
                          Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    '${item.turma} • ${item.semestre}',
                    softWrap: true,
                    style:
                        const TextStyle(
                      fontSize: 12,
                      color: Colors
                          .black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () async {
                await _abrirTelaAvaliacao(
                  item,
                );
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.black,
                foregroundColor:
                    Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
              ),
              child: const Text(
                'Avaliar',
                style: TextStyle(
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTurmaCardAvaliada(
    TurmaAvaliacao item,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(10),
        border: Border.all(
          color: Colors.black12,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    item.disciplina,
                    softWrap: true,
                    style:
                        const TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight
                              .w600,
                      color:
                          Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    '${item.turma} • ${item.semestre}',
                    softWrap: true,
                    style:
                        const TextStyle(
                      fontSize: 12,
                      color: Colors
                          .black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration:
                  BoxDecoration(
                color: const Color(
                  0xFFECECEC,
                ),
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),
              child: const Text(
                'Avaliada',
                style: TextStyle(
                  fontSize: 11,
                  color:
                      Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    String texto,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(10),
        border: Border.all(
          color: Colors.black12,
        ),
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