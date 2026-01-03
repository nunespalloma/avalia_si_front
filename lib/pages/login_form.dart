import 'package:flutter/material.dart';
import '../services/auth_service.dart';       // sobe um nível: lib/
import '../widgets/email_field.dart';
import '../widgets/password_field.dart';
import '../widgets/login_button.dart';

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Login OK! Bem-vindo, ${resposta['email'] ?? email}',
          ),
        ),
      );

      // Exemplo de navegação pós-login:
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (_) => const HomePage()),
      // );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro no login: $e'),
        ),
      );
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
        ],
      ),
    );
  }
}
