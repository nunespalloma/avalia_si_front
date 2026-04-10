import 'package:flutter/material.dart';
import '../../widgets/success_popup.dart';
import '../../widgets/logout_popup.dart';
import '../welcome/welcome_page.dart';
import '../evaluation/provide_evaluation_page.dart';
import '../evaluation/view_evaluation_page.dart';

class HomePage extends StatefulWidget {
  final String? mensagemSucesso;
  final bool jaAvaliouUltimoSemestre;

  const HomePage({
    super.key,
    this.mensagemSucesso,
    this.jaAvaliouUltimoSemestre = false,
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
    final concluiuTodas = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const ProvideEvaluationPage(),
      ),
    );

    if (concluiuTodas == true) {
      setState(() {
        _jaAvaliouUltimoSemestre = true;
      });
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

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  IconButton(
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
                ],
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

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_jaAvaliouUltimoSemestre) {
                      _abrirTelaAvaliacoes();
                    } else {
                      await _abrirTelaFornecerAvaliacao();
                    }
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
                  child: Text(
                    textoBotao,
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