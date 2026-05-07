import 'package:flutter/material.dart';
import '../../widgets/success_popup.dart';
import '../../widgets/logout_popup.dart';
import '../welcome/welcome_page.dart';
import '../evaluation/provide_evaluation_page.dart';
import '../evaluation/view_evaluation_page.dart';
import '../coordenacao/import_csv_page.dart';
import '../coordenacao/select_cadastros_base_page.dart';
import '../../services/provide_evaluation_service.dart';

class HomePage extends StatefulWidget {
  final String? mensagemSucesso;
  final bool jaAvaliouUltimoSemestre;
  final bool isCoordenacao;
  final int? alunoIdLogado;

  const HomePage({
    super.key,
    this.mensagemSucesso,
    this.jaAvaliouUltimoSemestre = false,
    this.isCoordenacao = false,
    this.alunoIdLogado,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late bool _jaAvaliouUltimoSemestre;
  bool _mensagemJaExibida = false;

  @override
  void initState() {
    super.initState();
    _jaAvaliouUltimoSemestre = widget.jaAvaliouUltimoSemestre;
    if (!widget.isCoordenacao && widget.alunoIdLogado != null) {
      _atualizarStatusAvaliacoes();
    }
  }

  Future<void> _atualizarStatusAvaliacoes() async {
    try {
      final turmas = await ProvideEvaluationService.listarTurmasParaAvaliacao(
        alunoId: widget.alunoIdLogado!,
      );

      if (!mounted) return;

      setState(() {
        _jaAvaliouUltimoSemestre =
            turmas.isNotEmpty && turmas.every((item) => item.avaliada);
      });
    } catch (_) {}
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_mensagemJaExibida && widget.mensagemSucesso != null) {
      _mensagemJaExibida = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        showTopMessageBanner(
          context,
          message: widget.mensagemSucesso!,
        );
      });
    }
  }

  Future<void> _abrirTelaFornecerAvaliacao() async {
    if (widget.alunoIdLogado == null) {
      showTopMessageBanner(
        context,
        message: 'Não foi possível identificar o aluno logado.',
      );
      return;
    }

    final concluiuTodas = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ProvideEvaluationPage(
          alunoId: widget.alunoIdLogado!,
        ),
      ),
    );

    if (concluiuTodas == true) {
      setState(() {
        _jaAvaliouUltimoSemestre = true;
      });
    } else {
      await _atualizarStatusAvaliacoes();
    }
  }

  void _abrirTelaAvaliacoes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ViewEvaluationPage(),
      ),
    );
  }

  void _abrirTelaImportarCsv() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ImportCsvPage(),
      ),
    );
  }

  void _abrirTelaCadastrosIniciais() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SelectCadastrosBasePage(),
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
        onPressed: onPressed,
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
          texto,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCoordenacao) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.logout,
                      size: 28,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      showLogoutPopup(
                        context,
                        onConfirm: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WelcomePage(
                                mensagemSucesso: 'Saiu com sucesso!',
                              ),
                            ),
                            (route) => false,
                          );
                        },
                      );
                    },
                  ),
                ),

                const Spacer(),

                Column(
                  children: const [
                    Text(
                      'Olá,',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'gerencie os cadastros e importe os planos de aula ou verifique as avaliações existentes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                Column(
                  children: [
                    _buildBotaoPrincipal(
                      texto: 'Gerenciar Cadastros',
                      onPressed: _abrirTelaCadastrosIniciais,
                    ),
                    const SizedBox(height: 16),
                    _buildBotaoPrincipal(
                      texto: 'Importar planos de aula dos alunos',
                      onPressed: _abrirTelaImportarCsv,
                    ),
                    const SizedBox(height: 16),
                    _buildBotaoPrincipal(
                      texto: 'Ver Avaliações',
                      onPressed: _abrirTelaAvaliacoes,
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
    }

    // 👇 resto do arquivo NÃO alterado

    final String titulo = _jaAvaliouUltimoSemestre ? 'Parabéns,' : 'Poxa,';

    final String subtitulo = _jaAvaliouUltimoSemestre
        ? 'você já avaliou o\núltimo semestre...'
        : 'parece que você\nainda não avaliou o\núltimo semestre...';

    final String descricao = _jaAvaliouUltimoSemestre
        ? 'Verifique as avaliações atualizadas de outros alunos neste semestre.'
        : 'Realize sua avaliação para ter acesso às avaliações atualizadas de outros alunos neste semestre.';

    final String textoBotao = _jaAvaliouUltimoSemestre
        ? 'Verificar Avaliações'
        : 'Fornecer Avaliação';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.logout,
                    size: 28,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    showLogoutPopup(
                      context,
                      onConfirm: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WelcomePage(
                              mensagemSucesso: 'Saiu com sucesso!',
                            ),
                          ),
                          (route) => false,
                        );
                      },
                    );
                  },
                ),
              ),
              const Spacer(),
              Column(
                children: [
                  Text(
                    titulo,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitulo,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.35,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 72),
              SizedBox(
                width: 280,
                child: Text(
                  descricao,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
              const Spacer(),
              _buildBotaoPrincipal(
                texto: textoBotao,
                onPressed: () async {
                  if (_jaAvaliouUltimoSemestre) {
                    _abrirTelaAvaliacoes();
                  } else {
                    await _abrirTelaFornecerAvaliacao();
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}