import 'package:flutter/material.dart';
import 'signup_form.dart';
import '../../widgets/signup_button.dart';
import '../../services/auth_service.dart';
import '../home/home_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _matriculaController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController =
      TextEditingController();

  final AuthService _authService = AuthService();

  bool _senhaVisivel = false;
  bool _confirmarSenhaVisivel = false;

  bool _carregando = false;
  String? _mensagemErro;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _matriculaController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  void _toggleSenhaVisivel() {
    setState(() {
      _senhaVisivel = !_senhaVisivel;
    });
  }

  void _toggleConfirmarSenhaVisivel() {
    setState(() {
      _confirmarSenhaVisivel = !_confirmarSenhaVisivel;
    });
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _carregando = true;
      _mensagemErro = null;
    });

    try {
      final response = await _authService.cadastrar(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        matricula: _matriculaController.text.trim(),
        senha: _senhaController.text,
      );

      if (!mounted) return;

      final int? alunoIdLogado =
          response['aluno_id'] ?? response['aluno']?['id'];

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(
            mensagemSucesso: 'Cadastro realizado com sucesso!',
            isCoordenacao: false,
            alunoIdLogado: alunoIdLogado,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _mensagemErro = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
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
              const SizedBox(height: 80),
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text(
                    'Seja\nbem-\nvindo(a)!',
                    style: TextStyle(
                      fontFamily: 'Michroma',
                      fontSize: 42,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              SignUpForm(
                formKey: _formKey,
                nomeController: _nomeController,
                emailController: _emailController,
                matriculaController: _matriculaController,
                senhaController: _senhaController,
                confirmarSenhaController: _confirmarSenhaController,
                senhaVisivel: _senhaVisivel,
                confirmarSenhaVisivel: _confirmarSenhaVisivel,
                onToggleSenhaVisivel: _toggleSenhaVisivel,
                onToggleConfirmarSenhaVisivel: _toggleConfirmarSenhaVisivel,
              ),
              if (_mensagemErro != null) ...[
                const SizedBox(height: 12),
                Text(
                  _mensagemErro!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ],
              const Spacer(),
              SignUpButton(
                onPressed: _carregando ? () {} : _cadastrar,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}