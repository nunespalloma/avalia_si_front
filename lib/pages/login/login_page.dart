import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../widgets/login_button.dart';
import '../home/home_page.dart';
import 'login_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final AuthService _authService = AuthService();

  bool _senhaVisivel = false;
  bool _carregando = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _toggleSenhaVisivel() {
    setState(() {
      _senhaVisivel = !_senhaVisivel;
    });
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final senha = _senhaController.text;

    setState(() {
      _carregando = true;
    });

    try {
      final response = await _authService.login(email, senha);

      if (!mounted) return;

      final usuario = response['usuario'] as Map<String, dynamic>;
      final bool isCoordenacao = usuario['is_coordenacao'] == true;

      setState(() {
        _errorMessage = null;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(
            mensagemSucesso: 'Login realizado com sucesso!',
            isCoordenacao: isCoordenacao,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'E-mail ou senha incorretos. Tente novamente.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
                child: Text(
                  'É bom\nter você\npor aqui!',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontFamily: 'Michroma',
                    fontSize: 42,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    LoginForm(
                      formKey: _formKey,
                      emailController: _emailController,
                      senhaController: _senhaController,
                      senhaVisivel: _senhaVisivel,
                      errorMessage: _errorMessage,
                      onToggleSenhaVisivel: _toggleSenhaVisivel,
                      onCloseError: () {
                        setState(() {
                          _errorMessage = null;
                        });
                      },
                    ),
                    const Spacer(),
                    LoginButton(
                      carregando: _carregando,
                      onPressed: _enviar,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}