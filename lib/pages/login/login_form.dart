import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../widgets/email_field.dart';
import '../../widgets/password_field.dart';
import '../../widgets/login_button.dart';
import '../../widgets/error_message.dart';
import '../home/home_page.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _senhaVisivel = false;
  bool _carregando = false;
  String? _errorMessage;

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final senha = _senhaController.text;

    setState(() {
      _carregando = true;
    });

    try {
      final resposta = await _authService.login(email, senha);
      if (!mounted) return;

      setState(() {
        _errorMessage = null; // limpa erro no sucesso
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'E-mail ou senha incorretos. Tente novamente.';
      });
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  void _toggleSenhaVisivel() {
    setState(() {
      _senhaVisivel = !_senhaVisivel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          EmailField(controller: _emailController),
          const SizedBox(height: 16),
          PasswordField(
            controller: _senhaController,
            senhaVisivel: _senhaVisivel,
            onToggleSenhaVisivel: _toggleSenhaVisivel,
          ),

          // "Esqueceu a senha?" alinhado à direita
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: fluxo de recuperação de senha
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Esqueceu a senha?',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          LoginButton(
            carregando: _carregando,
            onPressed: _enviar,
          ),

          // Mensagem de erro abaixo do botão
          if (_errorMessage != null)
            ErrorMessage(
              message: _errorMessage!,
              onClose: () {
                setState(() {
                  _errorMessage = null;
                });
              },
            ),
        ],
      ),
    );
  }
}
