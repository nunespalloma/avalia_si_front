import 'package:flutter/material.dart';

class SignUpForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController matriculaController;
  final TextEditingController senhaController;
  final TextEditingController confirmarSenhaController;
  final bool senhaVisivel;
  final bool confirmarSenhaVisivel;
  final VoidCallback onToggleSenhaVisivel;
  final VoidCallback onToggleConfirmarSenhaVisivel;

  const SignUpForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.matriculaController,
    required this.senhaController,
    required this.confirmarSenhaController,
    required this.senhaVisivel,
    required this.confirmarSenhaVisivel,
    required this.onToggleSenhaVisivel,
    required this.onToggleConfirmarSenhaVisivel,
  });

  InputDecoration buildDecoration(String label) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      alignLabelWithHint: false,

      labelStyle: const TextStyle(
        color: Colors.black45,
        fontSize: 14,
      ),
      floatingLabelStyle: const TextStyle(
        color: Colors.black54,
        fontSize: 14,
      ),

      contentPadding: const EdgeInsets.only(top: 8, bottom: 8),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black26),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black54),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            cursorColor: Colors.black,
            decoration: buildDecoration('E-mail UFF'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Informe seu e-mail';
              }

              final email = value.trim();
              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

              if (!emailRegex.hasMatch(email)) {
                return 'Informe um e-mail válido';
              }

              return null;
            },
          ),
          const SizedBox(height: 24),

          TextFormField(
            controller: matriculaController,
            keyboardType: TextInputType.number,
            cursorColor: Colors.black,
            decoration: buildDecoration('Matrícula'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Informe sua matrícula';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          TextFormField(
            controller: senhaController,
            obscureText: !senhaVisivel,
            cursorColor: Colors.black,
            decoration: buildDecoration('Senha').copyWith(
              suffixIcon: IconButton(
                onPressed: onToggleSenhaVisivel,
                icon: Icon(
                  senhaVisivel ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                  color: Colors.black54,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Informe sua senha';
              }
              if (value.length < 6) {
                return 'A senha deve ter pelo menos 6 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          TextFormField(
            controller: confirmarSenhaController,
            obscureText: !confirmarSenhaVisivel,
            cursorColor: Colors.black,
            decoration: buildDecoration('Confirme a senha').copyWith(
              suffixIcon: IconButton(
                onPressed: onToggleConfirmarSenhaVisivel,
                icon: Icon(
                  confirmarSenhaVisivel
                      ? Icons.visibility_off
                      : Icons.visibility,
                  size: 20,
                  color: Colors.black54,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Confirme sua senha';
              }
              if (value != senhaController.text) {
                return 'As senhas não coincidem';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}