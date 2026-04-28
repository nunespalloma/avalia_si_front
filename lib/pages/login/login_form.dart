import 'package:flutter/material.dart';

import '../../widgets/email_field.dart';
import '../../widgets/password_field.dart';
import '../../widgets/error_message.dart';

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController senhaController;
  final bool senhaVisivel;
  final String? errorMessage;
  final VoidCallback onToggleSenhaVisivel;
  final VoidCallback onCloseError;
  final VoidCallback onForgotPassword;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.senhaController,
    required this.senhaVisivel,
    required this.errorMessage,
    required this.onToggleSenhaVisivel,
    required this.onCloseError,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          EmailField(controller: emailController),
          const SizedBox(height: 16),

          PasswordField(
            controller: senhaController,
            senhaVisivel: senhaVisivel,
            onToggleSenhaVisivel: onToggleSenhaVisivel,
          ),

          const SizedBox(height: 12),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onForgotPassword,
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

          const SizedBox(height: 16),

          if (errorMessage != null)
            ErrorMessage(
              message: errorMessage!,
              onClose: onCloseError,
            ),
        ],
      ),
    );
  }
}