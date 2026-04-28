import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../widgets/email_field.dart';
import '../../widgets/error_message.dart';
import '../../widgets/login_button.dart';
import 'reset_password_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final AuthService _authService = AuthService();

  bool _carregando = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _carregando = true;
      _errorMessage = null;
    });

    try {
      final response = await _authService.forgotPassword(
        _emailController.text.trim(),
      );

      if (!mounted) return;

      final String token = response['token'].toString();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordPage(token: token),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Não foi possível iniciar a recuperação de senha.';
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
                  'Recuperar\nsenha',
                  textAlign: TextAlign.center,
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
                          EmailField(controller: _emailController),

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
                      texto: 'Continuar',
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