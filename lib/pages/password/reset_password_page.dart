import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/error_message.dart';
import '../../widgets/login_button.dart';
import '../login/login_page.dart';

class ResetPasswordPage extends StatefulWidget {
  final String token;

  const ResetPasswordPage({
    super.key,
    required this.token,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  bool _senhaVisivel = false;
  bool _confirmarSenhaVisivel = false;
  bool _carregando = false;
  String? _errorMessage;

  @override
  void dispose() {
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_senhaController.text != _confirmarSenhaController.text) {
      setState(() {
        _errorMessage = 'As senhas não coincidem';
      });
      return;
    }

    setState(() {
      _carregando = true;
      _errorMessage = null;
    });

    try {
      await _authService.resetPassword(
        token: widget.token,
        password: _senhaController.text,
        passwordConfirmation: _confirmarSenhaController.text,
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginPage(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Não foi possível alterar a senha.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  String? _validarSenha(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe a senha';
    }

    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }

    return null;
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
                child: Text(
                  'Nova\nsenha',
                  textAlign: TextAlign.left,
                  style: TextStyle(
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

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _senhaController,
                            obscureText: !_senhaVisivel,
                            validator: _validarSenha,
                            decoration: InputDecoration(
                              labelText: 'Nova senha',
                              border: const UnderlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _senhaVisivel
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _senhaVisivel = !_senhaVisivel;
                                  });
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _confirmarSenhaController,
                            obscureText: !_confirmarSenhaVisivel,
                            validator: _validarSenha,
                            decoration: InputDecoration(
                              labelText: 'Confirmar senha',
                              border: const UnderlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _confirmarSenhaVisivel
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _confirmarSenhaVisivel =
                                        !_confirmarSenhaVisivel;
                                  });
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

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