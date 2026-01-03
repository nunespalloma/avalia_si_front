import 'package:flutter/material.dart';
import '../../services/auth_service.dart';       // sobe um nível: lib/
import '../../widgets/email_field.dart';
import '../../widgets/password_field.dart';
import '../../widgets/login_button.dart';
import '../../pages/home/home_page.dart';
import '../../widgets/error_message.dart';

/// Formulário de login em si (possui estado)
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

  // instancia do serviço que chama o backend Ruby
  final AuthService _authService = AuthService();

  String? _errorMessage;

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

      // limpa mensagem de erro ao obter sucesso
      setState(() {
        _errorMessage = null;
      });

      // Redireciona para HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      if (!mounted) return;

      // deixa mensagem fixa até o usuário fechar ou tentar novamente
      setState(() {
        _errorMessage = "E-mail ou senha incorretos. Tente novamente.";
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _carregando = false;
      });
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
        mainAxisSize: MainAxisSize.min,
        children: [
          EmailField(
            controller: _emailController,
          ),
          const SizedBox(height: 16),
          PasswordField(
            controller: _senhaController,
            senhaVisivel: _senhaVisivel,
            onToggleSenhaVisivel: _toggleSenhaVisivel,
          ),
          const SizedBox(height: 24),
          LoginButton(
            carregando: _carregando,
            onPressed: _enviar,
          ),
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
